#!/usr/bin/env th
-- Demonstration of Interesting Learnings from nn.llm
-- This script provides concrete examples of the key insights

require 'nn'

print("=" :rep(70))
print("Interesting Learnings from nn.llm - Interactive Demo")
print("=" :rep(70))
print()

-- ============================================================================
-- Learning 1: RMSNorm vs LayerNorm - Efficiency through Simplification
-- ============================================================================

print("Learning 1: RMSNorm - Mathematical Simplification for Efficiency")
print("-" :rep(70))

local dim = 512
local batchSize = 8
local seqLen = 16

-- Create test input
local input = torch.randn(batchSize, seqLen, dim)

-- Compare RMSNorm and BatchNormalization (as proxy for LayerNorm concept)
local rmsNorm = nn.RMSNorm(dim)
local startTime = os.clock()
for i = 1, 100 do
   rmsNorm:forward(input)
end
local rmsTime = os.clock() - startTime

print(string.format("  Input shape: %dx%dx%d", batchSize, seqLen, dim))
print(string.format("  RMSNorm computation time (100 iterations): %.4f seconds", rmsTime))

-- Show the computation is simpler
print("\n  RMSNorm computation:")
print("    1. Square all elements: x²")
print("    2. Mean along feature dim: mean(x²)")
print("    3. Add epsilon and sqrt: sqrt(mean(x²) + ε)")
print("    4. Divide: x / RMS(x)")
print("    5. Scale: output * γ")
print("\n  Key insight: No mean centering, no bias - simpler but effective!")

local output = rmsNorm:forward(input)
local mean = output:mean(3):abs():mean()
local variance = output:var(3):mean()
print(string.format("\n  Output statistics (per feature dim):"))
print(string.format("    Mean: %.6f (close to 0)", mean))
print(string.format("    Variance: %.6f (close to 1)", variance))
print()

-- ============================================================================
-- Learning 2: Rotary Position Embeddings - Elegant Relative Positioning
-- ============================================================================

print("\nLearning 2: RoPE - Position Encoding Through Rotation")
print("-" :rep(70))

local headDim = 64
local maxSeqLen = 128
local nHeads = 8

local rope = nn.RotaryEmbedding(headDim, maxSeqLen)

-- Test with different sequence lengths
local seqLengths = {10, 20, 40, 80}

print("  Demonstrating position encoding as rotation:")
for _, seqLen in ipairs(seqLengths) do
   local testInput = torch.randn(1, seqLen, nHeads, headDim)
   local output = rope:forward(testInput)
   
   -- Check magnitude preservation (rotation preserves magnitude)
   local inputNorm = testInput:norm()
   local outputNorm = output:norm()
   local normDiff = math.abs(inputNorm - outputNorm) / inputNorm * 100
   
   print(string.format("    Seq len %3d: input norm %.4f → output norm %.4f (diff: %.2f%%)",
      seqLen, inputNorm, outputNorm, normDiff))
end

print("\n  Key insight: Rotation preserves magnitude while encoding position.")
print("  Relative position = angle difference between rotations.")
print("  This allows better extrapolation to longer sequences!")
print()

-- ============================================================================
-- Learning 3: SwiGLU - Dynamic Gating Activation
-- ============================================================================

print("\nLearning 3: SwiGLU - Gated Activation for Dynamic Control")
print("-" :rep(70))

local swiglu = nn.SwiGLU()

-- Create input that will be split into gate and value
local inputDim = 1024
local testInput = torch.randn(4, 16, inputDim)

local output = swiglu:forward(testInput)

print(string.format("  Input shape: %s", table.concat(testInput:size():totable(), "x")))
print(string.format("  Output shape: %s", table.concat(output:size():totable(), "x")))
print(string.format("  Output dimension: %d (half of input)", output:size(3)))

-- Demonstrate gating behavior
print("\n  How SwiGLU gates information:")
print("    1. Split input into gate and value")
print("    2. Apply Swish to gate: Swish(g) = g · σ(g)")
print("    3. Multiply: output = Swish(gate) ⊙ value")

