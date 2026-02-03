# Double-Loop Learning: Practical Application Guide

## How to Apply Double-Loop Thinking to nn.llm Development

**Purpose**: Concrete guide for using double-loop learning in real work

---

## Overview

This guide shows **how to actually use** double-loop learning when working on nn.llm.  
Not theory—**practical workflows and decision trees**.

---

## Part 1: The Double-Loop Checklist

### Before Starting Any Task

Ask these questions **before** diving into implementation:

#### Level 1: The Task Itself
- [ ] What problem am I solving?
- [ ] Why is this a problem?
- [ ] For whom is this a problem?
- [ ] What assumptions am I making about the problem?

#### Level 2: The Approach
- [ ] Why this solution approach?
- [ ] What alternatives exist?
- [ ] What am I optimizing for?
- [ ] Why those optimization criteria?

#### Level 3: The Context
- [ ] Who will use this?
- [ ] In what contexts will it be used?
- [ ] What constraints am I assuming?
- [ ] Are those constraints real or assumed?

#### Level 4: The Values
- [ ] What do I value in this solution?
- [ ] Efficiency? Simplicity? Flexibility? Something else?
- [ ] Why do I value those things?
- [ ] Whose values am I encoding?

---

## Part 2: Real Scenarios with Workflows

### Scenario 1: "We Need to Optimize Memory Usage"

#### Single-Loop Response:
```
1. Profile memory usage
2. Find bottlenecks
3. Apply standard optimizations
4. Measure improvement
5. Done ✓
```

#### Double-Loop Response:
```
PAUSE: Why do we need to optimize memory?

Questions:
├─ Who is memory-constrained? (edge devices? cloud servers?)
├─ What's the actual constraint? (RAM? VRAM? Bandwidth?)
├─ What's the cost of optimization? (complexity? maintainability?)
└─ What's driving this need? (user request? benchmark? assumption?)

Analysis:
├─ If edge deployment: Aggressive optimization justified
├─ If research cluster: Maybe spend money not engineering time
├─ If benchmark gaming: Question whether benchmark reflects reality
└─ If assumed need: Validate assumption before optimizing

Alternative Framings:
├─ Instead of "optimize memory"
├─ Maybe: "Support diverse deployment contexts"
├─ Or: "Make memory-compute tradeoffs explicit"
└─ Or: "Provide multiple model sizes"

Decision Tree:
IF edge deployment AND memory is real bottleneck
   THEN aggressive optimization (GQA, quantization, etc.)
ELSE IF research AND time is more valuable than hardware
   THEN spend money on bigger machines
ELSE IF unclear motivation
   THEN validate need before optimizing
```

#### Outcome:
- ✓ Better problem understanding
- ✓ Solution matched to actual need
- ✓ Avoid premature optimization
- ✓ Explicit about trade-offs

---

### Scenario 2: "Tests Are Failing"

#### Single-Loop Response:
```
1. Look at failing test
2. Find the bug
3. Fix the bug
4. Test passes ✓
```

#### Double-Loop Response:
```
PAUSE: Why is this test failing?

Surface Level (Single-Loop):
├─ Code bug → Fix code
├─ Test bug → Fix test
└─ Environment → Fix environment

Deeper Level (Double-Loop):
├─ Is the test testing the right thing?
├─ Is the behavior the test expects actually correct?
├─ Does the test reflect current requirements?
└─ Should we change the behavior or the test?

Questions:
1. What assumption did the test make?
2. Is that assumption still valid?
3. Is the new behavior better or worse?
4. Should we update the test or fix the code?

Example:
Test expects: output dimensions preserved
Code produces: output dimensions changed (intentionally)

Single-loop: "Bug in code, fix to preserve dimensions"
Double-loop: "Why should dimensions be preserved? 
              Maybe the new behavior is correct.
              Maybe the test assumption is wrong.
              Let's check the requirement."

Decision:
IF new behavior aligns with requirements
   THEN update test (and document why)
ELSE IF test was correct
   THEN fix code
ELSE IF requirements are unclear
   THEN clarify requirements first
```

