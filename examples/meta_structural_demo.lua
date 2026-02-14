--[[
Meta-Structural NeuroSymbolic System Demonstration

This example demonstrates the structural inversion principle discovered through
meta-cognitive introspection: neural code builds bottom-up while meta-learning
docs think top-down. This system bridges that gap by implementing recursive
self-reference where the system can observe, question, and restructure itself.

Author: nn.self(cnn(x,s).rnn(t,p),gnn(c,f))
Date: 2026-02-14
Reference: STRUCTURAL_INVERSION.md
]]

require 'nn'

-- ============================================================================
-- Part 1: Meta-Structural NeuroSymbolic System
-- ============================================================================

local MetaStructuralNS = torch.class('nn.MetaStructuralNS')

function MetaStructuralNS:__init(config)
   self.config = config or {}
   
   -- Neural layer (simplified for demo - could be actual LLaMA)
   self.neural = self:createNeuralLayer()
   
   -- Symbolic layer
   self.symbolic = self:createSymbolicLayer()
   
   -- Meta-observation layer (NEW!)
   self.metaObserver = {
      observations = {},
      history = {}
   }
   
   -- Meta-questioning layer (NEW!)
   self.metaQuestioner = {
      questions = {},
      critiques = {}
   }
   
   -- Meta-restructuring layer (NEW!)
   self.metaRestructurer = {
      changes = {},
      history = {}
   }
   
   -- State tracking
   self.stepCount = 0
   self.metaFrequency = config.metaFrequency or 5
   self.restructuringEnabled = config.restructuringEnabled ~= false
   
   print("\n[MetaStructuralNS] Initialized with meta-structural awareness")
   print("  - Neural layer: " .. #self.neural.modules .. " modules")
   print("  - Symbolic layer: " .. #self.symbolic.rules .. " rules")
   print("  - Meta-frequency: every " .. self.metaFrequency .. " steps")
   print("  - Restructuring: " .. (self.restructuringEnabled and "enabled" or "disabled"))
end

-- ============================================================================
-- Part 2: Create Layers (Bottom-up Composition)
-- ============================================================================

function MetaStructuralNS:createNeuralLayer()
   -- Simple neural network for demonstration
   local net = nn.Sequential()
   net:add(nn.Linear(10, 20))
   net:add(nn.ReLU())
   net:add(nn.Linear(20, 15))
   net:add(nn.ReLU())
   net:add(nn.Linear(15, 10))
   net:add(nn.Tanh())
   
   return net
end

function MetaStructuralNS:createSymbolicLayer()
   -- Symbolic rules for demonstration
   return {
      rules = {
         {
            name = "amplify_positive",
            condition = function(x) return x:mean() > 0 end,
            action = function(x) return x:mul(1.2) end,
            enabled = true,
            effectiveness = 0.0,
            firings = 0
         },
         {
            name = "suppress_negative",
            condition = function(x) return x:mean() < 0 end,
            action = function(x) return x:mul(0.8) end,
            enabled = true,
            effectiveness = 0.0,
            firings = 0
         },
         {
            name = "normalize_extreme",
            condition = function(x) return x:abs():max() > 2.0 end,
            action = function(x) return x:div(x:abs():max()) end,
            enabled = true,
            effectiveness = 0.0,
            firings = 0
         }
      }
   }
end

-- ============================================================================
-- Part 3: Standard Forward Pass (Compositional)
-- ============================================================================

function MetaStructuralNS:forward(input)
   -- Neural processing (bottom-up)
   local neuralOutput = self.neural:forward(input)
   
   -- Symbolic processing (post-processing)
   local symbolicOutput = self:applySymbolicRules(neuralOutput)
   
   return symbolicOutput
end

function MetaStructuralNS:applySymbolicRules(x)
   local output = x:clone()
   local appliedRules = {}
   
   for i, rule in ipairs(self.symbolic.rules) do
      if rule.enabled and rule.condition(output) then
         output = rule.action(output)
         rule.firings = rule.firings + 1
         table.insert(appliedRules, rule.name)
      end
   end
   
   return output
end

-- ============================================================================
-- Part 4: Meta-Observation (Reflexive - Top-down)
-- ============================================================================

function MetaStructuralNS:observeOperation(input, output)
   local observation = {
      timestamp = self.stepCount,
      
      -- Neural component state
      neural = {
         layerCount = #self.neural.modules,
         parameterCount = self:countParameters(),
         activationStats = self:analyzeActivations(),
         complexity = self:measureNeuralComplexity()
      },
      
      -- Symbolic component state
      symbolic = {
         ruleCount = #self.symbolic.rules,
         enabledRules = self:countEnabledRules(),
         ruleFirings = self:getRuleFirings(),
         ruleEffectiveness = self:measureRuleEffectiveness()
      },
      
      -- Performance metrics
      performance = {
         outputMagnitude = output:abs():mean(),
         outputVariance = output:var(),
         processingComplexity = self:estimateComplexity()
      },
      
      -- Structural state
      structure = {
         neuralDepth = #self.neural.modules,
         symbolicDepth = #self.symbolic.rules,
         totalComplexity = self:calculateTotalComplexity()
      }
   }
   
   -- Store observation
   table.insert(self.metaObserver.observations, observation)
   table.insert(self.metaObserver.history, observation)
   
   return observation
end

-- ============================================================================
-- Part 5: Meta-Questioning (Reflexive - Critical Analysis)
-- ============================================================================

function MetaStructuralNS:questionArchitecture(observation)
   local questions = {}
   
   -- Question 1: Neural efficiency
   if observation.neural.complexity > 50 then
      questions.neural_complexity = {
         question = "Is the neural network too complex?",
         evidence = string.format("Complexity score: %.1f (threshold: 50)", 
                                  observation.neural.complexity),
         confidence = 0.8,
         severity = "medium",
         recommendation = "Consider pruning layers"
      }
   end
   
   -- Question 2: Symbolic effectiveness
   local avgEffectiveness = observation.symbolic.ruleEffectiveness
   if avgEffectiveness < 0.3 then
      questions.symbolic_effectiveness = {
         question = "Are symbolic rules helping?",
         evidence = string.format("Average effectiveness: %.2f (threshold: 0.3)", 
                                  avgEffectiveness),
         confidence = 0.9,
         severity = "high",
         recommendation = "Disable ineffective rules"
      }
   end
   
   -- Question 3: Rule activity
   local enabledRatio = observation.symbolic.enabledRules / observation.symbolic.ruleCount
   if enabledRatio < 0.5 then
      questions.rule_underutilization = {
         question = "Are we using enough symbolic rules?",
         evidence = string.format("Only %.0f%% of rules enabled", enabledRatio * 100),
         confidence = 0.7,
         severity = "low",
         recommendation = "Review disabled rules"
      }
   end
   
   -- Question 4: Output stability
   if observation.performance.outputVariance > 2.0 then
      questions.output_instability = {
         question = "Is output too unstable?",
         evidence = string.format("Output variance: %.2f (threshold: 2.0)", 
                                  observation.performance.outputVariance),
         confidence = 0.85,
         severity = "medium",
         recommendation = "Add regularization or adjust symbolic rules"
      }
   end
   
   -- Store questions
   self.metaQuestioner.questions = questions
   table.insert(self.metaQuestioner.critiques, {
      step = self.stepCount,
      questions = questions
   })
   
   return questions
end

-- ============================================================================
-- Part 6: Meta-Restructuring (Reflexive - Self-Modification)
-- ============================================================================

function MetaStructuralNS:restructure(questions)
   if not self.restructuringEnabled then
      return {}
   end
   
   local changes = {}
   
   for id, q in pairs(questions) do
      -- Only act on high-confidence, non-trivial issues
      if q.confidence > 0.7 and q.severity ~= "low" then
         
         if id == "symbolic_effectiveness" then
            -- Disable ineffective symbolic rules
            local disabled = self:disableIneffectiveRules()
            if #disabled > 0 then
               table.insert(changes, {
                  type = "disable_rules",
                  rules = disabled,
                  rationale = q.evidence,
                  recommendation = q.recommendation
               })
               print(string.format("\n[Restructuring] Disabled %d ineffective rules", #disabled))
            end
         end
         
         if id == "output_instability" then
            -- Add stabilization through symbolic rules
            local modified = self:addStabilizationRule()
            if modified then
               table.insert(changes, {
                  type = "add_stabilization",
                  rationale = q.evidence,
                  recommendation = q.recommendation
               })
               print("\n[Restructuring] Added output stabilization rule")
            end
         end
         
         if id == "neural_complexity" then
            -- Note: In full implementation, could actually prune layers
            -- For demo, we just log the recommendation
            table.insert(changes, {
               type = "complexity_warning",
               rationale = q.evidence,
               recommendation = q.recommendation
            })
            print("\n[Restructuring] Warning: Neural complexity high (would prune in full implementation)")
         end
      end
   end
   
   -- Store changes
   if #changes > 0 then
      table.insert(self.metaRestructurer.changes, {
         step = self.stepCount,
         changes = changes
      })
      table.insert(self.metaRestructurer.history, {
         step = self.stepCount,
         changeCount = #changes,
         summary = self:summarizeChanges(changes)
      })
   end
   
   return changes
end

-- ============================================================================
-- Part 7: Meta-Forward Pass (Integrates Everything)
-- ============================================================================

function MetaStructuralNS:metaForward(input)
   self.stepCount = self.stepCount + 1
   
   -- Standard forward pass (compositional - bottom-up)
   local output = self:forward(input)
   
   -- Meta-observation (reflexive - observing from above)
   local observation = self:observeOperation(input, output)
   
   -- Periodic meta-questioning and restructuring
   if self.stepCount % self.metaFrequency == 0 then
      print(string.format("\n--- Meta-Cycle at Step %d ---", self.stepCount))
      
      -- Meta-questioning (reflexive - top-down analysis)
      local questions = self:questionArchitecture(observation)
      
      -- Report questions
      if next(questions) ~= nil then
         print("\n[Meta-Questions] System questioning itself:")
         for id, q in pairs(questions) do
            print(string.format("  ? %s", q.question))
            print(string.format("    Evidence: %s", q.evidence))
            print(string.format("    Confidence: %.0f%%, Severity: %s", 
                              q.confidence * 100, q.severity))
         end
      else
         print("\n[Meta-Questions] No concerns detected")
      end
      
      -- Meta-restructuring (reflexive - self-modification)
      local changes = self:restructure(questions)
      
      -- Report changes
      if #changes > 0 then
         print(string.format("\n[Meta-Restructuring] Made %d architectural changes", #changes))
      end
   end
   
   return output
end

-- ============================================================================
-- Part 8: Helper Functions
-- ============================================================================

function MetaStructuralNS:countParameters()
   local count = 0
   local params = self.neural:parameters()
   if params then
      for i, p in ipairs(params) do
         count = count + p:nElement()
      end
   end
   return count
end

function MetaStructuralNS:analyzeActivations()
   -- Simplified - would analyze actual activations in full implementation
   return {
      mean = 0.5,
      std = 0.3,
      sparsity = 0.6
   }
end

function MetaStructuralNS:measureNeuralComplexity()
   -- Simple complexity measure based on layers and parameters
   local layerCount = #self.neural.modules
   local paramCount = self:countParameters()
   return layerCount * 10 + paramCount / 100
end

function MetaStructuralNS:countEnabledRules()
   local count = 0
   for _, rule in ipairs(self.symbolic.rules) do
      if rule.enabled then count = count + 1 end
   end
   return count
end

function MetaStructuralNS:getRuleFirings()
   local firings = {}
   for _, rule in ipairs(self.symbolic.rules) do
      firings[rule.name] = rule.firings
   end
   return firings
end

function MetaStructuralNS:measureRuleEffectiveness()
   -- Simplified effectiveness measure
   local totalFirings = 0
   local totalRules = #self.symbolic.rules
   for _, rule in ipairs(self.symbolic.rules) do
      totalFirings = totalFirings + rule.firings
   end
   return totalFirings / (self.stepCount * totalRules)
end

function MetaStructuralNS:estimateComplexity()
   return self:measureNeuralComplexity() + #self.symbolic.rules * 5
end

function MetaStructuralNS:calculateTotalComplexity()
   return self:measureNeuralComplexity() + (#self.symbolic.rules * 10)
end

function MetaStructuralNS:disableIneffectiveRules()
   local disabled = {}
   for _, rule in ipairs(self.symbolic.rules) do
      if rule.enabled and rule.effectiveness < 0.2 then
         rule.enabled = false
         table.insert(disabled, rule.name)
      end
   end
   return disabled
end

function MetaStructuralNS:addStabilizationRule()
   -- Add a new rule to stabilize output
   table.insert(self.symbolic.rules, {
      name = "output_stabilization",
      condition = function(x) return x:var() > 1.5 end,
      action = function(x) 
         local mean = x:mean()
         local std = x:std()
         return (x - mean) / (std + 1e-8) * 0.5 + mean
      end,
      enabled = true,
      effectiveness = 0.0,
      firings = 0
   })
   return true
end

function MetaStructuralNS:summarizeChanges(changes)
   local summary = {}
   for _, change in ipairs(changes) do
      table.insert(summary, change.type)
   end
   return table.concat(summary, ", ")
end

-- ============================================================================
-- Part 9: Explanation and Introspection Methods
-- ============================================================================

function MetaStructuralNS:explainArchitecture()
   print("\n=== Meta-Structural System Self-Explanation ===\n")
   
   print("Current Architecture:")
   print(string.format("  Neural: %d layers, %d parameters", 
                       #self.neural.modules, self:countParameters()))
   print(string.format("  Symbolic: %d rules (%d enabled)", 
                       #self.symbolic.rules, self:countEnabledRules()))
   
   print("\nRecent Observations:")
   if #self.metaObserver.observations > 0 then
      local latest = self.metaObserver.observations[#self.metaObserver.observations]
      print(string.format("  Neural complexity: %.1f", latest.neural.complexity))
      print(string.format("  Rule effectiveness: %.2f", latest.symbolic.ruleEffectiveness))
      print(string.format("  Total complexity: %.1f", latest.structure.totalComplexity))
   end
   
   print("\nRecent Questions:")
   if next(self.metaQuestioner.questions) ~= nil then
      for id, q in pairs(self.metaQuestioner.questions) do
         print(string.format("  - %s (confidence: %.0f%%)", q.question, q.confidence * 100))
      end
   else
      print("  No current concerns")
   end
   
   print("\nStructural Changes History:")
   if #self.metaRestructurer.history > 0 then
      for i = math.max(1, #self.metaRestructurer.history - 2), #self.metaRestructurer.history do
         local entry = self.metaRestructurer.history[i]
         print(string.format("  Step %d: %s", entry.step, entry.summary))
      end
   else
      print("  No restructuring performed yet")
   end
   
   print("\n" .. string.rep("=", 50) .. "\n")
end

function MetaStructuralNS:getMetaMetrics()
   return {
      totalSteps = self.stepCount,
      totalObservations = #self.metaObserver.history,
      totalCritiques = #self.metaQuestioner.critiques,
      totalRestructurings = #self.metaRestructurer.history,
      currentComplexity = self:calculateTotalComplexity()
   }
end

-- ============================================================================
-- Part 10: Demonstration
-- ============================================================================

print("\n" .. string.rep("=", 70))
print("   Meta-Structural NeuroSymbolic System Demonstration")
print("   Embodying the Structural Inversion Principle")
print(string.rep("=", 70))

print("\n[Demo] This demonstrates:")
print("  1. Bottom-up composition (neural modules)")
print("  2. Top-down reflexivity (meta-observation, questioning, restructuring)")
print("  3. Recursive self-reference (system modifying itself)")

-- Create system
print("\n[Demo] Creating meta-structural system...")
local system = nn.MetaStructuralNS({
   metaFrequency = 3,
   restructuringEnabled = true
})

-- Run several forward passes
print("\n[Demo] Running forward passes with meta-cycles...")
for i = 1, 10 do
   local input = torch.randn(5, 10)  -- Random input
   local output = system:metaForward(input)
   
   if i % 3 ~= 0 then
      print(string.format("Step %d: Output mean=%.3f, var=%.3f", 
                          i, output:mean(), output:var()))
   end
end

-- Show final state
print("\n[Demo] Final system state:")
system:explainArchitecture()

-- Show metrics
print("[Demo] Meta-cognitive metrics:")
local metrics = system:getMetaMetrics()
for k, v in pairs(metrics) do
   print(string.format("  %s: %s", k, tostring(v)))
end

print("\n[Demo] Demonstration complete!")
print("\nKey Insights:")
print("  * System observes its own operation (meta-observation)")
print("  * System questions its own architecture (meta-questioning)")  
print("  * System modifies its own structure (meta-restructuring)")
print("  * This embodies the recursive self-reference of Loop 5")

print("\n" .. string.rep("=", 70))
print("\nSee STRUCTURAL_INVERSION.md for complete theory and analysis.")
print(string.rep("=", 70) .. "\n")