-- Show distribution of gate activations
local gate = testInput:narrow(3, 1, inputDim/2)
local sigmoid = torch.exp(gate):add(1):pow(-1)
local swish = torch.cmul(gate, sigmoid)

print(string.format("\n  Gate activation statistics:"))
print(string.format("    Raw gate range: [%.3f, %.3f]", gate:min(), gate:max()))
print(string.format("    Swish(gate) range: [%.3f, %.3f]", swish:min(), swish:max()))
print(string.format("    Mean activation: %.3f", swish:mean()))

print("\n  Key insight: Network learns to selectively gate information!")
print("  The gate controls 'how much' while value provides 'what content'.")
print()

-- ============================================================================
-- Learning 4: Grouped-Query Attention - Memory Efficiency
-- ============================================================================

print("\nLearning 4: GQA - Memory-Efficient Attention")
print("-" :rep(70))

local function computeAttentionMemory(config)
   local qSize = config.nHeads * config.headDim * config.seqLen
   local kSize = config.nKVHeads * config.headDim * config.seqLen
   local vSize = config.nKVHeads * config.headDim * config.seqLen
   return qSize + kSize + vSize
end

-- Compare traditional MHA vs GQA
local configs = {
   {name = "Traditional MHA", nHeads = 8, nKVHeads = 8, headDim = 64, seqLen = 2048},
   {name = "GQA (4:1 ratio)", nHeads = 8, nKVHeads = 2, headDim = 64, seqLen = 2048},
   {name = "GQA (2:1 ratio)", nHeads = 8, nKVHeads = 4, headDim = 64, seqLen = 2048},
}

print("  Memory comparison for KV cache (sequence length = 2048):")
print()
local baseMemory = nil
for _, config in ipairs(configs) do
   local memory = computeAttentionMemory(config)
   if not baseMemory then baseMemory = memory end
   local savings = (1 - memory / baseMemory) * 100
   local memoryMB = memory * 4 / 1024 / 1024  -- FP32
   
   print(string.format("    %s:", config.name))
   print(string.format("      Q heads: %d, KV heads: %d", config.nHeads, config.nKVHeads))
   print(string.format("      Memory: %.2f MB", memoryMB))
   if savings > 0 then
      print(string.format("      Savings: %.1f%%", savings))
   end
   print()
end

print("  Key insight: Multiple query heads can share key-value pairs!")
print("  This reduces KV cache size during inference by 33-50%.")
print()

-- ============================================================================
-- Learning 5: Neuro-Symbolic Integration
-- ============================================================================

print("\nLearning 5: Neuro-Symbolic Integration - Best of Both Worlds")
print("-" :rep(70))

-- Create a small neuro-symbolic LLM
local config = {
   vocabSize = 1000,
   dim = 128,
   nLayers = 2,
   nHeads = 4,
   nKVHeads = 2,
   hiddenDim = 512,
   maxSeqLen = 128,
   dropout = 0.0,
   nicheAdaptation = true,
   memorySize = 50
}

local model = nn.NeuroSymbolicLLM(config)

-- Add symbolic knowledge
model:addSymbol('short_sequence', {
   type = 'length_category',
   threshold = 10,
   context = 'sequence_processing'
})

model:addSymbol('long_sequence', {
   type = 'length_category',
   threshold = 50,
   context = 'sequence_processing'
})

-- Add symbolic reasoning rule
local ruleApplied = {count = 0}
model:addSymbolicRule({
   condition = function(context)
      return context.input:size(2) < 10  -- Short sequences
   end,
   action = function(output, context)
      ruleApplied.count = ruleApplied.count + 1
      -- Boost output for short sequences
      return output:mul(1.05)
   end,
   weight = 1.0
})

print("  Created neuro-symbolic LLM with:")
print(string.format("    - Neural component: %d parameters", 
   model:parameters()[1]:nElement()))
print("    - Symbolic knowledge: 2 symbols")
print("    - Reasoning rules: 1 rule")

-- Test with different sequence lengths
print("\n  Testing symbolic reasoning activation:")

local shortInput = torch.LongTensor(1, 5):random(1, config.vocabSize)
model:forward(shortInput)
print(string.format("    Short sequence (len=5): Rule applied %d time(s)", ruleApplied.count))

