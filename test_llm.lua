-- Tests for LLM modules
-- Test the individual components of the neuro-symbolic LLM

require 'nn'

local llmtest = {}
local mytester = torch.Tester()
local precision = 1e-4

-- Test RMSNorm
function llmtest.RMSNorm()
   print('\nTesting RMSNorm...')
   
   local dim = 32
   local batchSize = 2
   local seqLen = 4
   
   -- 2D test
   local module = nn.RMSNorm(dim)
   local input2d = torch.randn(batchSize, dim)
   local output2d = module:forward(input2d)
   
   mytester:asserteq(output2d:size(1), batchSize, 'RMSNorm 2D: batch size')
   mytester:asserteq(output2d:size(2), dim, 'RMSNorm 2D: dimension')
   
   -- Check that output is normalized (approximate RMS = 1)
   local rms = torch.sqrt(output2d:pow(2):mean(2))
   mytester:assertlt(torch.abs(rms:mean() - 1.0), 0.5, 'RMSNorm 2D: RMS approximately 1')
   
   -- 3D test
   local input3d = torch.randn(batchSize, seqLen, dim)
   local output3d = module:forward(input3d)
   
   mytester:asserteq(output3d:size(1), batchSize, 'RMSNorm 3D: batch size')
   mytester:asserteq(output3d:size(2), seqLen, 'RMSNorm 3D: sequence length')
   mytester:asserteq(output3d:size(3), dim, 'RMSNorm 3D: dimension')
   
   -- Test gradient
   local gradOutput = torch.randn(batchSize, seqLen, dim)
   local gradInput = module:updateGradInput(input3d, gradOutput)
   
   mytester:asserteq(gradInput:size(1), batchSize, 'RMSNorm: gradInput batch size')
   mytester:asserteq(gradInput:size(2), seqLen, 'RMSNorm: gradInput seq len')
   mytester:asserteq(gradInput:size(3), dim, 'RMSNorm: gradInput dimension')
   
   print('✓ RMSNorm tests passed')
end

-- Test RotaryEmbedding
function llmtest.RotaryEmbedding()
   print('\nTesting RotaryEmbedding...')
   
   local dim = 64
   local maxSeqLen = 128
   local batchSize = 2
   local seqLen = 8
   local nHeads = 4
   
   local module = nn.RotaryEmbedding(dim, maxSeqLen)
   local input = torch.randn(batchSize, seqLen, nHeads, dim)
   local output = module:forward(input)
   
   mytester:asserteq(output:size(1), batchSize, 'RoPE: batch size')
   mytester:asserteq(output:size(2), seqLen, 'RoPE: sequence length')
   mytester:asserteq(output:size(3), nHeads, 'RoPE: number of heads')
   mytester:asserteq(output:size(4), dim, 'RoPE: head dimension')
   
   -- Check that magnitudes are preserved (approximately)
   local inputNorm = torch.norm(input)
   local outputNorm = torch.norm(output)
   mytester:assertlt(torch.abs(inputNorm - outputNorm) / inputNorm, 0.1, 
      'RoPE: magnitude preservation')
   
   -- Test gradient
   local gradOutput = torch.randn(batchSize, seqLen, nHeads, dim)
   local gradInput = module:updateGradInput(input, gradOutput)
   
   mytester:asserteq(gradInput:size(1), batchSize, 'RoPE: gradInput shape')
   
   print('✓ RotaryEmbedding tests passed')
end

-- Test SwiGLU
function llmtest.SwiGLU()
   print('\nTesting SwiGLU...')
   
   local batchSize = 2
   local seqLen = 4
   local dim = 128  -- Must be even
   
   local module = nn.SwiGLU()
   local input = torch.randn(batchSize, seqLen, dim)
   local output = module:forward(input)
   
   mytester:asserteq(output:size(1), batchSize, 'SwiGLU: batch size')
   mytester:asserteq(output:size(2), seqLen, 'SwiGLU: sequence length')
   mytester:asserteq(output:size(3), dim / 2, 'SwiGLU: output dimension is half input')
   
   -- Test gradient
   local gradOutput = torch.randn(batchSize, seqLen, dim / 2)
   local gradInput = module:updateGradInput(input, gradOutput)
   
   mytester:asserteq(gradInput:size(3), dim, 'SwiGLU: gradInput dimension')
   
   print('✓ SwiGLU tests passed')
