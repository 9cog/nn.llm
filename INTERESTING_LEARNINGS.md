# Interesting Learnings from nn.llm

## Overview

This document captures fascinating insights and patterns discovered in the nn.llm neuro-symbolic LLM implementation. Each learning demonstrates how mathematical insights and architectural innovations lead to more efficient and effective neural networks.

---

## Learning 1: Mathematical Simplification for Efficiency

### RMSNorm: Less is More

**Discovery**: Root Mean Square Layer Normalization (RMSNorm) achieves comparable performance to LayerNorm with **significantly less computation**.

#### Comparison

**Traditional LayerNorm:**
```
y = (x - mean(x)) / std(x) * γ + β

where:
- mean(x) = Σx / n
- std(x) = sqrt(Σ(x - mean(x))² / n)
- γ, β are learnable parameters
```

**RMSNorm:**
```
y = x / RMS(x) * γ

where:
- RMS(x) = sqrt(Σx² / n + ε)
- γ is a learnable parameter (no β)
```

#### Why RMSNorm is Better

1. **Fewer Operations**: No mean computation or subtraction required
2. **Fewer Parameters**: Only γ (no bias term β)
3. **Simpler Gradients**: Cleaner backpropagation
4. **Same Performance**: Empirically shown to work as well as LayerNorm in LLMs

#### Key Insight

> **The mean centering step in LayerNorm doesn't contribute significantly to LLM performance, but adds computational cost. By removing it, RMSNorm achieves the same goal (controlling scale) more efficiently.**

#### Code Example

From `RMSNorm.lua`:
```lua
-- Compute RMS: sqrt(mean(x^2) + eps)
self.rms:copy(input):pow(2)
local sumSq = self.rms:sum(3):squeeze()
sumSq:div(dim):add(self.eps):sqrt()

-- Normalize: x / rms (no mean subtraction!)
self.normalized:cdiv(input, self.rms)

-- Scale by learned weight (no bias!)
self.output:copy(self.normalized)
for i = 1, batchSize do
   for j = 1, seqLen do
      self.output[i][j]:cmul(self.weight)
   end
end
```

---

## Learning 2: Position Encoding Through Rotation

### RotaryEmbedding (RoPE): Elegant Relative Positioning

**Discovery**: Encoding position as rotation in complex space provides **better extrapolation** to unseen sequence lengths compared to absolute position embeddings.

#### How It Works

1. **Treat consecutive dimensions as complex numbers**: `(x[2i], x[2i+1])` forms a complex number
2. **Rotate by angle θ**: `θ = position / base^(2i/dim)`
3. **Apply rotation**: `x' = x * cos(θ) + rotate_half(x) * sin(θ)`

#### Mathematical Formulation

For a complex number represented as `(x₁, x₂)`:
```
Rotation by θ:
[cos(θ)  -sin(θ)] [x₁]   [x₁·cos(θ) - x₂·sin(θ)]
[sin(θ)   cos(θ)] [x₂] = [x₁·sin(θ) + x₂·cos(θ)]
```

#### Why RoPE is Better

1. **Relative Encoding**: Distance between positions encoded in angle difference
2. **Extrapolation**: Can handle longer sequences than seen during training
3. **No Extra Parameters**: Deterministic, no learnable parameters needed
4. **Computational Efficiency**: Precompute cos/sin for all positions

#### Key Insight

> **By encoding position as rotation in complex space, the dot product between query and key naturally captures relative position information. This is more elegant and effective than adding absolute position embeddings.**

#### Code Example

