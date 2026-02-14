--[[
   Multi-Layer Perceptron (MLP) Module
   
   A comprehensive, configurable multi-layer perceptron implementation that provides
   a flexible way to build fully-connected feedforward neural networks.
   
   Features:
   - Configurable number of layers and hidden units
   - Multiple activation function options (ReLU, Tanh, Sigmoid, LeakyReLU, ELU, etc.)
   - Optional dropout for regularization
   - Optional batch normalization
   - Multiple weight initialization strategies (Xavier, He, uniform, normal)
   - Support for different output activation (or none for regression)
   - Training/evaluation mode switching
   
   Constructor:
   nn.MLP(inputSize, hiddenSizes, outputSize [, options])
   
   Arguments:
   - inputSize: number of input features
   - hiddenSizes: table of hidden layer sizes, e.g., {128, 64, 32}
   - outputSize: number of output units
   - options: table with optional fields:
     * activation: activation function name ('relu', 'tanh', 'sigmoid', 'leakyrelu', 'elu')
                   Default: 'relu'
     * outputActivation: activation for output layer (nil, 'sigmoid', 'tanh', 'softmax')
                         Default: nil (linear output)
     * dropout: dropout probability (0 to 1), applied after each hidden layer
                Default: 0.0 (no dropout)
     * batchNorm: whether to use batch normalization after each hidden layer
                  Default: false
     * bias: whether to use bias in linear layers
             Default: true
     * weightInit: weight initialization method ('xavier', 'he', 'uniform', 'normal')
                   Default: 'xavier'
   
   Example:
   -- Create a 3-layer MLP: 784 -> 256 -> 128 -> 10
   mlp = nn.MLP(784, {256, 128}, 10, {
      activation = 'relu',
      dropout = 0.5,
      batchNorm = true,
      outputActivation = 'softmax'
   })
]]--

local MLP, parent = torch.class('nn.MLP', 'nn.Sequential')

function MLP:__init(inputSize, hiddenSizes, outputSize, options)
   parent.__init(self)
   
   -- Validate inputs
   assert(inputSize and type(inputSize) == 'number' and inputSize > 0,
          'inputSize must be a positive number')
   assert(hiddenSizes and type(hiddenSizes) == 'table',
          'hiddenSizes must be a table of layer sizes')
   assert(outputSize and type(outputSize) == 'number' and outputSize > 0,
          'outputSize must be a positive number')
   
   -- Store configuration
   self.inputSize = inputSize
   self.hiddenSizes = hiddenSizes
   self.outputSize = outputSize
   self.options = options or {}
   
   -- Parse options with defaults
   self.activation = self.options.activation or 'relu'
   self.outputActivation = self.options.outputActivation or nil
   self.dropout = self.options.dropout or 0.0
   self.batchNorm = self.options.batchNorm or false
   self.bias = (self.options.bias ~= nil) and self.options.bias or true
   self.weightInit = self.options.weightInit or 'xavier'
   
   -- Validate options
   if self.dropout < 0 or self.dropout >= 1 then
      error('dropout must be in range [0, 1)')
   end
   
   -- Build the network
   self:buildNetwork()
end

