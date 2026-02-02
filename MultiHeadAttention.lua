-- MultiHeadAttention: Multi-Head Attention with Grouped-Query Attention (GQA) support
-- Used as the core attention mechanism in LLaMA

local MultiHeadAttention, parent = torch.class('nn.MultiHeadAttention', 'nn.Module')

function MultiHeadAttention:__init(dim, nHeads, nKVHeads, dropout)
   parent.__init(self)
   
   self.dim = dim
   self.nHeads = nHeads
   self.nKVHeads = nKVHeads or nHeads  -- For GQA: fewer KV heads than Q heads
   self.headDim = dim / nHeads
   self.dropout = dropout or 0.0
   
   if dim % nHeads ~= 0 then
      error('MultiHeadAttention: dim must be divisible by nHeads')
   end
   
   if nHeads % self.nKVHeads ~= 0 then
      error('MultiHeadAttention: nHeads must be divisible by nKVHeads')
   end
   
   self.nRep = nHeads / self.nKVHeads  -- Number of times to repeat KV
   
   -- Query, Key, Value projections
   self.wq = nn.Linear(dim, nHeads * self.headDim, false)
   self.wk = nn.Linear(dim, self.nKVHeads * self.headDim, false)
   self.wv = nn.Linear(dim, self.nKVHeads * self.headDim, false)
   self.wo = nn.Linear(nHeads * self.headDim, dim, false)
   
   -- Rotary embeddings for positional encoding
   self.rope = nn.RotaryEmbedding(self.headDim)
   
   -- Dropout
   if self.dropout > 0 then
      self.dropoutModule = nn.Dropout(self.dropout)
   end
   
   -- KV cache for inference
   self.cache_k = nil
   self.cache_v = nil
   
   -- Temporary buffers
   self.scores = torch.Tensor()
   self.attnWeights = torch.Tensor()
end

function MultiHeadAttention:_repeatKV(x, nRep)
   -- Repeat key/value tensors for grouped-query attention
   if nRep == 1 then
      return x
   end
   
   local batchSize = x:size(1)
   local seqLen = x:size(2)
   local nKVHeads = x:size(3)
   local headDim = x:size(4)
   
   -- Expand: (batch, seq_len, n_kv_heads, head_dim) -> 
   --         (batch, seq_len, n_heads, head_dim)
   local expanded = torch.Tensor(batchSize, seqLen, nKVHeads * nRep, headDim)
   
   for i = 1, nKVHeads do
      for j = 1, nRep do
         local idx = (i - 1) * nRep + j
         expanded:select(3, idx):copy(x:select(3, i))
      end
   end
   
   return expanded
end

