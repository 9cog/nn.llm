# Architecture Visualization

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Neuro-Symbolic LLM System                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                    Neural Component                       │ │
│  │                    (LLaMA Model)                          │ │
│  ├───────────────────────────────────────────────────────────┤ │
│  │                                                           │ │
│  │  Input: Token IDs [batch, seq_len]                       │ │
│  │         ↓                                                 │ │
│  │  Token Embeddings: [batch, seq_len, dim]                 │ │
│  │         ↓                                                 │ │
│  │  ┌─────────────────────────────────────────────────┐     │ │
│  │  │ Transformer Block × N                            │     │ │
│  │  │ ┌─────────────────────────────────────────────┐ │     │ │
│  │  │ │ RMSNorm                                     │ │     │ │
│  │  │ │        ↓                                    │ │     │ │
│  │  │ │ Multi-Head Attention (with GQA & RoPE)      │ │     │ │
│  │  │ │        ↓                                    │ │     │ │
│  │  │ │ Residual Add (+)                            │ │     │ │
│  │  │ │        ↓                                    │ │     │ │
│  │  │ │ RMSNorm                                     │ │     │ │
│  │  │ │        ↓                                    │ │     │ │
│  │  │ │ FeedForward (with SwiGLU)                   │ │     │ │
│  │  │ │        ↓                                    │ │     │ │
│  │  │ │ Residual Add (+)                            │ │     │ │
│  │  │ └─────────────────────────────────────────────┘ │     │ │
│  │  └─────────────────────────────────────────────────┘     │ │
│  │         ↓                                                 │ │
│  │  Final RMSNorm                                            │ │
│  │         ↓                                                 │ │
│  │  Output Projection: [batch, seq_len, vocab_size]         │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                          ↓                                     │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Symbolic Reasoning Layer                     │ │
│  ├───────────────────────────────────────────────────────────┤ │
│  │  • Apply symbolic rules to neural output                  │ │
│  │  • Query knowledge base                                   │ │
│  │  • Context-aware adjustments                              │ │
│  │  • Pattern matching                                       │ │
│  └───────────────────────────────────────────────────────────┘ │
│                          ↓                                     │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │           Dynamic Learning & Adaptation                   │ │
│  ├───────────────────────────────────────────────────────────┤ │
│  │  • Store experience in episodic memory                    │ │
│  │  • Extract patterns                                       │ │
│  │  • Reinforce successful strategies                        │ │
│  │  • Explore alternatives on failure                        │ │
│  │  • Build context-specific knowledge                       │ │
│  └───────────────────────────────────────────────────────────┘ │
│                          ↓                                     │
│                   Final Output                                │
│                                                               │
└─────────────────────────────────────────────────────────────────┘
```

## Attention Mechanism Detail

```
Multi-Head Attention (Grouped-Query Attention)
┌────────────────────────────────────────────────────────────┐
│                                                            │
│  Input: [batch, seq_len, dim]                             │
│         ↓         ↓         ↓                              │
│      ┌──────┐ ┌──────┐ ┌──────┐                           │
│      │ W_Q  │ │ W_K  │ │ W_V  │  (Linear projections)     │
│      └──┬───┘ └──┬───┘ └──┬───┘                           │
│         ↓         ↓         ↓                              │
│    Q [n_heads] K [n_kv] V [n_kv]  (Reshape to heads)      │
│         ↓         ↓         ↓                              │
│      RoPE      RoPE      (pass)   (Position encoding)     │
│         ↓         ↓         ↓                              │
│         Q    Repeat K  Repeat V   (GQA: repeat KV)        │
│         │         │         │                              │
│         └────┬────┴─────────┘                              │
│              ↓                                             │
│     Attention(Q, K, V) = softmax(QK^T/√d_k) V             │
│              ↓                                             │
│       [batch, n_heads, seq_len, head_dim]                 │
│              ↓                                             │
│       Transpose & Concatenate                             │
│              ↓                                             │
│       [batch, seq_len, dim]                               │
│              ↓                                             │
│         Output Linear                                     │
│              ↓                                             │
│     Output: [batch, seq_len, dim]                         │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Feed-Forward Network Detail

