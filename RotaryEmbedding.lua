-- RotaryEmbedding: Rotary Position Embeddings (RoPE)
-- Used in LLaMA for position encoding

local RotaryEmbedding, parent = torch.class('nn.RotaryEmbedding', 'nn.Module')

function RotaryEmbedding:__init(dim, maxSeqLen, base)
   parent.__init(self)
   self.dim = dim
   self.maxSeqLen = maxSeqLen or 2048
   self.base = base or 10000.0
   
   -- Precompute frequency tensor
   self:_computeFreqs()
end

function RotaryEmbedding:_computeFreqs()
   -- Compute inverse frequencies
   local inv_freq = torch.Tensor(self.dim / 2)
   for i = 1, self.dim / 2 do
      inv_freq[i] = 1.0 / (self.base ^ ((i - 1) * 2.0 / self.dim))
   end
   
   -- Create position indices
   local t = torch.range(0, self.maxSeqLen - 1)
   
   -- Compute freqs: outer product of t and inv_freq
   self.freqs = torch.Tensor(self.maxSeqLen, self.dim / 2)
   for i = 1, self.maxSeqLen do
      for j = 1, self.dim / 2 do
         self.freqs[i][j] = t[i] * inv_freq[j]
      end
   end
   
   -- Precompute cos and sin
   self.cos_cached = torch.cos(self.freqs)
   self.sin_cached = torch.sin(self.freqs)
end

function RotaryEmbedding:_rotateHalf(x)
   -- Rotate half the hidden dims
   local x1 = x:narrow(x:dim(), 1, x:size(x:dim()) / 2)
   local x2 = x:narrow(x:dim(), x:size(x:dim()) / 2 + 1, x:size(x:dim()) / 2)
   
   local rotated = torch.Tensor():resizeAs(x)
   local r1 = rotated:narrow(rotated:dim(), 1, x:size(x:dim()) / 2)
   local r2 = rotated:narrow(rotated:dim(), x:size(x:dim()) / 2 + 1, x:size(x:dim()) / 2)
   
   r1:copy(x2):mul(-1)
   r2:copy(x1)
   
   return rotated
end

function RotaryEmbedding:_applyRotary(x, cos, sin)
   -- Apply rotary embeddings: x * cos + rotate_half(x) * sin
   local x_rotated = self:_rotateHalf(x)
   
   local output = torch.Tensor():resizeAs(x)
   output:cmul(x, cos):addcmul(x_rotated, sin)
   
   return output
end

function RotaryEmbedding:updateOutput(input)
   -- input: (batch, seq_len, n_heads, head_dim)
   local batchSize = input:size(1)
   local seqLen = input:size(2)
   local nHeads = input:size(3)
   local headDim = input:size(4)
   
   if headDim ~= self.dim then
      error(string.format('RotaryEmbedding: head_dim (%d) != dim (%d)', headDim, self.dim))
   end
   
   if seqLen > self.maxSeqLen then
      error(string.format('RotaryEmbedding: seq_len (%d) > max_seq_len (%d)', seqLen, self.maxSeqLen))
   end
   
   -- Get cos and sin for current sequence length
   local cos = self.cos_cached:narrow(1, 1, seqLen)
   local sin = self.sin_cached:narrow(1, 1, seqLen)
   
   -- Expand to match input dimensions
   cos = cos:view(1, seqLen, 1, headDim / 2)
      :expand(batchSize, seqLen, nHeads, headDim / 2)
   sin = sin:view(1, seqLen, 1, headDim / 2)
      :expand(batchSize, seqLen, nHeads, headDim / 2)
   
   -- Duplicate cos and sin to match full head_dim
   local cos_full = torch.Tensor(batchSize, seqLen, nHeads, headDim)
   local sin_full = torch.Tensor(batchSize, seqLen, nHeads, headDim)
   
   for i = 1, 2 do
      local start = (i - 1) * (headDim / 2) + 1
      cos_full:narrow(4, start, headDim / 2):copy(cos)
      sin_full:narrow(4, start, headDim / 2):copy(sin)
   end
   
   -- Apply rotation
   self.output = self:_applyRotary(input, cos_full, sin_full)
   
   return self.output
end

function RotaryEmbedding:updateGradInput(input, gradOutput)
   -- Gradient through rotary is the inverse rotation
   local batchSize = input:size(1)
   local seqLen = input:size(2)
   local nHeads = input:size(3)
   local headDim = input:size(4)
   
   -- Get cos and sin for current sequence length
   local cos = self.cos_cached:narrow(1, 1, seqLen)
   local sin = self.sin_cached:narrow(1, 1, seqLen)
   
   -- Expand to match input dimensions
   cos = cos:view(1, seqLen, 1, headDim / 2)
      :expand(batchSize, seqLen, nHeads, headDim / 2)
   sin = sin:view(1, seqLen, 1, headDim / 2)
      :expand(batchSize, seqLen, nHeads, headDim / 2)
   
   -- Duplicate cos and sin to match full head_dim
   local cos_full = torch.Tensor(batchSize, seqLen, nHeads, headDim)
   local sin_full = torch.Tensor(batchSize, seqLen, nHeads, headDim)
   
   for i = 1, 2 do
      local start = (i - 1) * (headDim / 2) + 1
      local stop = i * (headDim / 2)
      cos_full:narrow(4, start, headDim / 2):copy(cos)
      sin_full:narrow(4, start, headDim / 2):copy(sin)
   end
   
   -- Apply inverse rotation (use negated sin copy)
   local sin_neg = sin_full:clone():mul(-1)
   self.gradInput = self:_applyRotary(gradOutput, cos_full, sin_neg)
   
   return self.gradInput
end

function RotaryEmbedding:__tostring__()
   return torch.type(self) .. 
      string.format('(dim=%d, max_seq_len=%d)', self.dim, self.maxSeqLen)
end
