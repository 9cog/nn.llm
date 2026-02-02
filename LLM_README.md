# Neuro-Symbolic LLM Implementation

This module implements **llama.cpp LLM functionality in pure Lua** as a derived neuro-symbolic neural network from first principles, enabling **dynamic learning for niche construction**.

## Overview

This implementation combines:
- **Neural Architecture**: Full LLaMA transformer model with:
  - Multi-head attention with Grouped-Query Attention (GQA)
  - Rotary Position Embeddings (RoPE)
  - RMSNorm layer normalization
  - SwiGLU activation functions
  - Feed-forward networks
  
- **Symbolic Reasoning**: 
  - Symbol table for storing conceptual knowledge
  - Rule-based reasoning system
  - Context-aware pattern matching
  
- **Dynamic Learning**:
  - Episodic memory for experience storage
  - Niche construction through adaptive learning
  - Meta-learning for domain adaptation
  - Performance-based reinforcement

## Architecture Components

### Core Modules

1. **RMSNorm** (`RMSNorm.lua`)
   - Root Mean Square Layer Normalization
   - More efficient than LayerNorm (no mean centering)
   - Used throughout LLaMA architecture

2. **RotaryEmbedding** (`RotaryEmbedding.lua`)
   - Rotary Position Embeddings (RoPE)
   - Relative position encoding
   - Applied to Query and Key vectors

3. **SwiGLU** (`SwiGLU.lua`)
   - Swish-Gated Linear Unit activation
   - Used in feed-forward networks
   - Better performance than standard ReLU

4. **MultiHeadAttention** (`MultiHeadAttention.lua`)
   - Multi-head self-attention mechanism
   - Grouped-Query Attention (GQA) support
   - Fewer KV heads for efficiency
   - Causal masking for autoregressive generation

5. **FeedForward** (`FeedForward.lua`)
   - Feed-forward network with SwiGLU
   - Three-layer projection (gate, value, output)
   - Dropout for regularization

6. **TransformerBlock** (`TransformerBlock.lua`)
   - Complete transformer layer
   - Pre-normalization architecture
   - Residual connections
   - Combines attention and feed-forward

7. **LLaMA** (`LLaMA.lua`)
   - Full LLaMA language model
   - Token embeddings
   - Stack of transformer blocks
   - Output projection with optional weight tying
   - Text generation capabilities

8. **NeuroSymbolicLLM** (`NeuroSymbolicLLM.lua`)
   - Wrapper combining neural and symbolic processing
   - Symbolic knowledge base
   - Rule-based reasoning
   - Dynamic niche construction
   - Episodic memory system
   - Adaptive learning mechanisms

## Usage

### Basic Example

```lua
require 'nn'

-- Create configuration
local config = {
   vocabSize = 32000,
   dim = 512,
   nLayers = 8,
   nHeads = 8,
   nKVHeads = 4,  -- GQA: half the query heads
   hiddenDim = 2048,
   maxSeqLen = 2048,
   dropout = 0.1,
   tieWeights = true,
   
   -- Neuro-symbolic parameters
   nicheAdaptation = true,
   learningRate = 0.01,
   memorySize = 1000
}

-- Create model
local model = nn.NeuroSymbolicLLM(config)

-- Add symbolic knowledge
model:addSymbol('greeting', {type = 'social', tokens = {...}})

-- Add reasoning rules
model:addSymbolicRule({
   condition = function(ctx) return ctx.input:size(2) < 10 end,
   action = function(out, ctx) return out:mul(1.1) end,
   weight = 1.0
})

-- Forward pass
local input = torch.LongTensor(2, 128):random(1, config.vocabSize)
local output = model:forward(input)

-- Generate text
local tokens = torch.LongTensor(1, 5):random(1, config.vocabSize)
local generated = model:generate(tokens, 50, 1.0)

-- Adapt to environment feedback
model:adaptToNiche({
   success = true,
   context = 'conversation',
   pattern = 'greeting_response'
})

-- Get adaptation metrics
local metrics = model:getAdaptationMetrics()
print(metrics)
```

### Running the Example

```bash
th examples/neurosymbolic_llm_example.lua
```

## Key Features

### 1. Pure Lua Implementation
- No external dependencies (except Torch)
- Fully transparent and modifiable
- Educational and research-friendly