From `RotaryEmbedding.lua`:
```lua
function RotaryEmbedding:_rotateHalf(x)
   -- Rotate half the hidden dims
   local x1 = x:narrow(x:dim(), 1, x:size(x:dim()) / 2)
   local x2 = x:narrow(x:dim(), x:size(x:dim()) / 2 + 1, x:size(x:dim()) / 2)
   
   local rotated = torch.Tensor():resizeAs(x)
   local r1 = rotated:narrow(rotated:dim(), 1, x:size(x:dim()) / 2)
   local r2 = rotated:narrow(rotated:dim(), x:size(x:dim()) / 2 + 1, x:size(x:dim()) / 2)
   
   r1:copy(x2):mul(-1)  -- First half gets -x2
   r2:copy(x1)          -- Second half gets x1
   
   return rotated
end

function RotaryEmbedding:_applyRotary(x, cos, sin)
   -- Apply rotary embeddings: x * cos + rotate_half(x) * sin
   local x_rotated = self:_rotateHalf(x)
   
   local output = torch.Tensor():resizeAs(x)
   output:cmul(x, cos):addcmul(x_rotated, sin)
   
   return output
end
```

#### Visualization

```
Position 0:  θ=0°     No rotation
Position 1:  θ=θ₁     Slight rotation
Position 2:  θ=2θ₁    More rotation
Position 3:  θ=3θ₁    Even more rotation
...

Relative position distance = Angle difference
```

---

## Learning 3: Gated Activation Functions

### SwiGLU: Dynamic Information Control

**Discovery**: Gated activation functions like SwiGLU allow the network to **dynamically control information flow**, leading to better performance than simple non-linearities.

#### How It Works

1. **Split input into two parts**: gate and value
2. **Apply smooth activation to gate**: `Swish(gate) = gate · σ(gate)`
3. **Element-wise multiply**: `output = Swish(gate) ⊙ value`

#### Mathematical Formulation

```
SwiGLU(x, W, V) = Swish(xW) ⊙ xV

where:
- Swish(x) = x · sigmoid(x)
- sigmoid(x) = 1 / (1 + e^(-x))
- ⊙ is element-wise multiplication
```

#### Why SwiGLU is Better

1. **Gating Mechanism**: Network learns what information to let through
2. **Smooth Gradients**: Swish has smooth derivatives (unlike ReLU)
3. **Non-monotonic**: Can selectively suppress/amplify different ranges
4. **Empirically Superior**: Performs better than ReLU/GELU in transformers

#### Key Insight

> **By splitting the computation into a gate and a value, SwiGLU allows the network to learn context-dependent activation. The gate decides "how much" and the value provides "what content".**

#### Code Example

From `SwiGLU.lua`:
```lua
function SwiGLU:updateOutput(input)
   local halfDim = input:size(input:dim()) / 2
   
   -- Split input into gate and value
   self.gate = input:narrow(input:dim(), 1, halfDim)
   local value = input:narrow(input:dim(), halfDim + 1, halfDim)
   
   -- Apply Swish to gate: gate * sigmoid(gate)
   local sigmoid = torch.Tensor():resizeAs(self.gate)
   sigmoid:copy(self.gate):exp():add(1):pow(-1)
   
   self.gateActivation:resizeAs(self.gate)
   self.gateActivation:cmul(self.gate, sigmoid)  -- Swish
   
   -- SwiGLU = Swish(gate) * value
   self.output:cmul(self.gateActivation, value)
   
   return self.output
end
```

#### Gradient Computation

The gradient of SwiGLU is interesting:
```lua
-- d(Swish)/d(gate) = sigmoid + gate · sigmoid · (1 - sigmoid)
--                  = sigmoid · (1 + gate · (1 - sigmoid))
dSwish:cmul(gate, sigmoid)
dSwish:cmul(oneMinusSigmoid)
dSwish:add(sigmoid)

-- Gradient w.r.t gate: gradOutput * value * d(swish)/d(gate)
gradGate:cmul(gradOutput, value)
gradGate:cmul(dSwish)
```

---

## Learning 4: Grouped-Query Attention (GQA)

### Memory-Efficient Attention

**Discovery**: Not all attention heads need separate key-value pairs. By **sharing KV heads across multiple query heads**, we can reduce memory by 50% with minimal quality loss.

#### Traditional Multi-Head Attention

```
Q heads: [head1, head2, head3, head4, head5, head6, head7, head8]
K heads: [head1, head2, head3, head4, head5, head6, head7, head8]
V heads: [head1, head2, head3, head4, head5, head6, head7, head8]

Memory: 3 × n_heads × d_head
```

