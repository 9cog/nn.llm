# nn.MLP - Multi-Layer Perceptron Module

## Overview

The `nn.MLP` module provides a comprehensive, configurable implementation of a Multi-Layer Perceptron (fully-connected feedforward neural network). It's built on top of `nn.Sequential` and offers a high-level interface for creating flexible neural network architectures.

## Features

- ✅ **Configurable Architecture**: Specify any number of hidden layers with custom sizes
- ✅ **Multiple Activation Functions**: Support for ReLU, Tanh, Sigmoid, LeakyReLU, ELU, and more
- ✅ **Regularization**: Built-in Dropout support
- ✅ **Normalization**: Optional Batch Normalization
- ✅ **Weight Initialization**: Multiple strategies (Xavier, He, uniform, normal)
- ✅ **Flexible Output**: Optional output activation or linear output for regression
- ✅ **Mode Switching**: Easy training/evaluation mode transitions
- ✅ **Preset Configurations**: Quick setup for common architectures

## Basic Usage

```lua
require 'nn'

-- Create a simple 3-layer MLP: 784 -> 256 -> 128 -> 10
local mlp = nn.MLP(784, {256, 128}, 10, {
   activation = 'relu',
   outputActivation = 'logsoftmax'
})

-- Forward pass
local input = torch.randn(32, 784)  -- batch of 32
local output = mlp:forward(input)   -- 32 x 10

-- Backward pass
local gradOutput = torch.randn(32, 10)
local gradInput = mlp:backward(input, gradOutput)
```

## Constructor

```lua
nn.MLP(inputSize, hiddenSizes, outputSize [, options])
```

### Parameters

- **`inputSize`** (number): Number of input features
- **`hiddenSizes`** (table): Array of hidden layer sizes, e.g., `{128, 64, 32}`
- **`outputSize`** (number): Number of output units
- **`options`** (table, optional): Configuration options

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `activation` | string | `'relu'` | Activation function for hidden layers |
| `outputActivation` | string | `nil` | Activation function for output layer (nil = linear) |
| `dropout` | number | `0.0` | Dropout probability (0 to 1) |
| `batchNorm` | boolean | `false` | Whether to use batch normalization |
| `bias` | boolean | `true` | Whether to include bias in linear layers |
| `weightInit` | string | `'xavier'` | Weight initialization method |

## Supported Activations

### Hidden Layer Activations
- `'relu'` - Rectified Linear Unit (default)
- `'tanh'` - Hyperbolic Tangent
- `'sigmoid'` - Sigmoid
- `'leakyrelu'` - Leaky ReLU
- `'elu'` - Exponential Linear Unit
- `'prelu'` - Parametric ReLU
- `'rrelu'` - Randomized ReLU
- `'relu6'` - ReLU capped at 6
- `'softsign'` - Softsign
- `'softplus'` - Softplus
- `'hardtanh'` - Hard Tanh

### Output Layer Activations
- `nil` - No activation (linear output, for regression)
- `'sigmoid'` - Binary classification
- `'tanh'` - Bounded output [-1, 1]
- `'softmax'` - Multi-class classification (probabilities)
- `'logsoftmax'` - Log probabilities (for NLL loss)

## Weight Initialization Methods

- `'xavier'` or `'xavier_uniform'` - Xavier/Glorot uniform initialization
- `'xavier_normal'` - Xavier/Glorot normal initialization
- `'he'` or `'he_uniform'` - He/Kaiming uniform (recommended for ReLU)
- `'he_normal'` or `'kaiming_normal'` - He/Kaiming normal (recommended for ReLU)
- `'uniform'` - Simple uniform initialization
- `'normal'` - Simple normal initialization

## Methods

### forward(input)
Forward pass through the network.

```lua
local output = mlp:forward(input)
```

### backward(input, gradOutput [, scale])
Backward pass computing gradients.

```lua
local gradInput = mlp:backward(input, gradOutput)
```

### training()
Switch to training mode (enables dropout, batch norm tracking).

```lua
mlp:training()
```

### evaluate()
Switch to evaluation mode (disables dropout, uses batch norm statistics).

```lua
mlp:evaluate()
```

### reset()
Re-initialize all weights using the specified initialization method.

```lua
mlp:reset()
```

### countParams()
Count total number of trainable parameters.

```lua
local numParams = mlp:countParams()
print('Total parameters:', numParams)
```

### getConfig()
Get the configuration used to create the MLP.

```lua
local config = mlp:getConfig()
-- Returns: {inputSize, hiddenSizes, outputSize, options}
```

## Examples

### Example 1: Image Classification (MNIST)

```lua
-- 784 input features (28x28 image)
-- Hidden layers: 256, 128
-- 10 output classes
local mnist_mlp = nn.MLP(784, {256, 128}, 10, {
   activation = 'relu',
   dropout = 0.5,
   batchNorm = true,
   outputActivation = 'logsoftmax'
})
```

### Example 2: Binary Classification

```lua
local binary_mlp = nn.MLP(100, {64, 32}, 1, {
   activation = 'relu',
   outputActivation = 'sigmoid',
   dropout = 0.3
})
```

### Example 3: Regression

```lua
local regression_mlp = nn.MLP(50, {128, 64, 32}, 1, {
   activation = 'elu',
   dropout = 0.2,
   weightInit = 'he'
   -- No output activation for regression
})
```

### Example 4: Deep Network

