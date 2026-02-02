#!/usr/bin/env th
-- Example: Using the Neuro-Symbolic LLM for text generation and dynamic learning
-- This demonstrates llama.cpp functionality implemented in pure Lua

require 'nn'

print("=== Neuro-Symbolic LLM Example ===\n")

-- Configuration for a small LLaMA model
local config = {
   vocabSize = 1000,      -- Small vocabulary for demo
   dim = 128,             -- Model dimension
   nLayers = 4,           -- Number of transformer layers
   nHeads = 4,            -- Number of attention heads
   nKVHeads = 2,          -- Number of key-value heads (GQA)
   hiddenDim = 512,       -- FFN hidden dimension
   maxSeqLen = 256,       -- Maximum sequence length
   dropout = 0.1,         -- Dropout rate
   normEps = 1e-6,        -- Normalization epsilon
   tieWeights = true,     -- Tie input/output embeddings
   
   -- Neuro-symbolic parameters
   nicheAdaptation = true,
   learningRate = 0.01,
   memorySize = 100,
   adaptiveThreshold = 0.5
}

print("Creating Neuro-Symbolic LLM with configuration:")
print(string.format("  Vocabulary: %d tokens", config.vocabSize))
print(string.format("  Model dim: %d", config.dim))
print(string.format("  Layers: %d", config.nLayers))
print(string.format("  Attention heads: %d (KV heads: %d)", config.nHeads, config.nKVHeads))
print(string.format("  Max sequence length: %d\n", config.maxSeqLen))

-- Create the neuro-symbolic LLM
local model = nn.NeuroSymbolicLLM(config)

print("Model structure:")
print(model)
print()

-- Add symbolic knowledge
print("=== Adding Symbolic Knowledge ===")
model:addSymbol('greeting', {tokens = {10, 20, 30}, context = 'social'})
model:addSymbol('question', {tokens = {40, 50}, context = 'inquiry'})
print("Added symbolic knowledge: 'greeting' and 'question'\n")

-- Add symbolic reasoning rule
print("=== Adding Symbolic Rules ===")
model:addSymbolicRule({
   condition = function(context)
      return context.input:size(2) < 10
   end,
   action = function(output, context)
      -- Boost probabilities for short sequences
      return output:mul(1.1)
   end,
   weight = 1.0
})
print("Added symbolic rule: boost output for short sequences\n")

-- Create sample input (batch of token sequences)
local batchSize = 2
local seqLen = 8
local input = torch.LongTensor(batchSize, seqLen):random(1, config.vocabSize)

print("=== Forward Pass ===")
print(string.format("Input shape: %dx%d", batchSize, seqLen))

-- Forward pass
model:training()
local output = model:forward(input)

print(string.format("Output shape: %dx%dx%d", output:size(1), output:size(2), output:size(3)))
print(string.format("Output range: [%.4f, %.4f]\n", output:min(), output:max()))

-- Get model parameters
local params, gradParams = model:parameters()
print(string.format("Total parameters: %d", #params))
local totalParams = 0
for i = 1, #params do
   totalParams = totalParams + params[i]:nElement()
end
print(string.format("Total parameter count: %d (%.2fM)\n", totalParams, totalParams / 1e6))

-- Demonstrate dynamic learning
print("=== Dynamic Learning (Niche Construction) ===")

-- Simulate feedback from environment
local feedback1 = {
   success = true,
   context = 'short_sequence',
   pattern = 'greeting_pattern',
   confidence = 0.8
}

model:adaptToNiche(feedback1)
print("Adapted to successful pattern")

local feedback2 = {
   success = false,
   context = 'long_sequence',
   pattern = 'complex_pattern',
   confidence = 0.3
}

model:adaptToNiche(feedback2)
print("Explored alternatives for failed pattern\n")

-- Get adaptation metrics
local metrics = model:getAdaptationMetrics()
print("=== Adaptation Metrics ===")
print(string.format("Episodic memory size: %d", metrics.episodicMemorySize))
print(string.format("Recent experiences: %d", metrics.recentExperiences))
print(string.format("Number of symbols: %d", metrics.numSymbols))
print(string.format("Number of rules: %d", metrics.numRules))
print(string.format("Number of contexts: %d", metrics.numContexts))
print(string.format("Adaptation rate: %.2f\n", metrics.adaptationRate))

-- Text generation example
print("=== Text Generation ===")
local startTokens = torch.LongTensor(1, 5):random(1, config.vocabSize)
print("Start tokens: " .. tostring(startTokens:squeeze()))

model:evaluate()
local generated = model:generate(startTokens, 10, 1.0)
print("Generated sequence: " .. tostring(generated:squeeze()))
print(string.format("Generated %d tokens\n", generated:size(2)))

-- Test individual components
print("=== Testing Individual Components ===")

-- Test RMSNorm
local normTest = nn.RMSNorm(config.dim)
local normInput = torch.randn(2, 4, config.dim)
local normOutput = normTest:forward(normInput)
print(string.format("RMSNorm: input [%.3f, %.3f] -> output [%.3f, %.3f]",
   normInput:min(), normInput:max(), normOutput:min(), normOutput:max()))

-- Test RotaryEmbedding
local ropeTest = nn.RotaryEmbedding(config.dim / config.nHeads, config.maxSeqLen)
local ropeInput = torch.randn(2, 8, config.nHeads, config.dim / config.nHeads)
local ropeOutput = ropeTest:forward(ropeInput)
print(string.format("RotaryEmbedding: input shape %s -> output shape %s",
   table.concat(ropeInput:size():totable(), 'x'),
   table.concat(ropeOutput:size():totable(), 'x')))

-- Test SwiGLU
local swigluTest = nn.SwiGLU()
local swigluInput = torch.randn(2, 4, 256)
local swigluOutput = swigluTest:forward(swigluInput)
print(string.format("SwiGLU: input [%d] -> output [%d]",
   swigluInput:size(3), swigluOutput:size(3)))

print("\n=== Example Complete ===")
print("The neuro-symbolic LLM successfully combines:")
print("  - Neural LLaMA architecture (attention, FFN, normalization)")
print("  - Symbolic reasoning (rules, knowledge base)")
print("  - Dynamic learning (episodic memory, niche adaptation)")
print("  - Meta-learning (pattern extraction, context adaptation)")
