--[[
   Example demonstrating the comprehensive nn.MLP module
   
   This file shows various ways to use the MLP (Multi-Layer Perceptron) module
   for building flexible feedforward neural networks.
]]

require 'nn'

print("\n=== nn.MLP Module Examples ===\n")

-- Example 1: Basic MLP for classification
print("1. Basic MLP for MNIST-style classification:")
print("   Input: 784 (28x28 image) -> Hidden: [256, 128] -> Output: 10 classes")
local mlp1 = nn.MLP(784, {256, 128}, 10, {
   activation = 'relu',
   outputActivation = 'logsoftmax'
})
print(mlp1)
print()

-- Example 2: MLP with dropout for regularization
print("2. MLP with Dropout (50%) for regularization:")
local mlp2 = nn.MLP(100, {200, 150, 100}, 20, {
   activation = 'relu',
   dropout = 0.5,
   outputActivation = 'softmax'
})
print(mlp2)
print()

-- Example 3: MLP with batch normalization
print("3. MLP with Batch Normalization:")
local mlp3 = nn.MLP(50, {128, 64, 32}, 10, {
   activation = 'relu',
   batchNorm = true,
   weightInit = 'he'
})
print(mlp3)
print()

-- Example 4: Deep MLP with multiple options
print("4. Deep MLP with all features:")
local mlp4 = nn.MLP(512, {1024, 512, 256, 128}, 64, {
   activation = 'elu',
   dropout = 0.3,
   batchNorm = true,
   weightInit = 'he_normal',
   outputActivation = nil  -- linear output for regression
})
print(mlp4)
print()

-- Example 5: Shallow network
print("5. Shallow MLP (single hidden layer):")
local mlp5 = nn.MLP(20, {50}, 5, {
   activation = 'tanh',
   outputActivation = 'sigmoid'
})
print(mlp5)
print()

-- Example 6: Using different activations
print("6. MLP with LeakyReLU activation:")
local mlp6 = nn.MLP(30, {100, 50}, 10, {
   activation = 'leakyrelu',
   dropout = 0.2
})
print(mlp6)
print()

-- Example 7: Direct mapping (no hidden layers)
print("7. Direct mapping (no hidden layers):")
local mlp7 = nn.MLP(100, {}, 10, {
   outputActivation = 'softmax'
})
print(mlp7)
print()

-- Example 8: Using preset configurations
print("8. Using preset configurations:")
print("\n   a) Small preset:")
local smallConstructor = nn.MLP.create('small')
local mlpSmall = smallConstructor(784, 10)
print(mlpSmall)

print("\n   b) Medium preset:")
local mediumConstructor = nn.MLP.create('medium')
local mlpMedium = mediumConstructor(784, 10)
print(mlpMedium)

print("\n   c) Large preset:")
local largeConstructor = nn.MLP.create('large')
local mlpLarge = largeConstructor(784, 10)
print(mlpLarge)
print()

-- Example 9: Demonstrating forward pass
print("9. Forward pass demonstration:")
local testMlp = nn.MLP(10, {20, 15}, 5)
local input = torch.randn(3, 10)  -- batch of 3 samples
print("   Input shape:", input:size(1), "x", input:size(2))
local output = testMlp:forward(input)
print("   Output shape:", output:size(1), "x", output:size(2))
print()

-- Example 10: Training vs Evaluation mode
print("10. Training vs Evaluation mode (with Dropout):")
local trainTestMlp = nn.MLP(10, {20}, 5, {dropout = 0.5})
local testInput = torch.ones(2, 10)

trainTestMlp:training()
local trainOut1 = trainTestMlp:forward(testInput):clone()
local trainOut2 = trainTestMlp:forward(testInput):clone()
print("   Training mode - outputs differ:", not torch.all(torch.eq(trainOut1, trainOut2)))

trainTestMlp:evaluate()
local evalOut1 = trainTestMlp:forward(testInput):clone()
local evalOut2 = trainTestMlp:forward(testInput):clone()
print("   Eval mode - outputs same:", torch.all(torch.eq(evalOut1, evalOut2)))
print()

-- Example 11: Different weight initializations
print("11. Available weight initialization methods:")
local initMethods = {'xavier', 'xavier_normal', 'he', 'he_normal', 'uniform', 'normal'}
for _, method in ipairs(initMethods) do
   local mlp = nn.MLP(10, {20}, 5, {weightInit = method})
   print("   -", method)
end
print()

-- Example 12: Getting configuration
print("12. Getting MLP configuration:")
local configMlp = nn.MLP(100, {200, 150}, 50, {
   activation = 'relu',
   dropout = 0.3
})
local config = configMlp:getConfig()
print("   Input size:", config.inputSize)
print("   Hidden sizes:", table.concat(config.hiddenSizes, ", "))
print("   Output size:", config.outputSize)
print("   Activation:", config.options.activation)
print("   Dropout:", config.options.dropout)
print()

-- Example 13: Parameter counting
print("13. Counting parameters:")
local countMlp = nn.MLP(10, {20, 15}, 5, {bias = true})
print("   With bias:", countMlp:countParams(), "parameters")

local countMlpNoBias = nn.MLP(10, {20, 15}, 5, {bias = false})
print("   Without bias:", countMlpNoBias:countParams(), "parameters")
print()

print("=== Examples Complete ===\n")

--[[
   Practical Use Cases:
   
   1. Image Classification:
      mlp = nn.MLP(784, {512, 256}, 10, {
         activation = 'relu',
         dropout = 0.5,
         batchNorm = true,
         outputActivation = 'logsoftmax'
      })
   
   2. Regression:
      mlp = nn.MLP(100, {200, 100, 50}, 1, {
         activation = 'relu',
         dropout = 0.2,
         weightInit = 'he'
      })
   
   3. Multi-label Classification:
      mlp = nn.MLP(50, {128, 64}, 20, {
         activation = 'relu',
         outputActivation = 'sigmoid'
      })
   
   4. Feature Extraction:
      mlp = nn.MLP(1000, {500, 250, 100}, 50, {
         activation = 'elu',
         batchNorm = true,
         dropout = 0.3
      })
   
   5. Autoencoder (encoder part):
      encoder = nn.MLP(784, {512, 256, 128}, 64, {
         activation = 'relu',
         batchNorm = true
      })
]]
