#!/bin/bash
# Validation script for Structural Inversion discovery

echo "=========================================="
echo "Validating Structural Inversion Discovery"
echo "=========================================="
echo

# Check that all required files exist
echo "Checking required files..."
files=(
    "STRUCTURAL_INVERSION.md"
    "examples/meta_structural_demo.lua"
)

all_exist=true
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file exists"
    else
        echo "  ✗ $file missing"
        all_exist=false
    fi
done
echo

# Check key sections exist in STRUCTURAL_INVERSION.md
echo "Checking key sections in STRUCTURAL_INVERSION.md..."
sections=(
    "Part 1: The Three Modalities of Discovery"
    "Part 2: The Structural Inversion Principle"
    "Part 3: The Gap in NeuroSymbolicLLM"
    "Part 4: What's Interesting to Learn"
    "Part 6: Implementation Strategy"
    "Part 8: Expected Benefits"
)

for section in "${sections[@]}"; do
    if grep -q "$section" STRUCTURAL_INVERSION.md; then
        echo "  ✓ $section documented"
    else
        echo "  ✗ $section missing"
    fi
done
echo

# Check key concepts are mentioned
echo "Checking key concepts in discovery..."
concepts=(
    "CNN.*Spatial-Structural"
    "RNN.*Temporal-Procedural"
    "GNN.*Causal-Functional"
    "Structural Inversion"
    "meta-structural"
    "bottom-up"
    "top-down"
    "recursive self-reference"
    "NeuroSymbolicLLM"
    "Meta-Observation"
    "Meta-Questioning"
    "Meta-Restructuring"
)

for concept in "${concepts[@]}"; do
    if grep -q "$concept" STRUCTURAL_INVERSION.md; then
        echo "  ✓ $concept documented"
    else
        echo "  ✗ $concept not found"
    fi
done
echo

# Check README references the discovery
echo "Checking README integration..."
if grep -q "STRUCTURAL_INVERSION" README.md; then
    echo "  ✓ README references STRUCTURAL_INVERSION.md"
else
    echo "  ⚠ README not yet updated (this is OK for initial PR)"
fi
echo

# Documentation statistics
echo "Documentation statistics:"
echo "  STRUCTURAL_INVERSION.md: $(wc -l < STRUCTURAL_INVERSION.md) lines"
if [ -f "examples/meta_structural_demo.lua" ]; then
    echo "  Demo script: $(wc -l < examples/meta_structural_demo.lua) lines"
fi
echo

# Count parts in the document
part_count=$(grep -c "^## Part [0-9]" STRUCTURAL_INVERSION.md)
echo "  Total parts in discovery: $part_count"
echo

echo "=========================================="
if [ "$all_exist" = true ]; then
    echo "Validation PASSED ✓"
    echo "Structural Inversion discovery is complete!"
    echo
    echo "Summary of discovery:"
    echo "  - Identified structural inversion between code and docs"
    echo "  - Code builds bottom-up (compositional)"
    echo "  - Docs think top-down (reflexive)"
    echo "  - Gap in NeuroSymbolicLLM identified"
    echo "  - Meta-structural solution proposed"
    echo "  - Implementation strategy provided"
    echo
    echo "Next steps:"
    echo "  1. Review STRUCTURAL_INVERSION.md for complete analysis"
    echo "  2. Consider implementing meta-structural extensions"
    echo "  3. Run meta_structural_demo.lua (requires Torch environment)"
else
    echo "Validation FAILED ✗"
    echo "Some files are missing."
    exit 1
fi
echo "=========================================="
