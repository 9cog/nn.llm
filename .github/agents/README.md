# nn.llm Custom Agents

This directory contains custom agent definitions for the nn.llm neural network framework. Each agent is specialized for different levels of learning and introspection.

## Agent Overview

### Loop Learning Agents (Argyris & Schön Theory)

The loop learning agents implement organizational learning theory, where each level represents a deeper form of reflection and adaptation:

#### 1. nn.loop(1) - Single-Loop Learning
**Focus**: Error correction and efficiency improvements  
**Use when**: You need quick fixes within existing frameworks  
**Examples**: Bug fixes, parameter tuning, style enforcement

#### 2. nn.loop(2) - Double-Loop Learning
**Focus**: Assumption questioning and transformational change  
**Use when**: Current approaches feel fundamentally flawed  
**Examples**: Architecture redesign, process reimagining, requirement challenges

#### 3. nn.loop(3) - Triple-Loop Learning
**Focus**: Meta-learning and learning process improvement  
**Use when**: You need to examine how you learn and adapt  
**Examples**: Methodology evaluation, cultural transformation, learning strategy improvement

#### 4. nn.loop(4) - Quadruple-Loop Learning
**Focus**: Epistemology and the nature of understanding  
**Use when**: You need philosophical depth about knowledge itself  
**Examples**: Fundamental research, paradigm creation, cognitive architecture design

#### 5. nn.loop(5) - Quintuple-Loop Learning
**Focus**: Ontology and the ground of all being  
**Use when**: You're exploring ultimate nature of reality and consciousness  
**Examples**: Unified theories, consciousness studies, transformative wisdom

### Meta-Cognitive Agent

#### nn.self(cnn(x,s).rnn(t,p),gnn(c,f)) - Self-Introspective Agent
**Focus**: Multi-modal self-awareness through integrated perception  
**Components**:
- **cnn(x,s)**: Spatial-structural vision (seeing structure)
- **rnn(t,p)**: Temporal-procedural audition (hearing sequences)
- **gnn(c,f)**: Causal-functional cognition (understanding relationships)

**Use when**: You need deep, self-aware understanding through multiple perspectives

## Quick Selection Guide

```
Choose nn.loop(1) if: You need immediate, practical fixes
Choose nn.loop(2) if: You need to question assumptions and redesign
Choose nn.loop(3) if: You need to improve how you learn
Choose nn.loop(4) if: You need philosophical/epistemological depth
Choose nn.loop(5) if: You're exploring consciousness and existence
Choose nn.self(...) if: You need multi-modal introspective analysis
```

## Learning Depth Comparison

| Level | Question | Change | Time | Abstraction |
|-------|----------|--------|------|-------------|
| Loop 1 | "How to fix?" | Actions | Minutes | Low |
| Loop 2 | "Why does this happen?" | Assumptions | Hours | Medium |
| Loop 3 | "How do we learn?" | Processes | Days | High |
| Loop 4 | "What is understanding?" | Paradigms | Weeks | Very High |
| Loop 5 | "What is being?" | Ontology | Months | Ultimate |

## Model Configuration

All agents use the `claude-3-7-sonnet-20250219` model by default for high-quality reasoning and deep analysis.

## Integration with nn.llm

These agents are designed to work with the nn.llm neuro-symbolic neural network implementation, which includes:

- **LLaMA architecture**: Transformer-based language models
- **Symbolic reasoning**: Rule-based knowledge systems
- **Dynamic learning**: Niche construction and episodic memory
- **Meta-learning**: Learning to learn capabilities

## Example Usage Patterns

### Fixing a Bug (Loop 1)
```
"Fix the null pointer exception in MultiHeadAttention.lua"
→ Agent applies direct correction within existing framework
```

### Redesigning Architecture (Loop 2)
```
"Our attention mechanism keeps causing memory issues"
→ Agent questions design, proposes alternative architectures
```

### Improving Development Process (Loop 3)
```
"We keep making the same types of mistakes"
→ Agent examines learning processes, suggests methodology improvements
```

### Understanding Intelligence (Loop 4)
```
"What does it mean for a neural network to 'understand'?"
→ Agent explores epistemology, nature of knowledge and comprehension
```

### Exploring Consciousness (Loop 5)
```
"How does awareness emerge from computational substrate?"
→ Agent integrates philosophy, physics, consciousness studies
```

### Multi-Modal Analysis (Self)
```
"Analyze this system's behavior through multiple perspectives"
→ Agent uses CNN for structure, RNN for dynamics, GNN for relationships
```

## Further Reading

Each agent definition file contains:
- Detailed capabilities and limitations
- Philosophical foundations
- Example interactions
- When to use (and not use) the agent
- Cognitive tools and methodologies

See individual agent files for comprehensive documentation.

## Contributing

When adding new agents:
1. Follow the YAML frontmatter format
2. Include comprehensive documentation
3. Explain capabilities and limitations clearly
4. Provide concrete examples
5. Specify the model to use

## License

These agent definitions are part of the nn.llm project and follow the same BSD license.