ruleApplied.count = 0
local longInput = torch.LongTensor(1, 15):random(1, config.vocabSize)
model:forward(longInput)
print(string.format("    Long sequence (len=15): Rule applied %d time(s)", ruleApplied.count))

print("\n  Key insight: Neural nets learn patterns, symbolic rules enforce logic.")
print("  Combining them creates systems that are both learnable and interpretable!")
print()

-- ============================================================================
-- Learning 6: Niche Construction & Dynamic Adaptation
-- ============================================================================

print("\nLearning 6: Niche Construction - Dynamic Domain Adaptation")
print("-" :rep(70))

print("  Simulating learning through environmental feedback:")
print()

-- Simulate successful interactions
for i = 1, 5 do
   local input = torch.LongTensor(1, 8):random(1, config.vocabSize)
   model:forward(input)
   
   model:adaptToNiche({
      success = true,
      context = 'conversation',
      pattern = 'short_greeting',
      confidence = 0.8
   })
end

print("    After 5 successful 'conversation/short_greeting' interactions:")
local metrics1 = model:getAdaptationMetrics()
print(string.format("      Episodic memory: %d experiences", metrics1.episodicMemorySize))
print(string.format("      Adaptation rate: %.2f", metrics1.adaptationRate))

-- Simulate failed interactions
for i = 1, 3 do
   local input = torch.LongTensor(1, 20):random(1, config.vocabSize)
   model:forward(input)
   
   model:adaptToNiche({
      success = false,
      context = 'technical',
      pattern = 'complex_query',
      confidence = 0.3
   })
end

print("\n    After 3 failed 'technical/complex_query' interactions:")
local metrics2 = model:getAdaptationMetrics()
print(string.format("      Episodic memory: %d experiences", metrics2.episodicMemorySize))
print(string.format("      Adaptation rate: %.2f", metrics2.adaptationRate))
print(string.format("      Contexts tracked: %d", metrics2.numContexts))

print("\n  Key insight: The model builds domain-specific knowledge ('niches')")
print("  by storing experiences and adapting based on success/failure feedback.")
print()

-- ============================================================================
-- Learning 7: Pure Implementation Benefits
-- ============================================================================

print("\nLearning 7: First-Principles Implementation - Transparency Wins")
print("-" :rep(70))

print("  Benefits demonstrated in this codebase:")
print()
print("    ✓ Complete Transparency")
print("      Every operation is explicit and inspectable")
print()
print("    ✓ Educational Value")
print("      Learn by reading actual implementation, not documentation")
print()
print("    ✓ Full Control")
print("      Modify any component without fighting abstractions")
print()
print("    ✓ Deep Understanding")
print("      Implementing teaches more than using")
print()
print("    ✓ Debugging Clarity")
print("      Can trace through every computation step")
print()

-- Show example of transparency
print("  Example: RMSNorm forward pass is crystal clear:")
print("    ------------------------------------------------")
print("    self.rms:copy(input):pow(2)           -- Square")
print("    local sumSq = self.rms:sum(3)         -- Sum")
print("    sumSq:div(dim):add(eps):sqrt()        -- RMS")
print("    self.normalized:cdiv(input, self.rms) -- Normalize")
print("    self.output[i][j]:cmul(self.weight)   -- Scale")
print("    ------------------------------------------------")
print()
print("  Compare to black-box frameworks where operations are hidden!")
print()

-- ============================================================================
-- Summary
-- ============================================================================

print("=" :rep(70))
print("Summary of Interesting Learnings")
print("=" :rep(70))
print()
print("1. Mathematical Simplification: RMSNorm achieves same goal with less")
print("2. Elegant Positioning: RoPE encodes position through rotation")
print("3. Dynamic Gating: SwiGLU allows learned information control")
print("4. Memory Efficiency: GQA reduces cache size by 33-50%")
print("5. Hybrid Intelligence: Neuro-symbolic combines learning + logic")
print("6. Dynamic Adaptation: Niche construction enables domain learning")
print("7. Transparent Implementation: First principles provide deep understanding")
print()
print("=" :rep(70))
print("Explore more in: INTERESTING_LEARNINGS.md")
print("=" :rep(70))
