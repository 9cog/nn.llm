# Quick Reference: Key Learnings from nn.llm

*A concise guide to the most interesting insights from the neuro-symbolic LLM implementation*

---

## 🎯 Top 7 Learnings

### 1. RMSNorm: Less is More
```
❌ LayerNorm: y = (x - mean(x)) / std(x) * γ + β
✅ RMSNorm:   y = x / RMS(x) * γ

Savings: ~20% compute, 50% parameters, same performance
```

### 2. RoPE: Position as Rotation
```
Traditional: Add position embeddings
RoPE:       Rotate queries/keys by position-dependent angle

Benefit: Better extrapolation to longer sequences
```

### 3. SwiGLU: Dynamic Gating
```
ReLU:    max(0, x)
SwiGLU:  Swish(gate) ⊙ value
         where Swish(x) = x · sigmoid(x)

Benefit: Network learns what information to pass through
```

### 4. GQA: Share KV Heads
```
Traditional: 8 Q heads, 8 K heads, 8 V heads
GQA:        8 Q heads, 4 K heads, 4 V heads (shared)

Savings: 33% KV cache memory, minimal quality loss
```

### 5. Neuro-Symbolic: Best of Both Worlds
```
Neural:   Pattern learning + Ambiguity handling
Symbolic: Logical rules + Interpretability
Combined: Learning + Logic + Transparency
```

### 6. Niche Construction: Adapt Without Retraining
```
1. Store experiences in episodic memory
2. Extract patterns from successful interactions
3. Build domain-specific knowledge
4. Adapt behavior based on feedback

Result: Domain adaptation without full retraining
```

### 7. First Principles: Implementation = Understanding
```
Black Box:        output = torch.magic(input)
First Principles: output = input:pow(2):sum():div(n):sqrt()

Benefit: Deep understanding, full control, easy debugging
```

---

## 📊 Quick Comparison Table

| Aspect | Traditional | Optimized | Improvement |
|--------|------------|-----------|-------------|
| Normalization | LayerNorm | RMSNorm | 20% faster |
| Position | Learned embeddings | RoPE | 100% fewer params |
| Activation | ReLU | SwiGLU | Better quality |
| Attention | Full KV heads | GQA | 33-50% less memory |
| Reasoning | Neural only | Neuro-symbolic | + Interpretability |
| Adaptation | Static | Niche construction | + Domain learning |
| Implementation | Framework | First principles | + Understanding |

---

## 🔍 Deep Dive Sections

### Mathematical Insight: RMSNorm
- **Observation**: Mean centering in LayerNorm doesn't help much for LLMs
- **Innovation**: Remove mean, just normalize by RMS
- **Result**: Simpler, faster, equally effective

### Geometric Insight: RoPE
- **Observation**: Position should encode relative distance
- **Innovation**: Rotate embeddings in complex space by position
- **Result**: Natural relative position encoding, better extrapolation

### Architectural Insight: GQA
- **Observation**: Not all heads need separate KV pairs
- **Innovation**: Multiple Q heads share fewer KV pairs
- **Result**: Massive memory savings with minimal quality cost

### Cognitive Insight: Neuro-Symbolic
- **Observation**: Pure neural ≠ interpretable, pure symbolic ≠ learnable
- **Innovation**: Combine neural learning with symbolic reasoning
- **Result**: Systems that learn AND explain their decisions

### Biological Insight: Niche Construction
- **Observation**: Static models can't adapt to new domains
- **Innovation**: Build domain-specific knowledge from experience
- **Result**: Dynamic adaptation like organisms modifying their environment

---

## 💡 Key Formulas

### RMSNorm
```
RMS(x) = sqrt(mean(x²) + ε)
output = (x / RMS(x)) * γ
```

### Rotary Embedding
```
θ_i = position / base^(2i/dim)
output = x * cos(θ) + rotate_half(x) * sin(θ)
```

### SwiGLU
```
Swish(x) = x * sigmoid(x)
SwiGLU(x, W, V) = Swish(xW) ⊙ xV
```

### GQA Memory
```
Traditional: (n_heads + n_heads + n_heads) * head_dim
GQA:        (n_heads + n_kv + n_kv) * head_dim
Savings:    1 - (n_heads + 2*n_kv) / (3*n_heads)
```

---

