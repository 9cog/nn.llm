-- RMSNorm: Root Mean Square Layer Normalization
-- Used in LLaMA for efficient normalization without mean centering

local RMSNorm, parent = torch.class('nn.RMSNorm', 'nn.Module')

function RMSNorm:__init(dim, eps)
   parent.__init(self)
   self.dim = dim
   self.eps = eps or 1e-6
   
   -- Learnable scale parameter (gamma)
   self.weight = torch.Tensor(dim):fill(1)
   self.gradWeight = torch.Tensor(dim):zero()
   
   -- Temporary buffers
   self.rms = torch.Tensor()
   self.normalized = torch.Tensor()
end

function RMSNorm:updateOutput(input)
   local batchSize, seqLen, dim
   
   if input:dim() == 2 then
      batchSize = input:size(1)
      dim = input:size(2)
   elseif input:dim() == 3 then
      batchSize = input:size(1)
      seqLen = input:size(2)
      dim = input:size(3)
   else
      error('RMSNorm: input must be 2D or 3D')
   end
   
   -- Compute RMS: sqrt(mean(x^2) + eps)
   self.rms:resizeAs(input)
   self.rms:copy(input):pow(2)
   
   if input:dim() == 2 then
      local sumSq = self.rms:sum(2):squeeze()
      sumSq:div(dim):add(self.eps):sqrt()
      self.rms = sumSq:view(-1, 1):expandAs(input)
   else
      local sumSq = self.rms:sum(3):squeeze()
      sumSq:div(dim):add(self.eps):sqrt()
      self.rms = sumSq:view(batchSize, seqLen, 1):expandAs(input)
   end
   
   -- Normalize: x / rms
   self.normalized:resizeAs(input)
   self.normalized:cdiv(input, self.rms)
   
   -- Scale by learned weight
   self.output:resizeAs(input)
   if input:dim() == 2 then
      self.output:copy(self.normalized)
      for i = 1, batchSize do
         self.output[i]:cmul(self.weight)
      end
   else
      self.output:copy(self.normalized)
      for i = 1, batchSize do
         for j = 1, seqLen do
            self.output[i][j]:cmul(self.weight)
         end
      end
   end
   
   return self.output
end

function RMSNorm:updateGradInput(input, gradOutput)
   local batchSize, seqLen, dim
   
   if input:dim() == 2 then
      batchSize = input:size(1)
      dim = input:size(2)
   else
      batchSize = input:size(1)
      seqLen = input:size(2)
      dim = input:size(3)
   end
   
   self.gradInput:resizeAs(input)
   
   -- Gradient through scale
   local gradNorm = torch.Tensor():resizeAs(gradOutput)
   if input:dim() == 2 then
      for i = 1, batchSize do
         gradNorm[i]:copy(gradOutput[i]):cmul(self.weight)
      end
   else
      for i = 1, batchSize do
         for j = 1, seqLen do
            gradNorm[i][j]:copy(gradOutput[i][j]):cmul(self.weight)
         end
      end
   end
   
   -- Gradient through normalization
   local gradRms = torch.Tensor():resizeAs(input)
   gradRms:cmul(self.normalized, gradNorm):mul(-1):cdiv(self.rms)
   
   local gradNormInput = torch.Tensor():resizeAs(input)
   gradNormInput:cdiv(gradNorm, self.rms)
   
   -- Gradient through RMS
   local gradSumSq = torch.Tensor():resizeAs(input)
   gradSumSq:cmul(input, gradRms):mul(2.0 / dim)
   
   self.gradInput:copy(gradNormInput):add(gradSumSq)
   
   return self.gradInput
end

function RMSNorm:accGradParameters(input, gradOutput, scale)
   scale = scale or 1
   local batchSize, seqLen, dim
   
   if input:dim() == 2 then
      batchSize = input:size(1)
      dim = input:size(2)
   else
      batchSize = input:size(1)
      seqLen = input:size(2)
      dim = input:size(3)
   end
   
   -- Gradient for weight parameter
   local gradW = torch.Tensor(dim):zero()
   if input:dim() == 2 then
      for i = 1, batchSize do
         gradW:addcmul(scale, self.normalized[i], gradOutput[i])
      end
   else
      for i = 1, batchSize do
         for j = 1, seqLen do
            gradW:addcmul(scale, self.normalized[i][j], gradOutput[i][j])
         end
      end
   end
   
   self.gradWeight:add(gradW)
end

function RMSNorm:parameters()
   return {self.weight}, {self.gradWeight}
end

function RMSNorm:__tostring__()
   return torch.type(self) .. string.format('(%d)', self.dim)
end