```
FeedForward with SwiGLU
┌────────────────────────────────────────────────────────────┐
│                                                            │
│  Input: [batch, seq_len, dim]                             │
│         │                                                  │
│         ├──────────┬──────────┐                           │
│         ↓          ↓          ↓                            │
│      Linear     Linear     (pass)                         │
│       (W1)       (W3)                                      │
│         ↓          ↓                                       │
│       Gate       Value                                    │
│  [hidden_dim] [hidden_dim]                                │
│         │          │                                       │
│         └────┬─────┘                                       │
│              ↓                                             │
│          SwiGLU Activation                                │
│     Swish(Gate) ⊙ Value                                   │
│     = (Gate × σ(Gate)) ⊙ Value                            │
│              ↓                                             │
│       [batch, seq_len, hidden_dim]                        │
│              ↓                                             │
│          Linear (W2)                                      │
│              ↓                                             │
│   Output: [batch, seq_len, dim]                           │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Neuro-Symbolic Integration

```
┌────────────────────────────────────────────────────────────┐
│                Neural Output Processing                    │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Neural Output (Logits)                                   │
│         ↓                                                  │
│  ┌──────────────────────────────────────────────────┐     │
│  │ Symbolic Knowledge Base                          │     │
│  │ ┌────────────┐  ┌─────────────┐  ┌────────────┐ │     │
│  │ │  Symbols   │  │    Rules    │  │  Context   │ │     │
│  │ │            │  │             │  │            │ │     │
│  │ │ 'greeting' │  │ if cond()   │  │ 'social'   │ │     │
│  │ │ 'question' │  │ then act()  │  │ 'technical'│ │     │
│  │ │ 'answer'   │  │             │  │ 'casual'   │ │     │
│  │ └────────────┘  └─────────────┘  └────────────┘ │     │
│  └──────────────────────────────────────────────────┘     │
│         ↓                                                  │
│  Apply Rules Based on Context                             │
│         ↓                                                  │
│  Modified Output                                          │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Dynamic Learning Flow

```
┌────────────────────────────────────────────────────────────┐
│                 Experience Lifecycle                       │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1. Interaction                                           │
│     Input → Model → Output                                │
│         ↓                                                  │
│  2. Store Experience                                      │
│     ┌─────────────────────────────────────┐               │
│     │ Episodic Memory (FIFO, max 1000)   │               │
│     │ {input, output, timestamp, seq}     │               │
│     └─────────────────────────────────────┘               │
│         ↓                                                  │
│  3. Receive Feedback                                      │
│     {success: bool, context: str, pattern: str}           │
│         ↓                                                  │
│  4. Extract Patterns                                      │
│     Analyze recent experiences                            │
│     Identify recurring patterns                           │
│         ↓                                                  │
│  5. Adapt                                                 │
│     ├─ If Success:                                        │
│     │  Reinforce pattern in domain knowledge              │
│     │  Increase weight for context+pattern               │
│     └─ If Failure:                                        │
│        Reduce pattern weight                              │
│        Mark for exploration                               │
│         ↓                                                  │
│  6. Update Metrics                                        │
│     Track adaptation rate                                 │
│     Monitor performance                                   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Component Dependencies

```
                    init.lua
                       │
                       ├─ THNN.lua
                       ├─ Module.lua
                       │
                       ├─ RMSNorm.lua ──────────────┐
                       ├─ RotaryEmbedding.lua       │
                       ├─ SwiGLU.lua                │
                       │                            │
                       ├─ MultiHeadAttention.lua ───┼─┐
                       │      uses: Linear          │ │
                       │            RotaryEmbedding │ │
                       │            Dropout         │ │
                       │                            │ │
                       ├─ FeedForward.lua ──────────┼─┼─┐
                       │      uses: Linear          │ │ │
                       │            SwiGLU          │ │ │
                       │            Dropout         │ │ │
                       │                            │ │ │
                       ├─ TransformerBlock.lua ─────┼─┼─┼─┐
                       │      uses: RMSNorm ────────┘ │ │ │
                       │            MultiHeadAttention─┘ │ │
                       │            FeedForward ─────────┘ │
                       │                                   │
                       ├─ LLaMA.lua ───────────────────────┼─┐
                       │      uses: LookupTable            │ │
                       │            TransformerBlock ──────┘ │
                       │            RMSNorm                  │
                       │            Linear                   │
                       │                                     │
                       └─ NeuroSymbolicLLM.lua ─────────────┘
                              uses: LLaMA ───────────────────┘