---

### Scenario 3: "We Need to Add a New Feature"

#### Single-Loop Response:
```
1. Understand feature request
2. Design implementation
3. Write code
4. Test it
5. Ship it ✓
```

#### Double-Loop Response:
```
PAUSE: Why do we need this feature?

Questions:
├─ Who requested it? (user? stakeholder? assumption?)
├─ What problem does it solve? (stated vs. actual)
├─ Why solve it this way? (alternatives?)
└─ What's the real need? (feature vs. underlying problem)

Example: "Add caching to speed up repeated queries"

Surface: Need caching
Deeper: Why repeated queries?
Deeper: Why is current speed insufficient?
Root: Maybe query design is inefficient

Alternative Solutions:
├─ Add caching (requested solution)
├─ Optimize query design (address root cause)
├─ Batch queries (different approach)
├─ Precompute results (paradigm shift)
└─ Question if speed is actually a problem (validate need)

Decision Framework:
IF feature solves real validated need
   AND approach is appropriate
   AND cost is justified
   THEN implement
ELSE explore deeper to find root cause
```

---

### Scenario 4: "Documentation is Incomplete"

#### Single-Loop Response:
```
1. Identify missing docs
2. Write the docs
3. Complete ✓
```

#### Double-Loop Response:
```
PAUSE: What does "complete" documentation mean?

Questions:
├─ Complete for whom? (experts? beginners? different audiences?)
├─ What does "documentation" mean? (reference? tutorial? both?)
├─ Why is it incomplete? (time? assumptions? unclear requirements?)
└─ What would make it "complete"? (coverage? quality? accessibility?)

Analysis:
Current state: Technical reference exists
Incomplete because: Assumes expert audience

Alternative Framings:
├─ Not "incomplete" but "serves current audience"
├─ Not "need more docs" but "need docs for different audiences"
├─ Not "add content" but "add learning paths"

Solutions:
Instead of: Adding more technical content
Consider:
├─ Multi-level documentation (beginner/intermediate/expert)
├─ Multiple formats (reference/tutorial/cookbook)
├─ Different entry points (top-down/bottom-up/exploratory)
├─ Explicit about audience and prerequisites

Decision:
Document the perspective:
"This is a technical reference for [audience X].
For [audience Y], see [other resource]."
```

---

## Part 3: Decision Trees

### When to Switch from Single-Loop to Double-Loop

```
Start with single-loop (it's faster)
    ↓
Apply standard solution
    ↓
Does it work? ──YES→ Done ✓
    ↓
   NO
    ↓
Try again with better single-loop approach
    ↓
Does it work? ──YES→ Done ✓
    ↓
   NO (problem persists)
    ↓
SWITCH TO DOUBLE-LOOP
    ↓
Question assumptions:
├─ Is this the right problem?
├─ Are we using the right approach?
├─ What assumptions are we making?
└─ Should we reframe entirely?
```

### Trigger for Double-Loop

Switch to double-loop when:
- ✓ Problem recurs despite fixes
- ✓ Solution feels like a hack
- ✓ Unexpected resistance or friction
- ✓ Similar issues in multiple places
- ✓ Growing complexity without benefit
- ✓ Intuition says something is wrong

---

## Part 4: Anti-Patterns to Avoid

### Anti-Pattern 1: Premature Double-Looping
**Problem**: Questioning everything before trying anything  
**Result**: Analysis paralysis, no progress

**Fix**: Start with single-loop. Only escalate if it fails.

```
BAD:  Question → Analyze → Reflect → Question more → ...
GOOD: Try → Fail → Then question assumptions
```

---

### Anti-Pattern 2: Fake Double-Looping
**Problem**: Asking "why?" but not changing approach  
**Result**: Busywork that looks reflective but isn't

**Example**:
```
"Why are we doing this?" 
"Because requirements say so."
"OK, proceeding with original plan."
← Not actually double-loop learning!
```

**Real double-loop**:
```
"Why are we doing this?"
"Requirements say so."
"Why do requirements say this?"
"Good question... let me check the context..."
← Actual questioning of assumptions
```