### 2. LLaMA Architecture
- State-of-the-art transformer design
- Efficient grouped-query attention
- Rotary position embeddings
- RMSNorm for stability

### 3. Neuro-Symbolic Integration
- Seamless combination of neural and symbolic processing
- Rule-based reasoning over neural outputs
- Symbolic knowledge representation

### 4. Dynamic Learning
- **Episodic Memory**: Stores experiences for learning
- **Niche Construction**: Adapts to specific domains/tasks
- **Meta-Learning**: Learns how to learn
- **Pattern Extraction**: Identifies successful strategies
- **Context Adaptation**: Adjusts to different situations

### 5. Extensibility
- Modular design allows easy customization
- Add custom symbolic rules
- Extend reasoning capabilities
- Modify neural architecture

## Dynamic Learning & Niche Construction

The model implements **niche construction** - the process by which organisms modify their environment and adapt to it. In this context:

1. **Experience Collection**: The model stores interactions in episodic memory
2. **Pattern Recognition**: Successful patterns are identified and reinforced
3. **Domain Adaptation**: The model builds domain-specific knowledge
4. **Strategy Exploration**: Failed approaches trigger alternative strategies
5. **Continuous Learning**: The model continuously adapts to new contexts

### Adaptation API

```lua
-- Provide feedback for learning
model:adaptToNiche({
   success = boolean,      -- Was the action successful?
   context = string,       -- What context/domain?
   pattern = string,       -- What pattern was used?
   confidence = number     -- How confident (0-1)?
})

-- Query adaptation state
local metrics = model:getAdaptationMetrics()
-- Returns:
-- {
--    episodicMemorySize = number,
--    recentExperiences = number,
--    numSymbols = number,
--    numRules = number,
--    numContexts = number,
--    adaptationRate = number
-- }

-- Save/load learned knowledge
model:saveKnowledge('knowledge.t7')
model:loadKnowledge('knowledge.t7')
```

## Technical Details

### Grouped-Query Attention (GQA)
- Reduces KV cache size for efficient inference
- Multiple query heads share KV heads
- Example: 8 query heads, 4 KV heads (2:1 ratio)

### Rotary Position Embeddings
- Relative position encoding
- Applied through complex number rotation
- Better extrapolation to longer sequences

### RMSNorm vs LayerNorm
- RMSNorm: `y = x / RMS(x) * γ`
- LayerNorm: `y = (x - mean(x)) / std(x) * γ + β`
- RMSNorm is simpler and faster

### SwiGLU Activation
- `SwiGLU(x, W, V) = Swish(xW) ⊗ xV`
- `Swish(x) = x · sigmoid(x)`
- Empirically better than ReLU/GELU

## Model Configuration

Recommended configurations for different scales:

### Tiny (for testing)
```lua
{vocabSize=1000, dim=128, nLayers=4, nHeads=4, nKVHeads=2}
```

### Small
```lua
{vocabSize=32000, dim=512, nLayers=8, nHeads=8, nKVHeads=4}
```

### Medium
```lua
{vocabSize=32000, dim=1024, nLayers=16, nHeads=16, nKVHeads=8}
```

### Large
```lua
{vocabSize=32000, dim=2048, nLayers=24, nHeads=32, nKVHeads=8}
```

## Limitations & Future Work

Current implementation limitations:
- Simplified backward pass (training needs full backprop)
- Basic generation (greedy decoding)
- No KV caching yet (for efficient inference)
- Symbolic reasoning is demonstrative (can be extended)

Future enhancements:
- Full training implementation with optimizers
- Advanced sampling (top-p, top-k, beam search)
- KV cache for faster generation
- More sophisticated symbolic reasoning
- Multi-modal capabilities
- Distributed training support

## References

- **LLaMA**: Touvron et al., "LLaMA: Open and Efficient Foundation Language Models" (2023)
- **GQA**: Ainslie et al., "GQA: Training Generalized Multi-Query Transformer Models" (2023)
- **RoPE**: Su et al., "RoFormer: Enhanced Transformer with Rotary Position Embedding" (2021)
- **SwiGLU**: Shazeer, "GLU Variants Improve Transformer" (2020)
- **Niche Construction**: Odling-Smee et al., "Niche Construction: The Neglected Process in Evolution" (2003)

## License

This implementation follows the same license as the nn package (BSD).
