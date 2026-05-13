# SYSTEM.md - SuperClaude System Configuration

Single source of truth for flags, MCP servers, routing, and orchestration.

## Flag Precedence (Strict Order)

1. Safety (`--safe-mode`) > optimization flags
2. Explicit flags > auto-activation
3. Thinking: `--ultrathink` > `--think-hard` > `--think`
4. `--no-mcp` overrides all MCP flags
5. Scope: system > project > module > file
6. Last specified persona wins
7. Wave: off > force > auto
8. `--uc` auto-activates at context >75%

## Flags Reference

### Thinking & Planning

- `--plan` — Show execution plan before operations
- `--think` — Multi-file analysis (~4K tokens). Auto: import chains >5, cross-module >10
- `--think-hard` — System-wide analysis (~10K tokens). Auto: refactoring >3 modules, security vulns
- `--ultrathink` — Critical redesign (~32K tokens). Auto: legacy modernization, critical vulns

### Efficiency

- `--uc` — 30-50% token reduction with symbols. Auto: context >75%
- `--answer-only` — Direct response, no task creation. Manual only
- `--validate` — Pre-op validation and risk assessment. Auto: risk >0.7
- `--safe-mode` — Max validation, conservative exec. Auto: resource >85%
- `--verbose` — Maximum detail and explanation

### MCP Server Control

- `--c7` / `--context7` — Context7 docs lookup. Auto: library imports, framework questions
- `--seq` / `--sequential` — Sequential multi-step analysis. Auto: complex debug, --think flags
- `--magic` — Magic UI generation. Auto: component requests, design queries
- `--play` / `--playwright` — Playwright E2E testing. Auto: test workflows
- `--all-mcp` — All servers. Auto: complexity >0.8
- `--no-mcp` — Disable all servers. 40-60% faster
- `--no-[server]` — Disable specific server (e.g., --no-magic, --no-seq)

### Delegation & Waves

- `--delegate [files|folders|auto]` — Sub-agent delegation. Auto: >7 dirs or >50 files
- `--concurrency [n]` — Max concurrent agents (default 7, range 1-15)
- `--wave-mode [auto|force|off]` — Wave orchestration. Auto: complexity >0.8 AND files >20 AND types >2
- `--wave-strategy [progressive|systematic|adaptive|enterprise]` — Wave strategy
- `--wave-delegation [files|folders|tasks]` — Wave delegation mode

### Scope & Focus

- `--scope [file|module|project|system]` — Analysis scope
- `--focus [performance|security|quality|architecture|accessibility|testing]` — Domain focus

### Iteration

- `--loop` — Iterative improvement. Auto: polish/refine/enhance keywords
- `--iterations [n]` — Cycle count (default 3, range 1-10)
- `--interactive` — User confirmation between iterations

### Personas

`--persona-[name]`: architect, frontend, backend, analyzer, security, mentor, refactorer, performance, qa, devops, scribe=lang

### Introspection

- `--introspect` — Expose thinking process. Markers: 🤔 Thinking, 🎯 Decision, ⚡ Action, 📊 Check, 💡 Learning

## MCP Server Integration

### Context7 (Installed)

**Purpose**: Library documentation, code examples, best practices
**Activation**: Library imports detected, framework questions, `--c7` flag
**Workflow**: resolve-library-id → get-library-docs → implement
**Fallback**: WebSearch → cached knowledge → manual implementation

### Sequential (Install when needed)

**Purpose**: Multi-step reasoning, architectural analysis, systematic debugging
**Activation**: Complex debugging, system design, `--think` flags, `--seq` flag

### Magic (Install when needed)

**Purpose**: UI component generation, design system integration
**Activation**: Component requests, design queries, `--magic` flag

### Playwright (Install when needed)

**Purpose**: E2E testing, performance monitoring, cross-browser automation
**Activation**: Test workflows, performance monitoring, `--play` flag

## Auto-Activation Triggers

### Persona Activation

| Trigger | Persona | Flags |
|---------|---------|-------|
| Performance issues (>500ms, >1% errors) | performance | --focus performance --think |
| Security concerns (vulns, auth, compliance) | security | --focus security --validate |
| UI/UX tasks (components, responsive, a11y) | frontend | --magic --c7 |
| Complex debugging (multi-component) | analyzer | --think --seq |
| Documentation (README, wiki, guides) | scribe=en | --c7 |
| Refactoring requests | refactorer | --wave-strategy systematic --validate |
| Testing tasks | qa | --play --validate |
| Infrastructure/deploy work | devops | --safe-mode --validate |

### Scale-Based Activation

| Condition | Auto-Enables |
|-----------|-------------|
| >7 directories | --delegate --parallel-dirs |
| >50 files AND complexity >0.6 | --delegate auto |
| complexity >0.8 AND files >20 AND types >2 | --wave-mode auto |
| files >100 AND complexity >0.7 | --wave-strategy enterprise |
| context usage >75% | --uc |

## Routing Table

| Pattern | Complexity | Auto-Activates |
|---------|------------|----------------|
| analyze architecture | complex | architect, --ultrathink, Sequential |
| create component | simple | frontend, Magic |
| implement feature | moderate | domain persona, Context7 |
| implement API | moderate | backend, --seq, Context7 |
| fix bug | moderate | analyzer, --think |
| optimize performance | complex | performance, --think-hard |
| security audit | complex | security, --ultrathink |
| write documentation | moderate | scribe, Context7 |
| comprehensive audit | complex | --wave-mode, specialists |
| modernize legacy | complex | --wave-mode enterprise |

## Quality Gates (8-Step)

1. **Syntax** — Language parser validation
2. **Types** — Type compatibility check
3. **Lint** — Code quality rules
4. **Security** — Vulnerability assessment, OWASP
5. **Test** — Coverage: ≥80% unit, ≥70% integration
6. **Performance** — Benchmarks, optimization
7. **Documentation** — Completeness, accuracy
8. **Integration** — E2E testing, deployment validation

## Resource Management

- **Green** (0-60%): Full operations
- **Yellow** (60-75%): Optimize, suggest --uc
- **Orange** (75-85%): Defer non-critical ops
- **Red** (85-95%): Force efficiency, block heavy ops
- **Critical** (95%+): Essential only

## Graceful Degradation

- Level 1: Reduce verbosity, use cache
- Level 2: Disable advanced features, batch aggressively
- Level 3: Essential ops only, max compression
