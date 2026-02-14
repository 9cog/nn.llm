--[[
   Test suite for nn.MLP module
   
   This file tests the comprehensive MLP implementation including:
   - Basic functionality (forward, backward)
   - Various activation functions
   - Dropout and batch normalization
   - Weight initialization methods
   - Training and evaluation modes
   - Parameter counting
   - Configuration options
]]

require 'torch'
require 'nn'

torch.setdefaulttensortype('torch.DoubleTensor')
torch.manualSeed(1234)

local tester = torch.Tester()
local mlptest = {}

-- Test basic MLP construction and forward pass
function mlptest.testBasicConstruction()
   local inputSize = 10
   local hiddenSizes = {20, 15}
   local outputSize = 5
   
   local mlp = nn.MLP(inputSize, hiddenSizes, outputSize)
   tester:asserteq(torch.typename(mlp), 'nn.MLP', 'Type should be nn.MLP')
   
   -- Test forward pass
   local input = torch.randn(3, inputSize) -- batch of 3
   local output = mlp:forward(input)
   
   tester:asserteq(output:size(1), 3, 'Batch size should be preserved')
   tester:asserteq(output:size(2), outputSize, 'Output size should match')
end

-- Test different activation functions
function mlptest.testActivations()
   local activations = {'relu', 'tanh', 'sigmoid', 'leakyrelu', 'elu'}
   
   for _, act in ipairs(activations) do
      local mlp = nn.MLP(5, {10}, 3, {activation = act})
      local input = torch.randn(2, 5)
      local output = mlp:forward(input)
      
      tester:asserteq(output:size(1), 2, 'Batch size preserved with ' .. act)
      tester:asserteq(output:size(2), 3, 'Output size correct with ' .. act)
   end
end

-- Test output activation functions
function mlptest.testOutputActivations()
   local outputActivations = {nil, 'sigmoid', 'tanh', 'softmax', 'logsoftmax'}
   
   for _, outAct in ipairs(outputActivations) do
      local mlp = nn.MLP(5, {10}, 3, {outputActivation = outAct})
      local input = torch.randn(2, 5)
      local output = mlp:forward(input)
      
      tester:asserteq(output:size(1), 2, 'Batch size preserved')
      tester:asserteq(output:size(2), 3, 'Output size correct')
      
      -- Check softmax constraint
      if outAct == 'softmax' then
         local sums = output:sum(2)
         tester:assertlt((sums - 1):abs():max(), 1e-5, 'Softmax should sum to 1')
      end
   end
end

-- Test dropout functionality
function mlptest.testDropout()
   local mlp = nn.MLP(10, {20, 15}, 5, {dropout = 0.5})
   local input = torch.randn(4, 10)
   
   -- Training mode
   mlp:training()
   local output1 = mlp:forward(input):clone()
   local output2 = mlp:forward(input):clone()
   
   -- Outputs should differ due to dropout
   tester:assert((output1 - output2):abs():sum() > 0, 'Dropout should randomize in training')
   
   -- Evaluation mode
   mlp:evaluate()
   local output3 = mlp:forward(input):clone()
   local output4 = mlp:forward(input):clone()
   
   -- Outputs should be identical in eval mode
   tester:assertlt((output3 - output4):abs():max(), 1e-10, 'No dropout in eval mode')
end

-- Test batch normalization
function mlptest.testBatchNorm()
   local mlp = nn.MLP(10, {20, 15}, 5, {batchNorm = true})
   local input = torch.randn(8, 10)
   
   -- Training mode
   mlp:training()
   local output1 = mlp:forward(input)
   
   -- Evaluation mode
   mlp:evaluate()
   local output2 = mlp:forward(input)
   
   tester:asserteq(output1:size(1), 8, 'Batch size preserved with BatchNorm')
   tester:asserteq(output2:size(1), 8, 'Batch size preserved in eval')
end