function MultiHeadAttention:updateOutput(input)
   local x = input
   local batchSize = x:size(1)
   local seqLen = x:size(2)
   local dim = x:size(3)
   
   -- Linear projections
   local q = self.wq:forward(x)  -- (batch, seq_len, n_heads * head_dim)
   local k = self.wk:forward(x)  -- (batch, seq_len, n_kv_heads * head_dim)
   local v = self.wv:forward(x)  -- (batch, seq_len, n_kv_heads * head_dim)
   
   -- Reshape for multi-head attention
   q = q:view(batchSize, seqLen, self.nHeads, self.headDim)
   k = k:view(batchSize, seqLen, self.nKVHeads, self.headDim)
   v = v:view(batchSize, seqLen, self.nKVHeads, self.headDim)
   
   -- Apply rotary embeddings
   q = self.rope:forward(q)
   k = self.rope:forward(k)
   
   -- Repeat k, v for grouped-query attention
   k = self:_repeatKV(k, self.nRep)
   v = self:_repeatKV(v, self.nRep)
   
   -- Transpose for attention: (batch, n_heads, seq_len, head_dim)
   q = q:transpose(2, 3)
   k = k:transpose(2, 3)
   v = v:transpose(2, 3)
   
   -- Compute attention scores: Q @ K^T / sqrt(head_dim)
   self.scores:resize(batchSize, self.nHeads, seqLen, seqLen)
   
   for b = 1, batchSize do
      for h = 1, self.nHeads do
         local qh = q[b][h]  -- (seq_len, head_dim)
         local kh = k[b][h]  -- (seq_len, head_dim)
         
         -- scores = Q @ K^T
         self.scores[b][h]:mm(qh, kh:t())
      end
   end
   
   -- Scale by sqrt(head_dim)
   self.scores:div(math.sqrt(self.headDim))
   
   -- Apply causal mask (upper triangular)
   for b = 1, batchSize do
      for h = 1, self.nHeads do
         for i = 1, seqLen do
            for j = i + 1, seqLen do
               self.scores[b][h][i][j] = -1e9
            end
         end
      end
   end
   
   -- Softmax
   self.attnWeights:resizeAs(self.scores)
   for b = 1, batchSize do
      for h = 1, self.nHeads do
         for i = 1, seqLen do
            local row = self.scores[b][h][i]
            local maxVal = row:max()
            local expRow = row:clone():add(-maxVal):exp()
            local sumExp = expRow:sum()
            self.attnWeights[b][h][i]:copy(expRow):div(sumExp)
         end
      end
   end
   
   -- Apply dropout
   if self.dropout > 0 and self.train then
      self.attnWeights = self.dropoutModule:forward(self.attnWeights)
   end
   
   -- Attention output: attn_weights @ V
   local attnOutput = torch.Tensor(batchSize, self.nHeads, seqLen, self.headDim)
   
   for b = 1, batchSize do
      for h = 1, self.nHeads do
         local weights = self.attnWeights[b][h]  -- (seq_len, seq_len)
         local vh = v[b][h]  -- (seq_len, head_dim)
         
         attnOutput[b][h]:mm(weights, vh)
      end
   end
   
   -- Transpose back: (batch, seq_len, n_heads, head_dim)
   attnOutput = attnOutput:transpose(2, 3)
   
   -- Concatenate heads
   attnOutput = attnOutput:contiguous():view(batchSize, seqLen, self.nHeads * self.headDim)
   
   -- Output projection
   self.output = self.wo:forward(attnOutput)
   
   return self.output
end

function MultiHeadAttention:updateGradInput(input, gradOutput)
   local batchSize = input:size(1)
   local seqLen = input:size(2)
   
   -- Backward through output projection
   local gradAttnOutput = self.wo:backward(
      torch.Tensor(batchSize, seqLen, self.nHeads * self.headDim), 
      gradOutput
   )
   
   -- This is a simplified backward pass
   -- Full implementation would backprop through attention mechanism
   self.gradInput = torch.Tensor():resizeAs(input):zero()
   
   return self.gradInput
end

function MultiHeadAttention:accGradParameters(input, gradOutput, scale)
   -- Accumulate gradients for all submodules
   scale = scale or 1
   
   -- This would accumulate gradients through all projections
   -- Simplified for now
end

function MultiHeadAttention:parameters()
   local params = {}
   local gradParams = {}
   
   local function addParams(module)
      local p, gp = module:parameters()
      if p then
         for i = 1, #p do
            table.insert(params, p[i])
            table.insert(gradParams, gp[i])
         end
      end
   end
   
   addParams(self.wq)
   addParams(self.wk)
   addParams(self.wv)
   addParams(self.wo)
   
   return params, gradParams
end

function MultiHeadAttention:training()
   parent.training(self)
   self.wq:training()
   self.wk:training()
   self.wv:training()
   self.wo:training()
   if self.dropoutModule then
      self.dropoutModule:training()
   end
end

function MultiHeadAttention:evaluate()
   parent.evaluate(self)
   self.wq:evaluate()
   self.wk:evaluate()
   self.wv:evaluate()
   self.wo:evaluate()
   if self.dropoutModule then
      self.dropoutModule:evaluate()
   end
end

function MultiHeadAttention:__tostring__()
   return torch.type(self) ..
      string.format('(dim=%d, n_heads=%d, n_kv_heads=%d)', 
         self.dim, self.nHeads, self.nKVHeads)
end
