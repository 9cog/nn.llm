-- SwiGLU: Swish-Gated Linear Unit activation
-- Used in LLaMA feedforward networks

local SwiGLU, parent = torch.class('nn.SwiGLU', 'nn.Module')

function SwiGLU:__init()
   parent.__init(self)
   
   -- Temporary buffers
   self.gate = torch.Tensor()
   self.gateActivation = torch.Tensor()
end

function SwiGLU:updateOutput(input)
   -- Input should be split into two parts: gate and value
   -- SwiGLU(x) = Swish(gate) * value = (gate * sigmoid(gate)) * value
   
   local dim = input:size(input:dim())
   if dim % 2 ~= 0 then
      error('SwiGLU: input last dimension must be even')
   end
   
   local halfDim = dim / 2
   
   -- Split input into gate and value
   self.gate = input:narrow(input:dim(), 1, halfDim)
   local value = input:narrow(input:dim(), halfDim + 1, halfDim)
   
   -- Apply Swish to gate: gate * sigmoid(gate)
   self.gateActivation:resizeAs(self.gate)
   self.gateActivation:copy(self.gate)
   
   -- Sigmoid
   local sigmoid = torch.Tensor():resizeAs(self.gate)
   sigmoid:copy(self.gate):exp():add(1):pow(-1)
   
   -- Swish = gate * sigmoid(gate)
   self.gateActivation:cmul(sigmoid)
   
   -- SwiGLU = Swish(gate) * value
   self.output:resizeAs(value)
   self.output:cmul(self.gateActivation, value)
   
   return self.output
end

function SwiGLU:updateGradInput(input, gradOutput)
   local dim = input:size(input:dim())
   local halfDim = dim / 2
   
   -- Get gate and value from input
   local gate = input:narrow(input:dim(), 1, halfDim)
   local value = input:narrow(input:dim(), halfDim + 1, halfDim)
   
   -- Compute sigmoid and swish
   local sigmoid = torch.Tensor():resizeAs(gate)
   sigmoid:copy(gate):exp():add(1):pow(-1)
   
   local swish = torch.Tensor():resizeAs(gate)
   swish:cmul(gate, sigmoid)
   
   -- Gradient w.r.t value: gradOutput * swish
   local gradValue = torch.Tensor():resizeAs(gradOutput)
   gradValue:cmul(gradOutput, swish)
   
   -- Gradient w.r.t gate: gradOutput * value * d(swish)/d(gate)
   -- d(swish)/d(gate) = sigmoid + gate * sigmoid * (1 - sigmoid)
   local dSwish = torch.Tensor():resizeAs(gate)
   local oneMinusSigmoid = torch.Tensor():resizeAs(sigmoid)
   oneMinusSigmoid:fill(1):add(-1, sigmoid)
   
   dSwish:copy(sigmoid)
   dSwish:addcmul(gate, sigmoid):cmul(oneMinusSigmoid):add(sigmoid)
   
   local gradGate = torch.Tensor():resizeAs(gradOutput)
   gradGate:cmul(gradOutput, value):cmul(dSwish)
   
   -- Concatenate gradients
   self.gradInput:resize(input:size())
   self.gradInput:narrow(input:dim(), 1, halfDim):copy(gradGate)
   self.gradInput:narrow(input:dim(), halfDim + 1, halfDim):copy(gradValue)
   
   return self.gradInput
end

function SwiGLU:__tostring__()
   return torch.type(self) .. '()'
end