-- Test backward pass
function mlptest.testBackward()
   local inputSize = 10
   local hiddenSizes = {15, 10}
   local outputSize = 5
   
   local mlp = nn.MLP(inputSize, hiddenSizes, outputSize)
   mlp:training()
   
   local input = torch.randn(3, inputSize)
   local gradOutput = torch.randn(3, outputSize)
   
   -- Forward pass
   local output = mlp:forward(input)
   
   -- Backward pass
   local gradInput = mlp:backward(input, gradOutput)
   
   tester:asserteq(gradInput:size(1), 3, 'Grad batch size preserved')
   tester:asserteq(gradInput:size(2), inputSize, 'Grad input size correct')
end

-- Test gradient checking with numerical gradient
function mlptest.testGradientChecking()
   local inputSize = 5
   local hiddenSizes = {8}
   local outputSize = 3
   
   local mlp = nn.MLP(inputSize, hiddenSizes, outputSize, {
      activation = 'tanh',
      dropout = 0.0  -- disable dropout for gradient checking
   })
   mlp:training()
   
   local input = torch.randn(2, inputSize)
   local criterion = nn.MSECriterion()
   local target = torch.randn(2, outputSize)
   
   -- Get parameters
   local params, gradParams = mlp:parameters()
   
   -- Forward pass
   local output = mlp:forward(input)
   local loss = criterion:forward(output, target)
   
   -- Backward pass
   local gradOutput = criterion:backward(output, target)
   mlp:zeroGradParameters()
   mlp:backward(input, gradOutput)
   
   -- Numerical gradient checking for first parameter
   local eps = 1e-5
   local param = params[1]
   local gradParam = gradParams[1]
   
   for i = 1, math.min(5, param:nElement()) do
      -- Finite difference approximation
      param[i] = param[i] + eps
      local output1 = mlp:forward(input)
      local loss1 = criterion:forward(output1, target)
      
      param[i] = param[i] - 2 * eps
      local output2 = mlp:forward(input)
      local loss2 = criterion:forward(output2, target)
      
      param[i] = param[i] + eps  -- restore
      
      local numGrad = (loss1 - loss2) / (2 * eps)
      local analyticGrad = gradParam[i]
      
      local diff = math.abs(numGrad - analyticGrad)
      local relative = diff / (math.abs(numGrad) + math.abs(analyticGrad) + 1e-10)
      
      tester:assertlt(relative, 1e-3, string.format(
         'Gradient check failed: numerical=%.6f, analytic=%.6f', numGrad, analyticGrad))
   end
end