## 🎓 Learning Path

**Beginner**: Start with Learning 1 (RMSNorm)
- Simple mathematical concept
- Easy to understand and implement
- Immediate practical value

**Intermediate**: Move to Learning 2 & 3 (RoPE, SwiGLU)
- More sophisticated mathematics
- Requires understanding of rotations and gating
- Significant impact on model quality

**Advanced**: Explore Learning 4-6 (GQA, Neuro-Symbolic, Niche)
- Architectural innovations
- Systems-level thinking
- Novel approaches to intelligence

**Expert**: Dive into Learning 7 (First Principles)
- Implementation from scratch
- Complete understanding
- Full control and customization

---

## 🚀 Quick Start

### See the Learnings in Action

```bash
# Run the demo
th examples/interesting_learnings_demo.lua

# Read comprehensive guide
cat INTERESTING_LEARNINGS.md

# Study implementations
cat RMSNorm.lua
cat RotaryEmbedding.lua
cat SwiGLU.lua
cat NeuroSymbolicLLM.lua
```

### Apply the Learnings

```lua
require 'nn'

-- Use efficient normalization
local norm = nn.RMSNorm(512)

-- Use better position encoding
local rope = nn.RotaryEmbedding(64, 2048)

-- Use better activation
local activation = nn.SwiGLU()

-- Use memory-efficient attention
local config = {
   nHeads = 8,
   nKVHeads = 4,  -- GQA with 2:1 ratio
   dim = 512
}
local attention = nn.MultiHeadAttention(config)

-- Add symbolic reasoning
local model = nn.NeuroSymbolicLLM(config)
model:addSymbolicRule({
   condition = function(ctx) return ctx.input:size(2) < 10 end,
   action = function(out, ctx) return out:mul(1.1) end
})

-- Enable adaptation
model:adaptToNiche({
   success = true,
   context = 'domain',
   pattern = 'pattern'
})
```

---

## 📚 Further Reading

**In this repository:**
- `INTERESTING_LEARNINGS.md` - Comprehensive deep dive
- `LLM_README.md` - Architecture overview
- `ARCHITECTURE.md` - Visual diagrams
- `IMPLEMENTATION_GUIDE.md` - Usage guide
- `examples/interesting_learnings_demo.lua` - Interactive demo

**Papers:**
- RMSNorm: Zhang & Sennrich (2019)
- RoPE: Su et al. (2021)
- SwiGLU: Shazeer (2020)
- GQA: Ainslie et al. (2023)
- LLaMA: Touvron et al. (2023)

**Implementation:**
- `RMSNorm.lua` - Root Mean Square normalization
- `RotaryEmbedding.lua` - Rotary position embeddings
- `SwiGLU.lua` - Swish-Gated Linear Unit
- `MultiHeadAttention.lua` - GQA implementation
- `NeuroSymbolicLLM.lua` - Neuro-symbolic integration

---

## 🎯 One-Sentence Summaries

1. **RMSNorm**: Skip mean centering to normalize 20% faster
2. **RoPE**: Rotate embeddings to encode relative position elegantly
3. **SwiGLU**: Gate information flow for better model quality
4. **GQA**: Share key-value heads to cut memory by 33-50%
5. **Neuro-Symbolic**: Combine learning and logic for interpretability
6. **Niche Construction**: Build domain knowledge from experience
7. **First Principles**: Implement to understand, don't just use

---

## ⚡ Practical Impact

**For Research:**
- Understand state-of-the-art techniques deeply
- Experiment with variations easily
- Build novel architectures on solid foundation

**For Production:**
- Deploy more efficient models (RMSNorm, GQA)
- Handle longer sequences better (RoPE)
- Reduce inference costs (GQA memory savings)

**For Learning:**
- See how LLMs actually work internally
- Grasp mathematical foundations clearly
- Gain intuition for why things work

---

## 🔗 Navigation

- **Main Documentation**: [README.md](README.md)
- **Deep Dive**: [INTERESTING_LEARNINGS.md](INTERESTING_LEARNINGS.md)
- **Architecture**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Implementation**: [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
- **Demo**: [examples/interesting_learnings_demo.lua](examples/interesting_learnings_demo.lua)

---

*Generated as part of single-loop learning exercise: identifying interesting patterns to learn from the nn.llm codebase.*
