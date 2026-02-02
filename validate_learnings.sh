#!/bin/bash
# Validation script for learning documentation

echo "=========================================="
echo "Validating Learning Documentation"
echo "=========================================="
echo

# Check that all required files exist
echo "Checking required files..."
files=(
    "INTERESTING_LEARNINGS.md"
    "LEARNINGS_QUICK_REFERENCE.md"
    "examples/interesting_learnings_demo.lua"
    "README.md"
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

# Check that all 7 learnings are documented
echo "Checking learning sections in INTERESTING_LEARNINGS.md..."
for i in {1..7}; do
    if grep -q "## Learning $i:" INTERESTING_LEARNINGS.md; then
        title=$(grep "## Learning $i:" INTERESTING_LEARNINGS.md)
        echo "  ✓ Learning $i documented: $title"
    else
        echo "  ✗ Learning $i missing"
    fi
done
echo

# Check that demo script is executable
echo "Checking demo script..."
if [ -x "examples/interesting_learnings_demo.lua" ]; then
    echo "  ✓ Demo script is executable"
else
    echo "  ✗ Demo script not executable"
fi
echo

# Check that README references the learnings
echo "Checking README references..."
if grep -q "INTERESTING_LEARNINGS.md" README.md; then
    echo "  ✓ README references INTERESTING_LEARNINGS.md"
else
    echo "  ✗ README missing reference to INTERESTING_LEARNINGS.md"
fi

if grep -q "LEARNINGS_QUICK_REFERENCE.md" README.md; then
    echo "  ✓ README references LEARNINGS_QUICK_REFERENCE.md"
else
    echo "  ✗ README missing reference to LEARNINGS_QUICK_REFERENCE.md"
fi
echo

# Count total content
echo "Documentation statistics:"
echo "  INTERESTING_LEARNINGS.md: $(wc -l < INTERESTING_LEARNINGS.md) lines"
echo "  LEARNINGS_QUICK_REFERENCE.md: $(wc -l < LEARNINGS_QUICK_REFERENCE.md) lines"
echo "  Demo script: $(wc -l < examples/interesting_learnings_demo.lua) lines"
echo "  Total: $(($(wc -l < INTERESTING_LEARNINGS.md) + $(wc -l < LEARNINGS_QUICK_REFERENCE.md) + $(wc -l < examples/interesting_learnings_demo.lua))) lines"
echo

# Check key concepts are mentioned
echo "Checking key concepts mentioned..."
concepts=(
    "RMSNorm"
    "RotaryEmbedding"
    "RoPE"
    "SwiGLU"
    "Grouped-Query Attention"
    "GQA"
    "Neuro-Symbolic"
    "Niche Construction"
)

for concept in "${concepts[@]}"; do
    if grep -q "$concept" INTERESTING_LEARNINGS.md; then
        echo "  ✓ $concept documented"
    else
        echo "  ✗ $concept not found"
    fi
done
echo

echo "=========================================="
if [ "$all_exist" = true ]; then
    echo "Validation PASSED ✓"
    echo "All learning documentation is complete!"
else
    echo "Validation FAILED ✗"
    echo "Some files are missing."
    exit 1
fi
echo "=========================================="
