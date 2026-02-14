# nn.MLP Quick Start Guide

## What is MLP?

MLP (Multi-Layer Perceptron) is a comprehensive module for building fully-connected feedforward neural networks with just one line of code.

## Quick Examples

### 1. Simple Classification Network

```lua
require 'nn'

-- Create: 784 inputs -> 256 hidden -> 128 hidden -> 10 outputs
mlp = nn.MLP(784, {256, 128}, 10, {
   activation = 'relu',
   outputActivation = 'logsoftmax'
})

-- Use it
input = torch.randn(32, 784)  -- batch of 32 images
output = mlp:forward(input)    -- 32 x 10 predictions
```

### 2. With Dropout and Batch Normalization

```lua
mlp = nn.MLP(100, {200, 100}, 10, {
   activation = 'relu',
   dropout = 0.5,           -- 50% dropout
   batchNorm = true,        -- add batch normalization
   outputActivation = 'softmax'
})
```

### 3. Regression Network

```lua
-- No output activation for regression
mlp = nn.MLP(50, {128, 64}, 1, {
   activation = 'relu',
   dropout = 0.2
})
```

### 4. Quick Presets

```lua
-- Small network (2 layers: 128, 64)
mlp = nn.MLP.create('small')(784, 10)

-- Medium network (3 layers: 512, 256, 128)
mlp = nn.MLP.create('medium')(784, 10)

-- Large network (4 layers: 1024, 512, 256, 128)
mlp = nn.MLP.create('large')(784, 10)
```

## Architecture Overview

```
MLP Structure:
--------------
Input Layer
    ↓
[Linear Transform]
[Batch Normalization] (optional)
[Activation Function]
[Dropout] (optional)
    ↓
... (repeat for each hidden layer)
    ↓
[Linear Transform]
[Output Activation] (optional)
    ↓
Output Layer
```

## Configuration Options

| Option | Values | Default | Purpose |
|--------|--------|---------|---------|
| `activation` | 'relu', 'tanh', 'sigmoid', 'elu', etc. | 'relu' | Hidden layer activation |
| `outputActivation` | 'softmax', 'sigmoid', 'tanh', nil | nil | Output activation |
| `dropout` | 0.0 to 1.0 | 0.0 | Dropout probability |
| `batchNorm` | true/false | false | Use batch normalization |
| `weightInit` | 'xavier', 'he', 'uniform', 'normal' | 'xavier' | Weight initialization |
| `bias` | true/false | true | Use bias in layers |

## Activation Functions

**For Hidden Layers:**
- `'relu'` - Best for most cases (default)
- `'elu'` - Smooth alternative to ReLU
- `'leakyrelu'` - ReLU with small negative slope
- `'tanh'` - Classic, bounded [-1, 1]
- `'sigmoid'` - Bounded [0, 1]

**For Output Layer:**
- `nil` - Linear (regression)
- `'softmax'` - Multi-class classification (probabilities)
- `'logsoftmax'` - Multi-class (with NLL loss)
- `'sigmoid'` - Binary classification

## Common Use Cases

### MNIST Classification

```lua
mlp = nn.MLP(784, {256, 128}, 10, {
   activation = 'relu',
   dropout = 0.5,
   batchNorm = true,
   weightInit = 'he',
   outputActivation = 'logsoftmax'
})
criterion = nn.ClassNLLCriterion()
```

### Binary Classification

```lua
mlp = nn.MLP(100, {64, 32}, 1, {
   activation = 'relu',
   outputActivation = 'sigmoid'
})
criterion = nn.BCECriterion()
```

### Regression

```lua
mlp = nn.MLP(50, {128, 64, 32}, 1, {
   activation = 'relu',
   dropout = 0.2,
   weightInit = 'he'
   -- No output activation
})
criterion = nn.MSECriterion()
```

### Feature Extraction

```lua
mlp = nn.MLP(2048, {512, 256}, 128, {
   activation = 'elu',
   batchNorm = true,
   dropout = 0.3
})
```

## Training Example

```lua
require 'nn'

-- Create model
model = nn.MLP(784, {256, 128}, 10, {
   activation = 'relu',
   dropout = 0.5,
   outputActivation = 'logsoftmax'
})

-- Loss function
criterion = nn.ClassNLLCriterion()

-- Training mode
model:training()

-- Training loop
for epoch = 1, 10 do
   -- Forward
   output = model:forward(trainInput)
   loss = criterion:forward(output, trainTarget)
   
   -- Backward
   model:zeroGradParameters()
   gradOutput = criterion:backward(output, trainTarget)
   model:backward(trainInput, gradOutput)
   
   -- Update (with learning rate)
   model:updateParameters(0.01)
   
   print('Epoch ' .. epoch .. ': loss = ' .. loss)
end

-- Evaluation mode
model:evaluate()
testOutput = model:forward(testInput)
```

## Tips

1. **Start simple**: Begin with 1-2 hidden layers
2. **ReLU is good**: Use ReLU or ELU for hidden layers
3. **Dropout helps**: 0.2-0.5 prevents overfitting
4. **He init for ReLU**: Use `weightInit='he'` with ReLU
5. **BatchNorm is powerful**: Often better than high dropout
6. **Match loss to output**: 
   - LogSoftMax → ClassNLLCriterion
   - Sigmoid → BCECriterion
   - Linear → MSECriterion

## Comparison

**Before (manual):**
```lua
model = nn.Sequential()
model:add(nn.Linear(784, 256))
model:add(nn.ReLU(true))
model:add(nn.Dropout(0.5))
model:add(nn.Linear(256, 128))
model:add(nn.ReLU(true))
model:add(nn.Dropout(0.5))
model:add(nn.Linear(128, 10))
model:add(nn.LogSoftMax())
```

**After (MLP):**
```lua
model = nn.MLP(784, {256, 128}, 10, {
   activation = 'relu',
   dropout = 0.5,
   outputActivation = 'logsoftmax'
})
```

## More Information

- Full documentation: [doc/MLP.md](../doc/MLP.md)
- Examples: [examples/mlp_example.lua](../examples/mlp_example.lua)
- Tests: [test_mlp.lua](../test_mlp.lua)

## Summary

The `nn.MLP` module makes it easy to create flexible, powerful feedforward neural networks with comprehensive features like dropout, batch normalization, and multiple activation functions - all with a simple, clean API.
