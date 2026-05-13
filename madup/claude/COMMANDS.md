# COMMANDS.md - SuperClaude Commands

## Command Format
```
/sc:[command] [args] [--flags]
```
Input parsing: `$ARGUMENTS` with `@<path>`, `!<command>`, `--<flags>`

## Commands

### Development

- `/build [target]` — Build/compile/package with framework detection | Personas: frontend, backend, architect | MCP: Magic, Context7 | Wave: yes
- `/implement [feature] [--type component|api|service|feature] [--framework name]` — Feature implementation with persona activation | Personas: frontend, backend, architect, security | MCP: Magic, Context7, Sequential | Wave: yes
- `/design [target] [--type architecture|api|component|database]` — System/component design | Personas: architect, frontend | MCP: Magic, Context7 | Wave: yes

### Analysis

- `/analyze [target] [--focus quality|security|performance|architecture] [--depth quick|deep]` — Multi-dimensional code analysis | Personas: analyzer, architect, security | MCP: Sequential, Context7 | Wave: yes
- `/troubleshoot [issue] [--type bug|build|performance|deployment]` — Problem investigation and resolution | Personas: analyzer, qa | MCP: Sequential
- `/explain [target] [--level basic|intermediate|advanced]` — Educational explanations | Personas: mentor, scribe | MCP: Context7

### Quality

- `/improve [target] [--type quality|performance|maintainability|style]` — Evidence-based code enhancement | Personas: refactorer, performance, architect, qa | MCP: Sequential, Context7 | Wave: yes
- `/cleanup [target] [--type code|imports|files|all] [--safe|--aggressive]` — Technical debt reduction | Personas: refactorer | MCP: Sequential

### Planning

- `/workflow [prd|description] [--strategy systematic|agile|mvp]` — Implementation workflow from PRDs | Personas: architect, analyzer | MCP: Sequential, Context7 | Wave: yes
- `/estimate [target] [--type time|effort|complexity]` — Development estimation | Personas: analyzer, architect | MCP: Sequential, Context7
- `/task [action] [--strategy systematic|agile|enterprise]` — Cross-session project management | Personas: architect, analyzer | MCP: Sequential | Wave: yes

### Testing & Docs

- `/test [target] [--type unit|integration|e2e|all] [--coverage]` — Test execution and reports | Personas: qa | MCP: Playwright
- `/document [target] [--type inline|external|api|guide]` — Documentation generation | Personas: scribe, mentor | MCP: Context7

### Version Control

- `/git [operation] [--smart-commit] [--branch-strategy]` — Git with intelligent commits | Personas: devops, scribe, qa

### Meta

- `/index [target] [--type docs|api|structure|readme]` — Project documentation/knowledge base | Personas: mentor, analyzer
- `/load [target] [--type project|config|deps|env] [--cache]` — Project context loading | Personas: analyzer, architect
- `/spawn [task] [--sequential|--parallel] [--validate]` — Complex task orchestration | Personas: analyzer, architect, devops

## Wave-Enabled Commands

7 commands: `/analyze`, `/build`, `/design`, `/implement`, `/improve`, `/task`, `/workflow`