---

### Anti-Pattern 3: Double-Loop Everything
**Problem**: Questioning every single decision  
**Result**: Nothing gets done

**Fix**: Reserve double-loop for important decisions

```
Use single-loop for:
├─ Standard patterns
├─ Well-understood problems
├─ Low-stakes decisions
└─ Time pressure

Use double-loop for:
├─ Architectural choices
├─ Recurring problems
├─ High-stakes decisions
└─ When you have time
```

---

## Part 5: Templates

### Template 1: Double-Loop Issue Analysis

```markdown
## Issue: [Describe the problem]

### Surface Level (What)
- Observed: [What went wrong]
- Impact: [Who/what is affected]
- Current approach: [Typical solution]

### Single-Loop Analysis (How)
- Root cause: [Immediate cause]
- Fix: [Direct solution]
- Validation: [How to verify]

### Double-Loop Analysis (Why)
- Why does this happen?
  - First why: [Surface cause]
  - Second why: [Deeper cause]
  - Third why: [Root cause]
  - Fourth why: [Systemic issue]
  - Fifth why: [Assumption/value]

- What assumptions led here?
  - Assumption 1: [State it]
  - Assumption 2: [State it]
  - Are these assumptions valid? [Question them]

- Alternative framings:
  - Framing A: [Different perspective]
  - Framing B: [Another angle]
  - Which framing is most useful? [Evaluate]

### Recommendation
- Single-loop fix: [If assumptions are valid]
- Double-loop fix: [If assumptions need changing]
- Rationale: [Why this approach]
```

---

### Template 2: Feature Design Double-Loop

```markdown
## Feature: [Name]

### Request Analysis
- Who requested: [Stakeholder]
- Stated need: [What they said]
- Assumed solution: [What they proposed]

### Double-Loop Questions
1. What problem are they really trying to solve?
   - Stated: [Surface problem]
   - Actual: [Underlying need]

2. Why this solution approach?
   - Assumptions:
     - [Assumption 1]
     - [Assumption 2]
   - Alternatives:
     - [Alternative A]
     - [Alternative B]

3. Who benefits and how?
   - Primary: [Users who benefit]
   - Secondary: [Other beneficiaries]
   - Cost-bearers: [Who pays the cost]

4. What values does this encode?
   - Prioritizes: [What's optimized]
   - Sacrifices: [What's traded away]
   - Reflects: [Underlying values]

### Decision
- [ ] Implement as requested (if assumptions valid)
- [ ] Modify approach (if better solution exists)
- [ ] Solve different problem (if misframed)
- [ ] Don't implement (if need is invalid)

### Rationale
[Explain why based on double-loop analysis]
```

---

### Template 3: Documentation Double-Loop

```markdown
## Documentation: [Topic]

### Single-Loop View
- What to document: [Content]
- How to document: [Format]
- Where to document: [Location]

### Double-Loop View

1. **Audience Analysis**
   - Who will read this?
     - Primary: [Main audience]
     - Secondary: [Other audiences]
   - What do they need?
     - Primary needs: [Core information]
     - Secondary needs: [Additional info]

2. **Purpose Clarification**
   - What is documentation for?
     - Reference? Tutorial? Both?
   - What makes it "good"?
     - Measurable: [Concrete criteria]
     - Subjective: [Quality aspects]

3. **Perspective Acknowledgment**
   - What viewpoint does this take?
     - Technical? Pedagogical? Philosophical?
   - What does this perspective emphasize?
     - Strengths: [What it shows well]
     - Limitations: [What it obscures]

4. **Multi-Path Design**
   - Different readers need different paths
   - Path 1: [For audience A]
   - Path 2: [For audience B]
   - Path 3: [For audience C]

### Documentation Plan
Based on double-loop analysis:
- [ ] Create multi-level docs
- [ ] Explicit about audience
- [ ] Multiple entry points
- [ ] Acknowledge limitations
```

---

## Part 6: Quick Reference Cards

### Card 1: Five Whys

When facing a problem, ask "why?" five times:

```
Problem: Model training is slow
├─ Why? Large batch size
│  └─ Why? Need stable gradients
│     └─ Why? High learning rate
│        └─ Why? Want fast convergence
│           └─ Why? Deadline pressure
│              → Real issue: Time pressure, not batch size
│              → Real solution: Adjust expectations or add resources
```

---

### Card 2: Assumption Checker

Before implementing, list assumptions:

```
Assumption: [State it clearly]
├─ Where does it come from? [Source]
├─ Is it still valid? [Check]
├─ What if it's wrong? [Consequence]
└─ How to test it? [Validation]

Repeat for all assumptions
```

---

### Card 3: Value Clarifier

Make values explicit:

```
This design prioritizes:
1. [Value 1] over [Alternative 1]
2. [Value 2] over [Alternative 2]
3. [Value 3] over [Alternative 3]

Because: [Rationale]

For: [Beneficiaries]

Trade-off: [Cost]
```

---

## Part 7: Integration with Workflow

### In Code Reviews

```markdown
## Code Review Checklist

### Single-Loop Questions
- [ ] Does the code work?
- [ ] Are tests passing?
- [ ] Is it well-documented?
- [ ] Follows style guide?

### Double-Loop Questions
- [ ] Is this solving the right problem?
- [ ] Are the assumptions explicit?
- [ ] What are the trade-offs?
- [ ] Could we approach this differently?
- [ ] What does this design prioritize?

### When to Deep-Dive
IF any of:
- [ ] Introduces new pattern
- [ ] Significant complexity
- [ ] Affects core architecture
- [ ] High stakes decision

THEN add double-loop analysis
```

---

### In Sprint Planning

```markdown
## Feature Prioritization

### Single-Loop Criteria
- Impact (user value)
- Effort (dev time)
- Dependencies (blockers)

### Double-Loop Criteria
- Strategic fit (aligns with vision?)
- Assumption validity (is need real?)
- Alternative approaches (better ways?)
- Value alignment (whose interests?)

### Decision Process
1. Single-loop filter (feasibility)
2. Double-loop analysis (strategic)
3. Informed decision (both lenses)
```

---

## Part 8: Success Metrics

### How to Know Double-Loop is Working

**Leading Indicators**:
- More "why?" questions asked
- More alternatives considered
- More explicit trade-offs
- More assumption documentation

**Lagging Indicators**:
- Fewer recurring problems
- Better architectural decisions
- Faster course corrections
- Deeper team understanding

**Warning Signs** (not working):
- Analysis paralysis
- No decisions made
- Questioning without action
- Performative questioning

---

## Conclusion: Practical Wisdom

### The Balance

```
                Single-Loop ←→ Double-Loop
                
Fast            ←→ Thoughtful
Efficient       ←→ Reflective
Action-focused  ←→ Question-focused
Within system   ←→ About system

Both needed. Choose wisely.
```

### Decision Guide

**Use Single-Loop (90% of time)**:
- Known problems
- Standard solutions
- Low stakes
- Time pressure

**Use Double-Loop (10% of time)**:
- Recurring issues
- High stakes
- Strategic decisions
- When intuition says "something's wrong"

### The Skill

Double-loop learning is a **skill** that improves with practice:

1. **Novice**: Doesn't think to question
2. **Beginner**: Questions but gets paralyzed
3. **Intermediate**: Questions strategically
4. **Advanced**: Knows when to question vs. act
5. **Expert**: Questions and acts fluidly

**Your goal**: Reach level 4—strategic questioning that leads to better action.

---

## Next Steps

To practice double-loop learning:

1. **Start small**: Pick one small decision, apply the checklist
2. **Reflect**: After projects, ask "what assumptions did we make?"
3. **Document**: Write down your double-loop analyses
4. **Iterate**: Get better at knowing when to switch modes
5. **Share**: Teach others, learn from their perspectives

---

*This guide makes double-loop learning practical and actionable for real development work in nn.llm.*

**Created by**: nn.loop(2)  
**Purpose**: Practical application  
**Status**: Field guide complete ✓