-- Test weight initialization methods
function mlptest.testWeightInit()
   local methods = {'xavier', 'xavier_normal', 'he', 'he_normal', 'uniform', 'normal'}
   
   for _, method in ipairs(methods) do
      local mlp = nn.MLP(10, {20}, 5, {weightInit = method})
      local params = mlp:parameters()
      
      tester:assert(params ~= nil, 'Parameters should exist for ' .. method)
      tester:assert(#params > 0, 'Should have parameters for ' .. method)
      
      -- Check that weights are initialized (not all zeros)
      local sumAbs = 0
      for i = 1, #params do
         sumAbs = sumAbs + params[i]:abs():sum()
      end
      tester:assert(sumAbs > 0, 'Weights should be initialized for ' .. method)
   end
end

-- Test reset functionality
function mlptest.testReset()
   local mlp = nn.MLP(10, {20}, 5)
   
   -- Get initial parameters
   local params1 = mlp:parameters()
   local weights1 = params1[1]:clone()
   
   -- Do some training (modify parameters)
   local input = torch.randn(2, 10)
   local gradOutput = torch.randn(2, 5)
   mlp:forward(input)
   mlp:backward(input, gradOutput)
   
   -- Reset
   mlp:reset()
   
   local params2 = mlp:parameters()
   local weights2 = params2[1]:clone()
   
   -- Weights should be different after reset
   local diff = (weights1 - weights2):abs():sum()
   tester:assert(diff > 0, 'Weights should change after reset')
end

-- Test parameter counting
function mlptest.testParamCounting()
   local mlp = nn.MLP(10, {20, 15}, 5, {bias = true})
   local count = mlp:countParams()
   
   -- Expected: (10*20 + 20) + (20*15 + 15) + (15*5 + 5) = 220 + 315 + 80 = 615
   local expected = (10 * 20 + 20) + (20 * 15 + 15) + (15 * 5 + 5)
   tester:asserteq(count, expected, 'Parameter count should match')
   
   -- Test without bias
   local mlp2 = nn.MLP(10, {20, 15}, 5, {bias = false})
   local count2 = mlp2:countParams()
   local expected2 = (10 * 20) + (20 * 15) + (15 * 5)
   tester:asserteq(count2, expected2, 'Parameter count without bias should match')
end

-- Test configuration retrieval
function mlptest.testGetConfig()
   local inputSize = 10
   local hiddenSizes = {20, 15}
   local outputSize = 5
   local options = {activation = 'relu', dropout = 0.3}
   
   local mlp = nn.MLP(inputSize, hiddenSizes, outputSize, options)
   local config = mlp:getConfig()
   
   tester:asserteq(config.inputSize, inputSize, 'Config should preserve inputSize')
   tester:asserteq(config.outputSize, outputSize, 'Config should preserve outputSize')
   tester:asserteq(#config.hiddenSizes, #hiddenSizes, 'Config should preserve hidden layer count')
   tester:asserteq(config.options.activation, 'relu', 'Config should preserve activation')
end

-- Test single hidden layer (simplest case)
function mlptest.testSingleLayer()
   local mlp = nn.MLP(10, {20}, 5)
   local input = torch.randn(3, 10)
   local output = mlp:forward(input)
   
   tester:asserteq(output:size(1), 3, 'Batch size preserved')
   tester:asserteq(output:size(2), 5, 'Output size correct')
end

-- Test deep network
function mlptest.testDeepNetwork()
   local mlp = nn.MLP(10, {50, 40, 30, 20, 10}, 5, {
      activation = 'relu',
      batchNorm = true,
      dropout = 0.2
   })
   local input = torch.randn(4, 10)
   local output = mlp:forward(input)
   
   tester:asserteq(output:size(1), 4, 'Deep network batch size preserved')
   tester:asserteq(output:size(2), 5, 'Deep network output size correct')
end

-- Test tostring
function mlptest.testToString()
   local mlp = nn.MLP(10, {20, 15}, 5, {
      activation = 'relu',
      dropout = 0.3,
      batchNorm = true
   })
   
   local str = tostring(mlp)
   tester:assert(str:find('nn.MLP') ~= nil, 'toString should contain nn.MLP')
   tester:assert(str:find('Input: 10') ~= nil, 'toString should show input size')
   tester:assert(str:find('Output: 5') ~= nil, 'toString should show output size')
end

-- Test preset configurations
function mlptest.testPresets()
   local presets = {'small', 'medium', 'large'}
   
   for _, preset in ipairs(presets) do
      local constructor = nn.MLP.create(preset)
      local mlp = constructor(784, 10)  -- MNIST-like dimensions
      
      local input = torch.randn(2, 784)
      local output = mlp:forward(input)
      
      tester:asserteq(output:size(1), 2, 'Preset ' .. preset .. ' batch size preserved')
      tester:asserteq(output:size(2), 10, 'Preset ' .. preset .. ' output size correct')
   end
end

-- Test training/evaluation mode switching
function mlptest.testModeSwitch()
   local mlp = nn.MLP(10, {20}, 5, {dropout = 0.5})
   local input = torch.randn(3, 10)
   
   -- Should start in training mode (default)
   tester:assert(mlp.train == true, 'Should start in training mode')
   
   -- Switch to eval
   mlp:evaluate()
   tester:assert(mlp.train == false, 'Should be in eval mode')
   
   -- Switch back to training
   mlp:training()
   tester:assert(mlp.train == true, 'Should be back in training mode')
end

-- Test no hidden layers (direct input to output)
function mlptest.testNoHiddenLayers()
   local mlp = nn.MLP(10, {}, 5)
   local input = torch.randn(2, 10)
   local output = mlp:forward(input)
   
   tester:asserteq(output:size(1), 2, 'No hidden layers: batch size preserved')
   tester:asserteq(output:size(2), 5, 'No hidden layers: output size correct')
end

-- Run all tests
print('\n=== Testing nn.MLP Module ===\n')
tester:add(mlptest)
tester:run()
print('\n=== All Tests Complete ===\n')