function MLP:buildNetwork()
   local layerSizes = {self.inputSize}
   for i = 1, #self.hiddenSizes do
      table.insert(layerSizes, self.hiddenSizes[i])
   end
   table.insert(layerSizes, self.outputSize)
   
   -- Build hidden layers
   for i = 1, #layerSizes - 2 do
      local inSize = layerSizes[i]
      local outSize = layerSizes[i + 1]
      
      -- Linear layer
      local linear = nn.Linear(inSize, outSize, self.bias)
      self:initWeights(linear)
      self:add(linear)
      
      -- Batch normalization (before activation)
      if self.batchNorm then
         self:add(nn.BatchNormalization(outSize))
      end
      
      -- Activation function
      self:add(self:getActivation(self.activation))
      
      -- Dropout
      if self.dropout > 0 then
         self:add(nn.Dropout(self.dropout))
      end
   end
   
   -- Output layer
   local finalInSize = layerSizes[#layerSizes - 1]
   local finalLinear = nn.Linear(finalInSize, self.outputSize, self.bias)
   self:initWeights(finalLinear)
   self:add(finalLinear)
   
   -- Optional output activation
   if self.outputActivation then
      self:add(self:getActivation(self.outputActivation))
   end
end

function MLP:getActivation(name)
   name = string.lower(name)
   
   if name == 'relu' then
      return nn.ReLU(true) -- inplace
   elseif name == 'tanh' then
      return nn.Tanh()
   elseif name == 'sigmoid' then
      return nn.Sigmoid()
   elseif name == 'leakyrelu' then
      return nn.LeakyReLU()
   elseif name == 'elu' then
      return nn.ELU()
   elseif name == 'softmax' then
      return nn.SoftMax()
   elseif name == 'logsoftmax' then
      return nn.LogSoftMax()
   elseif name == 'prelu' then
      return nn.PReLU()
   elseif name == 'rrelu' then
      return nn.RReLU()
   elseif name == 'relu6' then
      return nn.ReLU6()
   elseif name == 'softsign' then
      return nn.SoftSign()
   elseif name == 'softplus' then
      return nn.SoftPlus()
   elseif name == 'hardtanh' then
      return nn.HardTanh()
   else
      error('Unknown activation function: ' .. name .. 
            '\nSupported: relu, tanh, sigmoid, leakyrelu, elu, softmax, logsoftmax, ' ..
            'prelu, rrelu, relu6, softsign, softplus, hardtanh')
   end
end

function MLP:initWeights(linear)
   local method = string.lower(self.weightInit)
   local fanIn = linear.weight:size(2)
   local fanOut = linear.weight:size(1)
   
   if method == 'xavier' or method == 'xavier_uniform' then
      -- Xavier/Glorot uniform initialization
      local std = math.sqrt(2.0 / (fanIn + fanOut))
      linear.weight:uniform(-std, std)
      if linear.bias then
         linear.bias:zero()
      end
      
   elseif method == 'xavier_normal' then
      -- Xavier/Glorot normal initialization
      local std = math.sqrt(2.0 / (fanIn + fanOut))
      linear.weight:normal(0, std)
      if linear.bias then
         linear.bias:zero()
      end
      
   elseif method == 'he' or method == 'he_uniform' or method == 'kaiming' then
      -- He/Kaiming uniform initialization (good for ReLU)
      local std = math.sqrt(2.0 / fanIn)
      linear.weight:uniform(-std, std)
      if linear.bias then
         linear.bias:zero()
      end
      
   elseif method == 'he_normal' or method == 'kaiming_normal' then
      -- He/Kaiming normal initialization (good for ReLU)
      local std = math.sqrt(2.0 / fanIn)
      linear.weight:normal(0, std)
      if linear.bias then
         linear.bias:zero()
      end
      
   elseif method == 'uniform' then
      -- Simple uniform initialization
      local std = 1.0 / math.sqrt(fanIn)
      linear.weight:uniform(-std, std)
      if linear.bias then
         linear.bias:uniform(-std, std)
      end
      
   elseif method == 'normal' then
      -- Simple normal initialization
      linear.weight:normal(0, 0.01)
      if linear.bias then
         linear.bias:zero()
      end
      
   else
      error('Unknown weight initialization method: ' .. method ..
            '\nSupported: xavier, xavier_normal, he, he_normal, uniform, normal')
   end
end

function MLP:reset()
   -- Reset all parameters using the specified initialization
   for i = 1, #self.modules do
      local module = self.modules[i]
      if torch.typename(module) == 'nn.Linear' then
         self:initWeights(module)
      elseif torch.typename(module) == 'nn.BatchNormalization' then
         module:reset()
      end
   end
   return self
end

function MLP:__tostring__()
   local str = 'nn.MLP\n'
   str = str .. string.format('  Input: %d\n', self.inputSize)
   for i, size in ipairs(self.hiddenSizes) do
      str = str .. string.format('  Hidden[%d]: %d (%s', i, size, self.activation)
      if self.batchNorm then
         str = str .. ', BatchNorm'
      end
      if self.dropout > 0 then
         str = str .. string.format(', Dropout=%.2f', self.dropout)
      end
      str = str .. ')\n'
   end
   str = str .. string.format('  Output: %d', self.outputSize)
   if self.outputActivation then
      str = str .. string.format(' (%s)', self.outputActivation)
   end
   str = str .. '\n'
   str = str .. string.format('  Total params: %d', self:countParams())
   return str
end

function MLP:countParams()
   local params, _ = self:parameters()
   if not params then
      return 0
   end
   local total = 0
   for i = 1, #params do
      total = total + params[i]:nElement()
   end
   return total
end

function MLP:getConfig()
   -- Return configuration for serialization/reconstruction
   return {
      inputSize = self.inputSize,
      hiddenSizes = self.hiddenSizes,
      outputSize = self.outputSize,
      options = self.options
   }
end

-- Helper function to create common MLP architectures
function nn.MLP.create(config)
   --[[
      Create an MLP with a common configuration
      
      config can be:
      - 'small': for small datasets (MNIST, etc.)
      - 'medium': for medium datasets
      - 'large': for large datasets
      - a table with custom configuration
   ]]
   
   if type(config) == 'string' then
      config = string.lower(config)
      
      if config == 'small' then
         -- Small network for MNIST-like tasks
         return function(inputSize, outputSize)
            return nn.MLP(inputSize, {128, 64}, outputSize, {
               activation = 'relu',
               dropout = 0.2,
               outputActivation = 'logsoftmax'
            })
         end
         
      elseif config == 'medium' then
         -- Medium network
         return function(inputSize, outputSize)
            return nn.MLP(inputSize, {512, 256, 128}, outputSize, {
               activation = 'relu',
               dropout = 0.3,
               batchNorm = true,
               outputActivation = 'logsoftmax'
            })
         end
         
      elseif config == 'large' then
         -- Large network
         return function(inputSize, outputSize)
            return nn.MLP(inputSize, {1024, 512, 256, 128}, outputSize, {
               activation = 'relu',
               dropout = 0.4,
               batchNorm = true,
               weightInit = 'he',
               outputActivation = 'logsoftmax'
            })
         end
         
      else
         error('Unknown preset: ' .. config .. '. Supported: small, medium, large')
      end
   end
   
   -- Custom configuration
   return nn.MLP(config.inputSize, config.hiddenSizes, config.outputSize, config.options)
end