```

## Data Flow Example

```
Text: "Hello, how are you?"
         ↓
Tokenization: [42, 156, 789, 234, 901]
         ↓
Input Tensor: torch.LongTensor(1, 5)
         ↓
┌──────────────────────────────────────┐
│ Token Embedding                      │
│ [1, 5] → [1, 5, 512]                 │
└──────────────────────────────────────┘
         ↓
┌──────────────────────────────────────┐
│ Transformer Block 1                  │
│ Attention + FFN                      │
│ [1, 5, 512] → [1, 5, 512]            │
└──────────────────────────────────────┘
         ↓
         ...  (repeat for N layers)
         ↓
┌──────────────────────────────────────┐
│ Transformer Block N                  │
│ Attention + FFN                      │
│ [1, 5, 512] → [1, 5, 512]            │
└──────────────────────────────────────┘
         ↓
┌──────────────────────────────────────┐
│ Final RMSNorm                        │
│ [1, 5, 512] → [1, 5, 512]            │
└──────────────────────────────────────┘
         ↓
┌──────────────────────────────────────┐
│ Output Projection                    │
│ [1, 5, 512] → [1, 5, 32000]          │
└──────────────────────────────────────┘
         ↓
Logits: [1, 5, 32000]
         ↓
┌──────────────────────────────────────┐
│ Symbolic Reasoning                   │
│ Apply rules, check context           │
└──────────────────────────────────────┘
         ↓
Modified Logits: [1, 5, 32000]
         ↓
Softmax → Sample → Next Token
         ↓
┌──────────────────────────────────────┐
│ Dynamic Learning                     │
│ Store experience, extract patterns   │
└──────────────────────────────────────┘
```

## Module Hierarchy

```
nn.Module (base)
    │
    ├─ nn.RMSNorm
    │
    ├─ nn.RotaryEmbedding
    │
    ├─ nn.SwiGLU
    │
    ├─ nn.MultiHeadAttention
    │      contains:
    │      ├─ nn.Linear (wq, wk, wv, wo)
    │      ├─ nn.RotaryEmbedding (rope)
    │      └─ nn.Dropout (dropoutModule)
    │
    ├─ nn.FeedForward
    │      contains:
    │      ├─ nn.Linear (w1, w2, w3)
    │      ├─ nn.SwiGLU (swiglu)
    │      └─ nn.Dropout (dropoutModule)
    │
    ├─ nn.TransformerBlock
    │      contains:
    │      ├─ nn.RMSNorm (attnNorm, ffnNorm)
    │      ├─ nn.MultiHeadAttention (attention)
    │      └─ nn.FeedForward (feedForward)
    │
    ├─ nn.LLaMA
    │      contains:
    │      ├─ nn.LookupTable (tokEmbeddings)
    │      ├─ nn.TransformerBlock[] (layers)
    │      ├─ nn.RMSNorm (norm)
    │      └─ nn.Linear (output)
    │
    └─ nn.NeuroSymbolicLLM
           contains:
           ├─ nn.LLaMA (llama)
           ├─ symbolTable {}
           ├─ ruleBase []
           ├─ episodicMemory []
           └─ domainKnowledge {}
```

## Legend

```
┌─────┐
│ Box │  Component or Module
└─────┘

   ↓     Data flow direction

───┬───  Split/Branch

───┘     Join/Merge

[dims]   Tensor dimensions

⊙        Element-wise multiplication

×        Matrix multiplication

σ        Sigmoid function
```
