# Documentation Summary

This document provides an overview of the project documentation structure and key reference materials.

## Core Documentation

### README.md (96 lines)
The main entry point with:
- Project overview and purpose
- Skills table (26 skills listed)
- Agents table (6 agents listed)
- Quick bootstrap guide (references full guide)
- Quality bar and skill structure
- Resource links

### docs/bootstrap-guide.md (new)
Extracted from README to provide comprehensive bootstrap documentation:
- Bootstrap script usage and options
- What the script does and where it creates symlinks
- Usage examples with all command-line flags
- Troubleshooting commands and validation
- Configuration files and model setup
- Local/offline model workflow

### .github/copilot-instructions.md (129 lines)
Comprehensive authoring guide referenced from README:
- Purpose and quality bar
- Repository structure
- Skill frontmatter schema
- Procedure structure requirements
- Validation and troubleshooting
- Submission checklist

## Skill-Specific Documentation

Each skill in `.github/skills/<name>/` contains:
- `SKILL.md` - Main instruction file with frontmatter and procedure
- `references/` - Optional supporting documents (loaded on-demand)

## Agent Documentation

Each agent in `.github/agents/` contains:
- `<name>.agent.md` - Agent definition with tools, constraints, and workflow

## Reference Documents

### Shared References
- `.github/references/mistral-cross-cutting-guidance.md` - Mistral SDK best practices

### Skill-Specific References
Examples:
- `skill-builder/references/quality-checklist.md` - Skill validation checklist
- `skill-builder/references/research-queries.md` - GitHub research templates
- `skill-builder/references/skill-structure.md` - Canonical skill template

## Documentation Principles

1. **Single Source of Truth**: README is concise and references detailed guides
2. **Progressive Disclosure**: Complex topics extracted to separate documents
3. **Up-to-Date**: All documentation reflects current implementation
4. **Actionable**: Includes concrete commands and examples
5. **Well-Structured**: Clear headings and logical organization

## Documentation Workflow

1. **Update Source Files**: Modify SKILL.md, agent.md, or reference files
2. **Regenerate Symlinks**: Run `scripts/setup-copilot-globals.sh` to propagate changes
3. **Verify Links**: Check that all references resolve correctly
4. **Test Commands**: Ensure all documented commands work as expected

## Future Documentation Improvements

- Add architecture diagram showing agent relationships
- Create quick-start guide for new contributors
- Document common delegation patterns
- Add troubleshooting FAQ
- Create video walkthroughs for key workflows
