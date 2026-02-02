-- FeedForward: Feed-forward network with SwiGLU activation
-- Used in LLaMA transformer blocks

local FeedForward, parent = torch.class('nn.FeedForward', 'nn.Module')

function FeedForward:__init(dim, hiddenDim, dropout)
   parent.__init(self)
   
   self.dim = dim
   self.hiddenDim = hiddenDim or (4 * dim)
   self.dropout = dropout or 0.0
   
   -- Three linear layers for SwiGLU
   -- w1 and w3 are used for the gate and value respectively
   self.w1 = nn.Linear(dim, self.hiddenDim, false)  -- Gate projection
   self.w2 = nn.Linear(self.hiddenDim, dim, false)  -- Output projection
   self.w3 = nn.Linear(dim, self.hiddenDim, false)  -- Value projection
   
   -- SwiGLU activation
   self.swiglu = nn.SwiGLU()
   
   -- Dropout
   if self.dropout > 0 then
      self.dropoutModule = nn.Dropout(self.dropout)
   end
   
   -- Temporary storage
   self.w1Out = torch.Tensor()
   self.w3Out = torch.Tensor()
   self.combined = torch.Tensor()
end

function FeedForward:updateOutput(input)
   -- Forward pass: w2(SwiGLU(w1(x), w3(x)))
   
   -- Compute gate and value projections
   self.w1Out = self.w1:forward(input)  -- Gate
   self.w3Out = self.w3:forward(input)  -- Value
   
   -- Combine for SwiGLU: concatenate along last dimension
   local batchSize = input:size(1)
   local seqLen = input:size(2)
   
   self.combined:resize(batchSize, seqLen, 2 * self.hiddenDim)
   self.combined:narrow(3, 1, self.hiddenDim):copy(self.w1Out)
   self.combined:narrow(3, self.hiddenDim + 1, self.hiddenDim):copy(self.w3Out)
   
   -- Apply SwiGLU activation
   local activated = self.swiglu:forward(self.combined)
   
   -- Apply dropout if training
   if self.dropout > 0 and self.train then
      activated = self.dropoutModule:forward(activated)
   end
   
   -- Output projection
   self.output = self.w2:forward(activated)
   
   return self.output
end

function FeedForward:updateGradInput(input, gradOutput)
   -- Simplified backward pass
   -- Full implementation would backprop through all layers
   
   self.gradInput = torch.Tensor():resizeAs(input):zero()
   
   return self.gradInput
end

function FeedForward:accGradParameters(input, gradOutput, scale)
   -- Accumulate gradients for all submodules
   scale = scale or 1
   
   -- This would accumulate gradients through all layers
   -- Simplified for now
end

function FeedForward:parameters()
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
   
   addParams(self.w1)
   addParams(self.w2)
   addParams(self.w3)
   
   return params, gradParams
end

function FeedForward:training()
   parent.training(self)
   self.w1:training()
   self.w2:training()
   self.w3:training()
   if self.dropoutModule then
      self.dropoutModule:training()
   end
end

function FeedForward:evaluate()
   parent.evaluate(self)
   self.w1:evaluate()
   self.w2:evaluate()
   self.w3:evaluate()
   if self.dropoutModule then
      self.dropoutModule:evaluate()
   end
end

function FeedForward:__tostring__()
   return torch.type(self) ..
      string.format('(dim=%d, hidden_dim=%d)', self.dim, self.hiddenDim)
end