end

-- Test MultiHeadAttention
function llmtest.MultiHeadAttention()
   print('\nTesting MultiHeadAttention...')
   
   local dim = 64
   local nHeads = 4
   local nKVHeads = 2
   local batchSize = 2
   local seqLen = 8
   
   local module = nn.MultiHeadAttention(dim, nHeads, nKVHeads, 0.0)
   local input = torch.randn(batchSize, seqLen, dim)
   local output = module:forward(input)
   
   mytester:asserteq(output:size(1), batchSize, 'Attention: batch size')
   mytester:asserteq(output:size(2), seqLen, 'Attention: sequence length')
   mytester:asserteq(output:size(3), dim, 'Attention: dimension')
   
   -- Check that output is not all zeros
   mytester:assertne(output:abs():sum(), 0, 'Attention: output is not zero')
   
   print('✓ MultiHeadAttention tests passed')
end

-- Test FeedForward
function llmtest.FeedForward()
   print('\nTesting FeedForward...')
   
   local dim = 64
   local hiddenDim = 256
   local batchSize = 2
   local seqLen = 8
   
   local module = nn.FeedForward(dim, hiddenDim, 0.0)
   local input = torch.randn(batchSize, seqLen, dim)
   local output = module:forward(input)
   
   mytester:asserteq(output:size(1), batchSize, 'FFN: batch size')
   mytester:asserteq(output:size(2), seqLen, 'FFN: sequence length')
   mytester:asserteq(output:size(3), dim, 'FFN: dimension')
   
   -- Check that output is not all zeros
   mytester:assertne(output:abs():sum(), 0, 'FFN: output is not zero')
   
   print('✓ FeedForward tests passed')
end

-- Test TransformerBlock
function llmtest.TransformerBlock()
   print('\nTesting TransformerBlock...')
   
   local dim = 64
   local nHeads = 4
   local nKVHeads = 2
   local hiddenDim = 256
   local batchSize = 2
   local seqLen = 8
   
   local module = nn.TransformerBlock(dim, nHeads, nKVHeads, hiddenDim, 0.0)
   local input = torch.randn(batchSize, seqLen, dim)
   local output = module:forward(input)
   
   mytester:asserteq(output:size(1), batchSize, 'TransformerBlock: batch size')
   mytester:asserteq(output:size(2), seqLen, 'TransformerBlock: sequence length')
   mytester:asserteq(output:size(3), dim, 'TransformerBlock: dimension')
   
   -- Check that residual connections work (output != input)
   local diff = torch.norm(output - input)
   mytester:assertne(diff, 0, 'TransformerBlock: output differs from input')
   
   print('✓ TransformerBlock tests passed')
end

