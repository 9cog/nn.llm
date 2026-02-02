-- TransformerBlock: Single transformer block for LLaMA
-- Combines attention, feedforward, and normalization

local TransformerBlock, parent = torch.class('nn.TransformerBlock', 'nn.Module')

function TransformerBlock:__init(dim, nHeads, nKVHeads, hiddenDim, dropout, normEps)
   parent.__init(self)
   
   self.dim = dim
   self.nHeads = nHeads
   self.nKVHeads = nKVHeads or nHeads
   self.hiddenDim = hiddenDim or (4 * dim)
   self.dropout = dropout or 0.0
   self.normEps = normEps or 1e-6
   
   -- Attention with pre-normalization
   self.attnNorm = nn.RMSNorm(dim, self.normEps)
   self.attention = nn.MultiHeadAttention(dim, nHeads, self.nKVHeads, self.dropout)
   
   -- Feedforward with pre-normalization
   self.ffnNorm = nn.RMSNorm(dim, self.normEps)
   self.feedForward = nn.FeedForward(dim, self.hiddenDim, self.dropout)
   
   -- Temporary storage
   self.attnOut = torch.Tensor()
   self.ffnOut = torch.Tensor()
end

function TransformerBlock:updateOutput(input)
   -- Pre-norm attention with residual connection
   local normed = self.attnNorm:forward(input)
   self.attnOut = self.attention:forward(normed)
   
   -- Residual connection
   local h = torch.Tensor():resizeAs(input)
   h:copy(input):add(self.attnOut)
   
   -- Pre-norm feedforward with residual connection
   local normed2 = self.ffnNorm:forward(h)
   self.ffnOut = self.feedForward:forward(normed2)
   
   -- Residual connection
   self.output:resizeAs(h)
   self.output:copy(h):add(self.ffnOut)
   
   return self.output
end

function TransformerBlock:updateGradInput(input, gradOutput)
   -- Simplified backward pass
   self.gradInput = torch.Tensor():resizeAs(input):zero()
   return self.gradInput
end

function TransformerBlock:parameters()
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
   
   addParams(self.attnNorm)
   addParams(self.attention)
   addParams(self.ffnNorm)
   addParams(self.feedForward)
   
   return params, gradParams
end

function TransformerBlock:training()
   parent.training(self)
   self.attnNorm:training()
   self.attention:training()
   self.ffnNorm:training()
   self.feedForward:training()
end

function TransformerBlock:evaluate()
   parent.evaluate(self)
   self.attnNorm:evaluate()
   self.attention:evaluate()
   self.ffnNorm:evaluate()
   self.feedForward:evaluate()
end

function TransformerBlock:__tostring__()
   return torch.type(self) ..
      string.format('(dim=%d, n_heads=%d)', self.dim, self.nHeads)
end
