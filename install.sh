#!/bin/bash
set -e

SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

SKILLS=(
  aims-os-feature-versioning
  aims-os-scope-toggle
  aims-os-eng-handoff-spec
  aims-os-ds-component
  aims-os-prototype-screen
  aims-os-versioning-quality
)

for skill in "${SKILLS[@]}"; do
  cp -r "$skill" "$SKILLS_DIR/"
  echo "✓ $skill"
done

echo ""
echo "All AIMS-OS skills installed to $SKILLS_DIR"
echo "Restart Claude Code to activate."