-- Test LLaMA
function llmtest.LLaMA()
   print('\nTesting LLaMA...')
   
   local config = {
      vocabSize = 1000,
      dim = 64,
      nLayers = 2,
      nHeads = 4,
      nKVHeads = 2,
      hiddenDim = 256,
      maxSeqLen = 128,
      dropout = 0.0,
      tieWeights = false
   }
   
   local model = nn.LLaMA(config)
   local batchSize = 2
   local seqLen = 8
   
   -- Test forward pass
   local input = torch.LongTensor(batchSize, seqLen):random(1, config.vocabSize)
   local output = model:forward(input)
   
   mytester:asserteq(output:size(1), batchSize, 'LLaMA: batch size')
   mytester:asserteq(output:size(2), seqLen, 'LLaMA: sequence length')
   mytester:asserteq(output:size(3), config.vocabSize, 'LLaMA: vocabulary size')
   
   -- Test that output is not all zeros
   mytester:assertne(output:abs():sum(), 0, 'LLaMA: output is not zero')
   
   -- Test generation
   -- Note: Use tokens that are unlikely to be EOS (token 2) to test extension
   local startTokens = torch.LongTensor(1, 3)
   startTokens:fill(100)  -- Use non-EOS tokens
   local generated = model:generate(startTokens, 5, 1.0)
   
   mytester:asserteq(generated:size(1), 1, 'LLaMA generate: batch size')
   -- May or may not extend if EOS is generated, so just check it's at least the input size
   mytester:assert(generated:size(2) >= 3, 'LLaMA generate: sequence at least input size')
   mytester:assert(generated:size(2) <= 3 + 5, 'LLaMA generate: sequence within bounds')
   
   -- Test parameters
   local params, gradParams = model:parameters()
   mytester:assert(#params > 0, 'LLaMA: has parameters')
   mytester:asserteq(#params, #gradParams, 'LLaMA: param count matches grad param count')
   
   print('✓ LLaMA tests passed')
end

-- Test NeuroSymbolicLLM
function llmtest.NeuroSymbolicLLM()
   print('\nTesting NeuroSymbolicLLM...')
   
   local config = {
      vocabSize = 1000,
      dim = 64,
      nLayers = 2,
      nHeads = 4,
      nKVHeads = 2,
      hiddenDim = 256,
      maxSeqLen = 128,
      dropout = 0.0,
      nicheAdaptation = true,
      learningRate = 0.01,
      memorySize = 10
   }
   
   local model = nn.NeuroSymbolicLLM(config)
   local batchSize = 2
   local seqLen = 8
   
   -- Test forward pass
   local input = torch.LongTensor(batchSize, seqLen):random(1, config.vocabSize)
   local output = model:forward(input)
   
   mytester:asserteq(output:size(1), batchSize, 'NeuroSymbolic: batch size')
   mytester:asserteq(output:size(2), seqLen, 'NeuroSymbolic: sequence length')
   mytester:asserteq(output:size(3), config.vocabSize, 'NeuroSymbolic: vocabulary size')
   
   -- Test symbolic knowledge
   model:addSymbol('test_key', {value = 42})
   local retrieved = model:querySymbolic('test_key')
   mytester:asserteq(retrieved.value, 42, 'NeuroSymbolic: symbol storage')
   
   -- Test symbolic rules
   model:addSymbolicRule({
      condition = function(ctx) return true end,
      action = function(out, ctx) return out end,
      weight = 1.0
   })
   
   -- Test episodic memory
   local initialMemory = model:getAdaptationMetrics().episodicMemorySize
   model:updateEpisodicMemory({data = 'test'})
   local newMemory = model:getAdaptationMetrics().episodicMemorySize
   mytester:asserteq(newMemory, initialMemory + 1, 'NeuroSymbolic: episodic memory')
   
   -- Test niche adaptation
   model:adaptToNiche({
      success = true,
      context = 'test_context',
      pattern = 'test_pattern'
   })
   
   local metrics = model:getAdaptationMetrics()
   mytester:assert(metrics.adaptationRate >= 0, 'NeuroSymbolic: adaptation rate')
   
   -- Test generation (use non-EOS tokens to ensure extension)
   local startTokens = torch.LongTensor(1, 3)
   startTokens:fill(100)  -- Use non-EOS token
   local generated = model:generate(startTokens, 5, 1.0)
   mytester:assert(generated:size(2) >= 3, 'NeuroSymbolic generate: sequence at least input size')
   
   print('✓ NeuroSymbolicLLM tests passed')
end

-- Run all tests
function llmtest.runAll()
   print('\n========================================')
   print('Running LLM Module Tests')
   print('========================================')
   
   llmtest.RMSNorm()
   llmtest.RotaryEmbedding()
   llmtest.SwiGLU()
   llmtest.MultiHeadAttention()
   llmtest.FeedForward()
   llmtest.TransformerBlock()
   llmtest.LLaMA()
   llmtest.NeuroSymbolicLLM()
   
   print('\n========================================')
   print('All LLM tests completed!')
   print('========================================\n')
end

-- Set up test suite
local function setupTests()
   for name, func in pairs(llmtest) do
      if name ~= 'runAll' then
         mytester:add(func, name)
      end
   end
   return mytester
end

-- Can be run standalone or integrated
if not nn.test then
   nn.test = setupTests()
   nn.test:run()
else
   -- Integrate with existing test suite
   for name, func in pairs(llmtest) do
      if name ~= 'runAll' then
         nn.test:add(func, 'LLM_' .. name)
      end
   end
end

return llmtest
