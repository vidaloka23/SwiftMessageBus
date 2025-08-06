# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the BMad-Method (Breakthrough Method of Agile AI-driven Development) framework distribution - an AI-driven development methodology that uses specialized AI agents for Agile development processes. This is NOT a traditional software project with source code, but rather a framework for orchestrating AI agents to build software.

## Framework Structure

```
.bmad-core/           # Core BMad framework resources
├── agents/           # AI agent role definitions (PM, Dev, Architect, QA, UX)
├── tasks/            # Workflow task definitions and prompts
├── templates/        # Document templates for PRDs, architecture, etc.
├── data/             # Knowledge base and user preferences
└── checklists/       # Quality assurance and review checklists

web-bundles/          # Standalone distributions for web UIs
├── agents/           # Individual agent bundles
├── teams/            # Team composition bundles
└── expansion-packs/  # Domain-specific packs (games, DevOps)
```

## Working with BMad Resources

### Key Commands

The BMad framework uses slash commands within AI interactions:
- `*help` - Display available commands for current agent
- `*create-doc` - Generate framework documents
- `*review` - Trigger quality review processes
- `*handoff` - Prepare work for next agent in workflow

### Agent Roles

Each agent has specific capabilities:
- **bmad-master**: Orchestration and workflow coordination
- **bmad-pm**: Product requirements and user stories
- **bmad-dev**: Code implementation and technical execution
- **bmad-architect**: System design and architecture decisions
- **bmad-qa**: Testing strategies and quality assurance
- **bmad-ux-expert**: User experience and interface design

### Workflow Patterns

1. **Planning Phase**: Use web UI agents to create PRDs and architecture
2. **Development Phase**: Execute in IDE with specialized agents
3. **Review Cycles**: Apply checklists and quality gates
4. **Handoffs**: Structured transitions between agent roles

## Important Files and Locations

- **Knowledge Base**: `.bmad-core/data/bmad-kb.md` - Core framework documentation
- **Agent Specs**: `.bmad-core/agents/` - Role definitions and capabilities
- **IDE Rules**: `.cursor/rules/` - Cursor-specific agent implementations
- **Templates**: `.bmad-core/templates/` - Document scaffolding

## Development Approach

This framework doesn't have traditional build/test commands. Instead:

1. **Resource Modification**: Edit agent definitions, templates, or tasks in `.bmad-core/`
2. **Bundle Creation**: Package resources for distribution in `web-bundles/`
3. **Integration Updates**: Sync changes to IDE-specific directories (`.cursor/`, `.claude/`, etc.)
4. **Testing**: Validate agent behaviors through actual usage in target environments

## Key Principles

- **Agent-First Development**: AI agents handle implementation details
- **Role Separation**: Each agent maintains its specialized domain
- **Structured Workflows**: Follow BMad's phased approach (Plan → Build → Review)
- **Resource Dependencies**: Tasks reference templates and data consistently
- **Multi-Platform Support**: Maintain compatibility across AI coding assistants