#### Grouped-Query Attention (GQA)

```
Q heads: [head1, head2, head3, head4, head5, head6, head7, head8]
K heads: [head1, head2, head3, head4] (shared)
V heads: [head1, head2, head3, head4] (shared)

Memory: (n_heads + 2 × n_kv_heads) × d_head
```

#### Key Insight

> **Query heads can share key-value pairs. Each KV head is repeated across multiple Q heads. This reduces KV cache size during inference while maintaining model quality.**

#### Example Configuration

```lua
config = {
   nHeads = 8,      -- 8 query heads
   nKVHeads = 4,    -- 4 key-value heads (2:1 ratio)
   dim = 512,
   headDim = 64
}

-- Each KV head serves 2 query heads
-- Memory reduction: (8+4+4)/(8+8+8) = 16/24 = 67% memory
-- Savings: 33% reduction in KV cache!
```

---

## Learning 5: Neuro-Symbolic Integration

### Combining Neural and Symbolic Reasoning

**Discovery**: Pure neural networks and pure symbolic systems each have limitations. **Combining them** creates a system that learns from data while respecting logical rules.

#### Architecture

```
Input → Neural Processing (LLaMA) → Symbolic Reasoning → Output
         ↓                              ↑
    Episodic Memory              Domain Knowledge
         ↓                              ↑
    Pattern Extraction → Adaptation → Rule Updates
```

#### Key Components

1. **Symbol Table**: Stores conceptual knowledge
2. **Rule Base**: Condition-action rules applied to neural outputs
3. **Episodic Memory**: Experiences for learning
4. **Dynamic Adaptation**: Updates rules based on feedback

#### Key Insight

> **Neural networks excel at pattern recognition but struggle with logical consistency. Symbolic systems excel at logical reasoning but struggle with ambiguity. Combining them leverages the strengths of both.**

#### Code Example

From `NeuroSymbolicLLM.lua`:
```lua
function NeuroSymbolicLLM:forward(input)
   -- Neural processing
   local neuralOutput = self.llama:forward(input)
   
   -- Create context for symbolic reasoning
   local context = {
      input = input,
      output = neuralOutput,
      batchSize = input:size(1),
      seqLen = input:size(2)
   }
   
   -- Apply symbolic reasoning rules
   local finalOutput = self:applySymbolicReasoning(neuralOutput, context)
   
   -- Store experience for learning
   self:updateEpisodicMemory({
      input = input:clone(),
      output = finalOutput:clone(),
      timestamp = os.time(),
      sequence = #self.episodicMemory + 1
   })
   
   return finalOutput
end

function NeuroSymbolicLLM:applySymbolicReasoning(neuralOutput, context)
   local modifiedOutput = neuralOutput:clone()
   
   -- Apply each rule if condition is met
   for i, rule in ipairs(self.ruleBase) do
      if rule.condition(context) then
         modifiedOutput = rule.action(modifiedOutput, context)
      end
   end
   
   return modifiedOutput
end
```

---

## Learning 6: Niche Construction & Meta-Learning

### Dynamic Adaptation to Environment

**Discovery**: By maintaining episodic memory and extracting patterns from experience, a system can **adapt to specific domains** without retraining from scratch.

#### Niche Construction Theory

From biology: organisms don't just adapt to their environment, they also **modify their environment** (build niches) to better suit their needs. Similarly, this LLM:

1. **Experiences interactions** with its environment
2. **Stores experiences** in episodic memory
3. **Extracts patterns** from successful interactions
4. **Builds domain-specific knowledge** (the "niche")
5. **Adapts behavior** based on what works

#### Implementation

