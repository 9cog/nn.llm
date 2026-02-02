-- LLaMA: LLaMA Language Model implementation in pure Lua
-- Core transformer-based language model

local LLaMA, parent = torch.class('nn.LLaMA', 'nn.Module')

function LLaMA:__init(config)
   parent.__init(self)
   
   -- Model configuration
   self.vocabSize = config.vocabSize or 32000
   self.dim = config.dim or 512
   self.nLayers = config.nLayers or 8
   self.nHeads = config.nHeads or 8
   self.nKVHeads = config.nKVHeads or self.nHeads
   self.hiddenDim = config.hiddenDim or (4 * self.dim)
   self.maxSeqLen = config.maxSeqLen or 2048
   self.dropout = config.dropout or 0.0
   self.normEps = config.normEps or 1e-6
   
   -- Token embeddings
   self.tokEmbeddings = nn.LookupTable(self.vocabSize, self.dim)
   
   -- Transformer blocks
   self.layers = {}
   for i = 1, self.nLayers do
      self.layers[i] = nn.TransformerBlock(
         self.dim, self.nHeads, self.nKVHeads, 
         self.hiddenDim, self.dropout, self.normEps
      )
   end
   
   -- Final normalization
   self.norm = nn.RMSNorm(self.dim, self.normEps)
   
   -- Output projection (language model head)
   self.output = nn.Linear(self.dim, self.vocabSize, false)
   
   -- Share embeddings with output layer (weight tying)
   if config.tieWeights then
      self.output.weight = self.tokEmbeddings.weight
      self.output.gradWeight = self.tokEmbeddings.gradWeight
   end
   
   -- Initialize weights
   self:reset()
end

function LLaMA:reset()
   -- Initialize embeddings
   local std = 1.0 / math.sqrt(self.dim)
   self.tokEmbeddings.weight:normal(0, std)
   
   -- Initialize output layer if not tied
   if self.output.weight ~= self.tokEmbeddings.weight then
      self.output.weight:normal(0, std)
   end
end

function LLaMA:updateOutput(input)
   -- input: (batch_size, seq_len) - token indices
   local batchSize = input:size(1)
   local seqLen = input:size(2)
   
   if seqLen > self.maxSeqLen then
      error(string.format('LLaMA: seq_len (%d) > max_seq_len (%d)', seqLen, self.maxSeqLen))
   end
   
   -- Embed tokens
   local h = self.tokEmbeddings:forward(input)  -- (batch, seq_len, dim)
   
   -- Pass through transformer blocks
   for i = 1, self.nLayers do
      h = self.layers[i]:forward(h)
   end
   
   -- Final normalization
   h = self.norm:forward(h)
   
   -- Project to vocabulary
   self.output:forward(h)  -- (batch, seq_len, vocab_size)
   
   return self.output.output
end

function LLaMA:updateGradInput(input, gradOutput)
   -- Simplified backward pass
   self.gradInput = torch.Tensor():resizeAs(input):zero()
   return self.gradInput
end

function LLaMA:parameters()
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
   
   addParams(self.tokEmbeddings)
   
   for i = 1, self.nLayers do
      addParams(self.layers[i])
   end
   
   addParams(self.norm)
   
   -- Only add output params if not weight-tied
   if self.output.weight ~= self.tokEmbeddings.weight then
      addParams(self.output)
   end
   
   return params, gradParams
end

function LLaMA:training()
   parent.training(self)
   self.tokEmbeddings:training()
   for i = 1, self.nLayers do
      self.layers[i]:training()
   end
   self.norm:training()
   self.output:training()
end

function LLaMA:evaluate()
   parent.evaluate(self)
   self.tokEmbeddings:evaluate()
   for i = 1, self.nLayers do
      self.layers[i]:evaluate()
   end
   self.norm:evaluate()
   self.output:evaluate()
end

function LLaMA:generate(tokens, maxNewTokens, temperature, topP)
   -- Simple greedy generation
   self:evaluate()
   
   temperature = temperature or 1.0
   maxNewTokens = maxNewTokens or 50
   
   local generated = tokens:clone()
   
   for i = 1, maxNewTokens do
      -- Forward pass
      local logits = self:forward(generated)
      
      -- Get last token logits (handle single batch case)
      local nextTokenLogits
      if logits:size(1) == 1 then
         nextTokenLogits = logits[1][-1]  -- Keep dimensions for single batch
      else
         nextTokenLogits = logits[{{}, -1, {}}]:squeeze()
      end
      
      -- Apply temperature
      nextTokenLogits:div(temperature)
      
      -- Softmax to get probabilities
      local probs = torch.exp(nextTokenLogits)
      probs:div(probs:sum())
      
      -- Sample (greedy for now - just take argmax)
      local _, nextToken = probs:max(1)
      nextToken = nextToken[1]
      
      -- Append to sequence
      local newGenerated = torch.LongTensor(1, generated:size(2) + 1)
      newGenerated[{{}, {1, -2}}]:copy(generated)
      newGenerated[1][-1] = nextToken
      generated = newGenerated
      
      -- Check for end token (assuming 2 is EOS)
      if nextToken == 2 then
         break
      end
   end
   
   return generated
end

function LLaMA:__tostring__()
   return torch.type(self) ..
      string.format('(vocab=%d, dim=%d, layers=%d, heads=%d)', 
         self.vocabSize, self.dim, self.nLayers, self.nHeads)
end