```lua
local deep_mlp = nn.MLP(1000, {512, 256, 128, 64}, 10, {
   activation = 'relu',
   dropout = 0.4,
   batchNorm = true,
   weightInit = 'he_normal',
   outputActivation = 'softmax'
})
```

### Example 5: Using Preset Configurations

```lua
-- Small network (2 hidden layers)
local small_constructor = nn.MLP.create('small')
local small_mlp = small_constructor(784, 10)

-- Medium network (3 hidden layers)
local medium_constructor = nn.MLP.create('medium')
local medium_mlp = medium_constructor(784, 10)

-- Large network (4 hidden layers)
local large_constructor = nn.MLP.create('large')
local large_mlp = large_constructor(784, 10)
```

## Training Example

```lua
require 'nn'
require 'optim'

-- Create model
local model = nn.MLP(784, {256, 128}, 10, {
   activation = 'relu',
   dropout = 0.5,
   outputActivation = 'logsoftmax'
})

-- Loss function
local criterion = nn.ClassNLLCriterion()

-- Get parameters
local params, gradParams = model:getParameters()

-- Training function
local function train(input, target)
   model:training()
   
   -- Forward pass
   local output = model:forward(input)
   local loss = criterion:forward(output, target)
   
   -- Backward pass
   model:zeroGradParameters()
   local gradOutput = criterion:backward(output, target)
   model:backward(input, gradOutput)
   
   return loss
end

-- Evaluation function
local function evaluate(input, target)
   model:evaluate()
   
   local output = model:forward(input)
   local loss = criterion:forward(output, target)
   
   return loss
end

-- Training loop
for epoch = 1, 10 do
   local loss = train(trainInput, trainTarget)
   print(string.format('Epoch %d: loss = %.4f', epoch, loss))
end
```

## Comparison with Sequential

While you can build an MLP manually using `nn.Sequential`, `nn.MLP` provides:

1. **Convenience**: One-line creation vs. multiple `add()` calls
2. **Consistency**: Ensures proper layer ordering (Linear -> BatchNorm -> Activation -> Dropout)
3. **Configuration**: Easy experimentation with different architectures
4. **Initialization**: Automatic weight initialization with multiple strategies
5. **Documentation**: Self-documenting architecture via `__tostring__`

### Manual Sequential equivalent:

```lua
-- Manual way (verbose)
local manual = nn.Sequential()
manual:add(nn.Linear(784, 256))
manual:add(nn.BatchNormalization(256))
manual:add(nn.ReLU(true))
manual:add(nn.Dropout(0.5))
manual:add(nn.Linear(256, 128))
manual:add(nn.BatchNormalization(128))
manual:add(nn.ReLU(true))
manual:add(nn.Dropout(0.5))
manual:add(nn.Linear(128, 10))
manual:add(nn.LogSoftMax())

-- vs. MLP way (concise)
local mlp = nn.MLP(784, {256, 128}, 10, {
   activation = 'relu',
   dropout = 0.5,
   batchNorm = true,
   outputActivation = 'logsoftmax'
})
```

## Architecture Details

The MLP module follows this layer structure:

```
For each hidden layer:
  1. Linear transformation
  2. Batch Normalization (if enabled)
  3. Activation function
  4. Dropout (if enabled)

For output layer:
  1. Linear transformation
  2. Output activation (if specified)
```

This ordering follows best practices:
- BatchNorm before activation (though both orders work)
- Dropout after activation

## Performance Considerations

1. **Batch Normalization**: Adds computational overhead but can speed up training
2. **Dropout**: Slows training but improves generalization
3. **Deep Networks**: Consider using skip connections (ResNet-style) for very deep networks
4. **Weight Initialization**: He initialization recommended for ReLU, Xavier for Tanh/Sigmoid

## Tips and Best Practices

1. **Start Simple**: Begin with a small network and increase complexity as needed
2. **ReLU Family**: Use ReLU or its variants (LeakyReLU, ELU) for hidden layers
3. **Dropout Rate**: 0.2-0.5 is typically effective; higher for larger networks
4. **Batch Normalization**: Often eliminates need for high dropout rates
5. **Weight Init**: Use He init with ReLU, Xavier with Tanh/Sigmoid
6. **Output Activation**: 
   - Classification: use LogSoftMax with ClassNLLCriterion
   - Binary: use Sigmoid with BCECriterion
   - Regression: use no activation with MSECriterion

## Troubleshooting

### Problem: Network not learning
- Check learning rate (too high or too low)
- Verify loss function matches output activation
- Try different weight initialization
- Reduce dropout rate

### Problem: Overfitting
- Increase dropout rate
- Add batch normalization
- Reduce network size
- Add L2 regularization

### Problem: Underfitting
- Increase network size (more/wider layers)
- Reduce dropout
- Train longer
- Check data preprocessing

## See Also

- [nn.Sequential](http://github.com/torch/nn/blob/master/doc/containers.md#nn.Sequential)
- [nn.Linear](http://github.com/torch/nn/blob/master/doc/simple.md#nn.Linear)
- [nn.Dropout](http://github.com/torch/nn/blob/master/doc/simple.md#nn.Dropout)
- [nn.BatchNormalization](http://github.com/torch/nn/blob/master/doc/simple.md#nn.BatchNormalization)
- [Transfer Functions](http://github.com/torch/nn/blob/master/doc/transfer.md)