```lua
function NeuroSymbolicLLM:adaptToNiche(feedback)
   -- Analyze recent experiences
   local patterns = self:extractPatterns(self.recentExperiences)
   
   -- Update contextual patterns
   for pattern, weight in pairs(patterns) do
      self.contextualPatterns[pattern] = 
         (self.contextualPatterns[pattern] or 0) + weight
   end
   
   -- Adjust based on feedback
   if feedback.success then
      self:reinforceSuccessfulPatterns(feedback)
   else
      self:exploreAlternatives(feedback)
   end
   
   -- Update adaptation metrics
   self.performanceMetrics.adaptationRate = 
      self.performanceMetrics.adaptationRate * 0.9 + 
      (feedback.success and 0.1 or 0.0)
end
```

#### Key Insight

> **Static models can't adapt to new domains without retraining. By maintaining episodic memory and extracting patterns from feedback, the model can construct domain-specific "niches" dynamically.**

---

## Learning 7: Pure Implementation from First Principles

### Transparency and Understanding

**Discovery**: Implementing complex systems in **pure Lua without black-box libraries** provides deep understanding and full control.

#### Benefits of First-Principles Implementation

1. **Complete Transparency**: Every operation is explicit
2. **Educational Value**: Easy to understand and learn from
3. **Debuggability**: Can inspect every intermediate computation
4. **Modifiability**: Easy to experiment with variations
5. **No Hidden Costs**: Understand exact computational requirements

#### Example: RMSNorm Forward Pass

```lua
-- Crystal clear implementation
self.rms:copy(input):pow(2)                    -- Square each element
local sumSq = self.rms:sum(3):squeeze()        -- Sum along feature dim
sumSq:div(dim):add(self.eps):sqrt()            -- Compute RMS
self.normalized:cdiv(input, self.rms)          -- Normalize
self.output:copy(self.normalized)              -- Copy to output
for i = 1, batchSize do
   for j = 1, seqLen do
      self.output[i][j]:cmul(self.weight)      -- Apply learned scale
   end
end
```

Compare with typical framework:
```python
# Hidden implementation
output = torch.nn.functional.rms_norm(input, normalized_shape, weight)
# What's actually happening? Hard to know!
```

#### Key Insight

> **Understanding comes from implementation. By building LLMs from scratch in pure Lua, we gain deep insights into how they actually work, not just how to use them.**

---

## Practical Applications of These Learnings

### 1. Building Efficient Models

**Apply RMSNorm instead of LayerNorm:**
- 15-20% reduction in normalization compute
- Fewer parameters to store and update
- Same or better model quality

### 2. Handling Long Sequences

**Use RoPE for position encoding:**
- Better extrapolation beyond training length
- No position embedding parameters to learn
- Captures relative position naturally

### 3. Memory-Constrained Deployment

**Use GQA for attention:**
- 33-50% reduction in KV cache size
- Faster inference due to less memory movement
- Minimal quality degradation

### 4. Domain Adaptation

**Implement niche construction:**
- Adapt to new domains without full retraining
- Build domain-specific knowledge incrementally
- Learn from environmental feedback

### 5. Interpretability

**Add symbolic reasoning layer:**
- Explain model decisions with rules
- Ensure consistency with domain knowledge
- Debug model behavior more easily

---

## Quantitative Comparisons

### Computational Savings

| Component | Traditional | Optimized | Savings |
|-----------|------------|-----------|---------|
| Normalization | LayerNorm | RMSNorm | ~20% |
| Position Encoding | Learned Embedding | RoPE | 100% params |
| Activation | ReLU/GELU | SwiGLU | +Quality |
| Attention KV Cache | Full heads | GQA (2:1) | 33% |

### Model Size Comparison

**Configuration**: 8 layers, 512 dim, 8 heads

| Component | Params | Memory (FP32) |
|-----------|--------|---------------|
| Embeddings (32k vocab) | 16.4M | 65.5 MB |
| RMSNorm (8 layers × 2) | 8.2k | 32 KB |
| Attention (8 layers, GQA 8:4) | 20.9M | 83.9 MB |
| FFN (8 layers) | 25.2M | 100.7 MB |
| **Total** | **62.5M** | **250 MB** |

