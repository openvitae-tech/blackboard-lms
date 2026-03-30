---
name: ui-audit
description: Audit Figma designs against ui_manifest.md to identify missing component features and plan NeoComponent extensions.
---

# UI Audit Skill

## Goal
Compare a Figma design against the available NeoComponent helpers and produce
a gap analysis with a concrete plan to extend existing helpers.

## Instructions

1. Read `engines/neo_component/ui_manifest.md` in full
2. Fetch the Figma URL from the GitHub issue
3. For each UI element in the Figma design:
   - Find the closest matching NeoComponent helper
   - Identify any missing arguments or visual variants
4. Produce a gap analysis artifact:
   - List of helpers that need new optional arguments
   - List of genuinely new UI patterns that require a new component
   - For each extension: the new argument name, type, default value, and allowed values
5. Post the gap analysis as a comment on the GitHub issue and wait for developer approval
6. Only proceed to implementation after approval

## Constraints
- Never create a new component when extending an existing one is possible
- All new arguments must have defaults that preserve existing caller behavior
- Update `ui_manifest.md` after every change
