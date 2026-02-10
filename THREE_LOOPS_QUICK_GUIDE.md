# Three Learning Loops: Quick Reference Guide

**Purpose**: Practical guide for choosing and using the three learning loops

---

## The Three Loops at a Glance

| | Loop 1: Single-Loop | Loop 2: Double-Loop | Loop 3: Triple-Loop |
|---|---|---|---|
| **Focus** | Actions & Results | Assumptions & Values | Learning Process |
| **Question** | "How?" | "Why?" | "How do we learn?" |
| **Changes** | Parameters | Framework | Learning capacity |
| **Speed** | Fast ⚡ | Medium 🤔 | Slow 🧘 |
| **Impact** | Incremental | Transformational | Paradigmatic |
| **Use When** | Problem is clear | Problem recurs | Process fails |

---

## Decision Tree: Which Loop to Use?

```
START: You have a challenge/opportunity
    ↓
┌──────────────────────────────────────┐
│ Is the problem well-defined?         │
│ Do you know how to solve it?         │
└──────────┬───────────────────────────┘
          YES → Use Loop 1 (Single-Loop)
           |      Fix it efficiently
           |
           NO
           ↓
┌──────────────────────────────────────┐
│ Have you tried solving this before?  │
│ Does it keep coming back?            │
└──────────┬───────────────────────────┘
          YES → Use Loop 2 (Double-Loop)
           |      Question your assumptions
           |
           NO → Use Loop 1 anyway
           |      (gather data first)
           |
           ↓
┌──────────────────────────────────────┐
│ Have you tried multiple approaches?  │
│ Is the learning process ineffective? │
└──────────┬───────────────────────────┘
          YES → Use Loop 3 (Triple-Loop)
           |      Examine learning process
           |
           NO → Use Loop 2 more
                (question deeper)
```

---

## Examples from nn.llm

### Scenario 1: Performance Problem

**Situation**: Neural network is slow

**Loop 1 Response**:
```
1. Profile the code
2. Find slow operations
3. Optimize them (e.g., use RMSNorm instead of LayerNorm)
4. Measure speedup
5. Done ✓
```

**Loop 2 Response**:
```
1. Why is it slow?
2. Is speed the real problem or symptom?
3. Should we optimize for speed or accuracy or memory?
4. Are we using the right architecture?
5. Reframe: Maybe we need different hardware, not faster code
```

**Loop 3 Response**:
```
1. How do we identify performance problems?
2. What's our process for optimization?
3. How do we decide what to optimize?
4. Can we improve how we approach performance?
5. Should we build tools to automate this meta-analysis?
```

---

### Scenario 2: Design Decision

**Situation**: Choosing between architectures

**Loop 1**:
- Compare benchmarks
- Pick the faster/smaller/better one
- Implement it

**Loop 2**:
- Why these specific architectures?
- What assumptions do they embody?
- Is this comparison even the right question?
- Should we design something new instead?

**Loop 3**:
- How do we make design decisions?
- What's our decision-making framework?
- Can we improve how we evaluate options?
- How do we learn which criteria matter when?

---

### Scenario 3: Learning Something New

**Situation**: "Identify something interesting to learn"

**Loop 1** (nn.loop(1)):
- Scan codebase
- Find 7 technical innovations
- Document them clearly
- Result: INTERESTING_LEARNINGS.md

**Loop 2** (nn.loop(2)):
- Question what "interesting" means
- Examine assumptions behind selection
- Explore 8 alternative perspectives
- Result: META_LEARNING_REFLECTION.md

**Loop 3** (nn.loop(3)):
- Analyze how loops interact
- Extract meta-patterns of learning
- Build meta-strategies
- Result: TRIPLE_LOOP_LEARNING.md

---

## When NOT to Use Each Loop

### Don't Use Loop 1 When:
- ❌ You keep fixing the same bug
- ❌ Solutions feel like band-aids
- ❌ Root cause is unclear
- ❌ Framework might be wrong
→ **Switch to Loop 2**

### Don't Use Loop 2 When:
- ❌ You need quick action
- ❌ Problem is truly novel
- ❌ Framework is sound
- ❌ Overthinking is happening
→ **Drop to Loop 1**

### Don't Use Loop 3 When:
- ❌ Lost in abstraction
- ❌ No concrete problems to ground in
- ❌ Reflection becomes procrastination
- ❌ Paralyzed by meta-thinking
→ **Drop to Loop 1 or 2**

---

## Integration Strategy

### The Optimal Rhythm

**Don't choose one loop forever. Cycle through them:**

```
Week 1-3: Loop 1 (Execution)
    ↓
    Build, ship, measure
    ↓
Week 4: Loop 2 (Reflection)
    ↓
    Question approach, explore alternatives
    ↓
Month 3: Loop 3 (Meta-Review)
    ↓
    Examine learning process, improve capacity
    ↓
Return to Loop 1 with enhanced capability
```

**Adjust rhythm to your context** (faster for startups, slower for research)

---

## Practical Cheat Sheet

### I Have a Bug to Fix
→ **Loop 1**: Fix it directly  
→ Time: Minutes to hours

### The Bug Keeps Coming Back
→ **Loop 2**: Question the design  
→ Time: Hours to days

### We Keep Making the Same Design Mistakes
→ **Loop 3**: Improve design process  
→ Time: Days to weeks

### I'm Learning a New Technology
→ **Loop 1**: Learn the API  
→ **Loop 2**: Understand the philosophy  
→ **Loop 3**: Extract learning strategies

### I'm Stuck and Don't Know Why
→ **Loop 2**: Question assumptions  
→ If still stuck → **Loop 3**: Examine problem-solving process

