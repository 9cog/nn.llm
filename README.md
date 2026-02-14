[![Build Status](https://travis-ci.org/torch/nn.svg?branch=master)](https://travis-ci.org/torch/nn)
<a name="nn.dok"></a>
# Neural Network Package #

This package provides an easy and modular way to build and train simple or complex neural networks using [Torch](https://github.com/torch/torch7/blob/master/README.md):
 * Modules are the bricks used to build neural networks. Each are themselves neural networks, but can be combined with other networks using containers to create complex neural networks:
   * [Module](doc/module.md#nn.Module): abstract class inherited by all modules;
   * [Containers](doc/containers.md#nn.Containers): composite and decorator classes like [`Sequential`](doc/containers.md#nn.Sequential), [`Parallel`](doc/containers.md#nn.Parallel), [`Concat`](doc/containers.md#nn.Concat) and [`NaN`](doc/containers.md#nn.NaN);
   * [Transfer functions](doc/transfer.md#nn.transfer.dok): non-linear functions like [`Tanh`](doc/transfer.md#nn.Tanh) and [`Sigmoid`](doc/transfer.md#nn.Sigmoid);
   * [Simple layers](doc/simple.md#nn.simplelayers.dok): like [`Linear`](doc/simple.md#nn.Linear), [`Mean`](doc/simple.md#nn.Mean), [`Max`](doc/simple.md#nn.Max) and [`Reshape`](doc/simple.md#nn.Reshape);
   * [Table layers](doc/table.md#nn.TableLayers): layers for manipulating `table`s like [`SplitTable`](doc/table.md#nn.SplitTable), [`ConcatTable`](doc/table.md#nn.ConcatTable) and [`JoinTable`](doc/table.md#nn.JoinTable);
   * [Convolution layers](doc/convolution.md#nn.convlayers.dok): [`Temporal`](doc/convolution.md#nn.TemporalModules),  [`Spatial`](doc/convolution.md#nn.SpatialModules) and [`Volumetric`](doc/convolution.md#nn.VolumetricModules) convolutions;
 * Criterions compute a gradient according to a given loss function given an input and a target:
   * [Criterions](doc/criterion.md#nn.Criterions): a list of all criterions, including [`Criterion`](doc/criterion.md#nn.Criterion), the abstract class;
   * [`MSECriterion`](doc/criterion.md#nn.MSECriterion): the Mean Squared Error criterion used for regression;
   * [`ClassNLLCriterion`](doc/criterion.md#nn.ClassNLLCriterion): the Negative Log Likelihood criterion used for classification;
 * Additional documentation:
   * [Overview](doc/overview.md#nn.overview.dok) of the package essentials including modules, containers and training;
   * [Training](doc/training.md#nn.traningneuralnet.dok): how to train a neural network using [`StochasticGradient`](doc/training.md#nn.StochasticGradient);
   * [Testing](doc/testing.md): how to test your modules.
   * [Experimental Modules](https://github.com/clementfarabet/lua---nnx/blob/master/README.md): a package containing experimental modules and criteria.
 * LLM and Learning Resources:
   * [LLM Implementation](LLM_README.md): Neuro-symbolic LLM with dynamic learning for niche construction
   * [Interesting Learnings](INTERESTING_LEARNINGS.md): Deep dive into key insights and patterns from the codebase
   * [Quick Reference](LEARNINGS_QUICK_REFERENCE.md): Concise guide to the most interesting learnings
   * [Interactive Demo](examples/interesting_learnings_demo.lua): Hands-on demonstration of key concepts
 * Meta-Learning Resources:
   * [**🔬 Structural Inversion**](STRUCTURAL_INVERSION.md): **🔬 META-COGNITIVE DISCOVERY - How code architecture and conceptual understanding exhibit inverse organizational principles**
   * [**🌟 Five Loops Complete Guide**](FIVE_LOOPS_COMPLETE_GUIDE.md): **🌟 ULTIMATE INTEGRATION - All five learning loops unified from implementation to ontology**
   * [**🔮 Quintuple-Loop Ontology**](QUINTUPLE_LOOP_ONTOLOGY.md): **🔮 THE DEEPEST LEVEL - Exploring the ground of being and the nature of existence that enables learning**
   * [**⚡ Quintuple-Loop Quick Reference**](QUINTUPLE_LOOP_QUICK_REFERENCE.md): **⚡ One-page guide to Loop 5 - when to use and key insights**
   * [**📖 Quintuple-Loop Summary**](QUINTUPLE_LOOP_SUMMARY.md): **Executive summary of the Loop 5 discovery - being and knowing unified**
   * [**💫 Quintuple-Loop Example**](examples/quintuple_loop_example.lua): **Code demonstrating ontological awareness in practice**
   * [**Four Loops Visual Guide**](FOUR_LOOPS_VISUAL_GUIDE.md): **Complete visual guide to all four learning loops with practical examples**
   * [**Four Loops Quick Reference**](FOUR_LOOPS_QUICK_REFERENCE.md): **One-page reference card for rapid loop identification and decision-making**
   * [Learning Map](LEARNING_MAP.md): Visual guide to navigating all learning resources
   * [Three Loops Quick Guide](THREE_LOOPS_QUICK_GUIDE.md): Practical reference for choosing and using learning loops
   * [Learning Evolution](LEARNING_EVOLUTION.md): Synthesis showing the journey through all three learning loops
   * [Triple-Loop Learning](TRIPLE_LOOP_LEARNING.md): Examining the learning process itself - how we learn to learn
   * [**Quadruple-Loop Epistemology**](QUADRUPLE_LOOP_EPISTEMOLOGY.md): **Deep philosophical inquiry into the nature of understanding and knowledge itself**
   * [**Quadruple-Loop Summary**](QUADRUPLE_LOOP_SUMMARY.md): **Executive summary of the loop 4 discovery and its implications**
   * [Meta-Learning Reflection](META_LEARNING_REFLECTION.md): Double-loop learning analysis questioning what "interesting" means
   * [Double-Loop Insights](DOUBLE_LOOP_INSIGHTS.md): Actionable wisdom from questioning assumptions
   * [Learning Loops Comparison](LEARNING_LOOPS_COMPARISON.md): Visual guide comparing single-loop vs. double-loop learning
   * [Double-Loop Field Guide](DOUBLE_LOOP_FIELD_GUIDE.md): Practical application guide with templates and workflows
   * [Double-Loop Summary](DOUBLE_LOOP_SUMMARY.md): Executive summary of the double-loop learning journey