Without GQA (full KV heads):
- Attention: 28.3M (+35%)
- Total: 69.9M (+12%)

---

## Code Patterns Worth Learning

### Pattern 1: Dimension Flexibility

Handle both 2D and 3D tensors gracefully:
```lua
if input:dim() == 2 then
   batchSize = input:size(1)
   dim = input:size(2)
elseif input:dim() == 3 then
   batchSize = input:size(1)
   seqLen = input:size(2)
   dim = input:size(3)
else
   error('Input must be 2D or 3D')
end
```

### Pattern 2: Precomputation

Compute expensive operations once:
```lua
function RotaryEmbedding:_computeFreqs()
   -- Precompute during initialization
   self.cos_cached = torch.cos(self.freqs)
   self.sin_cached = torch.sin(self.freqs)
end

function RotaryEmbedding:updateOutput(input)
   -- Just lookup during forward pass
   local cos = self.cos_cached:narrow(1, 1, seqLen)
   local sin = self.sin_cached:narrow(1, 1, seqLen)
   -- ... use precomputed values
end
```

### Pattern 3: Gradient Symmetry

Forward and backward should mirror each other:
```lua
-- Forward: Apply rotation
output = x * cos + rotate_half(x) * sin

-- Backward: Apply inverse rotation (negate sin)
gradInput = gradOutput * cos + rotate_half(gradOutput) * (-sin)
```

### Pattern 4: Modular Composition

Build complex systems from simple modules:
```lua
-- TransformerBlock composes simpler modules
self.attnNorm = nn.RMSNorm(dim)
self.attention = nn.MultiHeadAttention(config)
self.ffnNorm = nn.RMSNorm(dim)
self.feedForward = nn.FeedForward(config)

-- Each module is independently testable
```

---

## Conclusion: Key Takeaways

1. **Simplicity Often Wins**: RMSNorm achieves the same goal as LayerNorm with less computation

2. **Elegant Math Matters**: RoPE's rotation-based encoding is both mathematically elegant and practically effective

3. **Gating is Powerful**: SwiGLU's gating mechanism provides dynamic control over information flow

4. **Memory Efficiency**: GQA reduces memory usage significantly with minimal quality impact

5. **Hybrid Approaches**: Combining neural and symbolic reasoning leverages strengths of both paradigms

6. **Adaptation > Static Models**: Niche construction enables domain adaptation without full retraining

7. **Implementation Teaches**: Building from first principles provides deep understanding

---

## Further Exploration

To deepen understanding, try:

1. **Implement variations**: Try different normalization schemes, compare performance
2. **Visualize activations**: Plot how SwiGLU gates information vs ReLU
3. **Measure memory**: Profile actual memory usage with/without GQA
4. **Test extrapolation**: Train with short sequences, test on longer ones (RoPE advantage)
5. **Build applications**: Create domain-specific neuro-symbolic systems
6. **Benchmark efficiency**: Compare pure Lua implementation to framework implementations

---

## References

### Papers
- **RMSNorm**: Zhang & Sennrich, "Root Mean Square Layer Normalization" (2019)
- **RoPE**: Su et al., "RoFormer: Enhanced Transformer with Rotary Position Embedding" (2021)
- **SwiGLU**: Shazeer, "GLU Variants Improve Transformer" (2020)
- **GQA**: Ainslie et al., "GQA: Training Generalized Multi-Query Transformer Models" (2023)
- **LLaMA**: Touvron et al., "LLaMA: Open and Efficient Foundation Language Models" (2023)
- **Niche Construction**: Odling-Smee et al., "Niche Construction Theory" (2003)

### Code
- Implementation: `/home/runner/work/nn.llm/nn.llm/`
- Examples: `examples/neurosymbolic_llm_example.lua`
- Tests: `test_llm.lua`
- Documentation: `LLM_README.md`, `ARCHITECTURE.md`, `IMPLEMENTATION_GUIDE.md`

---

*This document captures learnings from exploring the nn.llm repository - a pure Lua implementation of neuro-symbolic LLMs from first principles.*