### I Want to Improve My Team
→ **Loop 1**: Train on skills  
→ **Loop 2**: Align on values  
→ **Loop 3**: Build learning culture

---

## Signals & Triggers

### Signs You're in the Right Loop

#### Loop 1 ✓
- Making steady progress
- Clear metrics improving
- Solutions working
- Momentum building

#### Loop 2 ✓
- Uncovering hidden assumptions
- Multiple perspectives emerging
- Deeper understanding developing
- Paradigm shift feeling

#### Loop 3 ✓
- Meta-patterns becoming visible
- Process improvements identified
- Learning capacity expanding
- Wisdom accumulating

### Signs You're in the Wrong Loop

#### Stuck in Loop 1 ⚠️
- Same problems recurring
- Diminishing returns
- Framework feels constraining
- Need for deeper thinking
→ **Move to Loop 2**

#### Stuck in Loop 2 ⚠️
- Analysis paralysis
- Too many perspectives
- Not enough action
- Losing concreteness
→ **Return to Loop 1**

#### Stuck in Loop 3 ⚠️
- Excessive abstraction
- Navel-gazing
- Disconnected from reality
- Reflection without application
→ **Return to Loop 1 or 2**

---

## The Meta-Strategy Table

| Context | Loop 1 | Loop 2 | Loop 3 | Integration |
|---------|--------|--------|--------|-------------|
| **New Problem** | Try standard solution | Question if standard applies | Reflect on problem-solving approach | L1 → if fails → L2 |
| **Recurring Problem** | Fix symptoms | Question root cause | Examine why problems recur | L2 → then L3 |
| **Learning New Skill** | Practice techniques | Understand principles | Develop learning strategy | L1 + L2 + L3 |
| **Team Development** | Train skills | Align values | Build learning culture | L1 foundation, L2 cohesion, L3 growth |
| **Research** | Run experiments | Question hypotheses | Improve methodology | L1 data, L2 theory, L3 process |
| **Crisis** | Act quickly | Reflect after | Extract meta-lessons | L1 now, L2 soon, L3 later |

---

## The Helix Pattern

**Effective learning spirals through all three loops:**

```
Month 1: Loop 1 intensive (build, execute, measure)
           ↓ Collect experience
         
Week 4-5: Loop 2 deep dive (question, reframe, explore)
           ↓ Extract insights
           
Week 6: Loop 3 reflection (examine process, improve capacity)
           ↓ Build meta-strategies
           
Month 2: Loop 1 enhanced (better execution with Loop 2/3 insights)
           ↓ Repeat spiral
```

**Each cycle**: Same loops, higher capability

---

## For AI Systems

### Implementing Triple-Loop in Code

```lua
-- Example: Adaptive learning system

function AdaptiveLearner:learn(experience)
    -- Determine which loop to engage
    local loop = self:selectLoop(experience)
    
    if loop == 1 then
        -- Single-loop: Direct learning
        self:updateWeights(experience)
        
    elseif loop == 2 then
        -- Double-loop: Adjust learning strategy
        self:questionAssumptions(experience)
        self:modifyArchitecture()
        
    elseif loop == 3 then
        -- Triple-loop: Improve learning process
        self:evaluateLearningEffectiveness()
        self:improveMetaStrategies()
        self:buildLearningCapacity()
    end
end

function AdaptiveLearner:selectLoop(experience)
    -- Meta-strategy: Choose learning mode
    
    if self:isProgressSteady() then
        return 1  -- Keep doing what works
        
    elseif self:isProgressStagnant() then
        return 2  -- Question approach
        
    elseif self:isLearningIneffective() then
        return 3  -- Improve learning itself
    end
end
```

---

## The Wisdom Hierarchy

```
        Wisdom
       /   |   \
      /    |    \
     /     |     \
   Loop   Loop   Loop
    3      2      1
    |      |      |
Process  Values  Facts
    |      |      |
Meta-   Frame-  Execute
Learn   work
```

**Moving up**: Increasing abstraction, decreasing frequency  
**Moving down**: Increasing action, increasing frequency  
**Wisdom**: Knowing where to be, when

---

## Quick Reminders

### For Daily Work
- **Default**: Loop 1 (get things done)
- **Weekly**: Loop 2 (reflect and question)
- **Monthly**: Loop 3 (improve processes)

### For Learning
- **Master content**: Loop 1
- **Understand context**: Loop 2
- **Develop meta-skills**: Loop 3

### For Teams
- **Execute projects**: Loop 1
- **Align on vision**: Loop 2
- **Build learning culture**: Loop 3

### For Research
- **Run experiments**: Loop 1
- **Question paradigms**: Loop 2
- **Improve methodology**: Loop 3

---

## The One-Minute Summary

**Loop 1**: Fix problems (fast, tactical)  
**Loop 2**: Question assumptions (medium, strategic)  
**Loop 3**: Improve learning process (slow, transformational)

**Use all three**: Cycle through them strategically  
**Master all three**: Develop mode-switching fluency  
**Integrate all three**: Build adaptive learning systems

**The goal**: Become better at becoming better at becoming better.

---

## Final Wisdom

> **The novice uses one loop.**  
> **The expert uses all three.**  
> **The master doesn't notice which loop they're using—it flows naturally.**

---

*For detailed analysis, see:*
- *INTERESTING_LEARNINGS.md (Loop 1)*
- *META_LEARNING_REFLECTION.md (Loop 2)*
- *TRIPLE_LOOP_LEARNING.md (Loop 3)*
- *LEARNING_LOOPS_COMPARISON.md (Comparative analysis)*
