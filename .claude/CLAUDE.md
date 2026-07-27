## Workflow Orchestration

### 1. Plan Node Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: add the lesson to the **Lessons** section at the bottom of this file.
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness
- A change is only complete when `just lint` passes. Use `//nolint` on false hits (no trailing comment needed if the reason is obvious from the directive), and fix legitimate lint errors

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Before presenting: audit the entire change as a whole for duplicated ideas, inconsistent abstractions, or unnecessary indirection

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

### 7. Commit Message Style
- Lowercase start, imperative/descriptive verb (`simplify`, `fix`, `add`, `remove`, `harden`, `clean up`, etc.)
- Single-line title, ideally under 60 characters; add detail lines below only when context isn't clear from the title
- No trailing period, no conventional-commit prefixes, no ticket references, no Co-Authored-By trailer
- Describe what changed, not why — e.g. `simplify auth model and command surface`
- Always sign commits (`git commit -s`)

## Task Management

1. **Track Progress**: Mark items complete as you go
2. **Explain Changes**: High-level summary at each step
3. **Capture Lessons**: Add to the **Lessons** section at the bottom of this file after corrections

## Core Principles

- **Lean & Flat**: Constantly drive toward a light-weight, lean, flat codebase: fewer files, shallower package and directory hierarchies, minimal dependencies, less indirection. Prefer deleting over adding; the smallest surface that does the job wins. Hold documentation to the same bar: terse, flat, no sprawl or duplication.
- **Simplicity First**: Make every change as simple as possible. Only touch what's necessary. Avoid introducing bugs.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Boyscout Rule**: Always leave the code cleaner than you found it. When defluff or review surfaces nearby debt — even if it predates the current diff — fix it, unless it opens a large can of worms.

## Lessons

### Tooling
- **After editing Go files, ALWAYS run `goimports -w <file>` to fix imports and formatting — including adding missing imports AND removing unused ones.** This is faster than manually searching for import paths and more correct than hand-editing. Never manually add or remove import lines; let `goimports` handle it.

### Code Quality
- Don't add comments that restate what the code already says. Only comment where logic isn't self-evident. This includes `nolint` directives — don't add a trailing comment that just restates the lint rule (e.g., `//nolint:forcetypeassert // always a UDPAddr`). The nolint directive is self-explanatory; only comment if the reason is genuinely non-obvious.
- Don't ship dead or unused code — no dead branches for impossible conditions, no nil/zero guards on values that provably can't be nil/zero, no struct fields only tests read, no parameters the function ignores. These guards are actively misleading: they imply the guarded state is reachable when it isn't. Signatures and types are contracts.
- No premature implementation. Don't build guards, validation, or abstractions for capability models that don't yet have variability. If every call site passes one of two hardcoded values, runtime checks against those values are dead logic. Add the guards when the variability is introduced, not before.
- Deduplicate before shipping. If two functions build the same output from the same data, one should call the other.
- Every switch on a type or enum must be exhaustive. Dead default branches that can't fire are fluff — remove them.
- No naked returns in functions with named return values unless the function is trivially short.
- Comment discipline: match the file's existing comment density (usually terse one-liners). No multi-paragraph doc-comment essays. No restating struct fields or self-documenting test/subtest names. No saying the same idea in multiple ways within one comment: every sentence must add new information; if a "tighter" rewrite still says the rule three times, it's still wordy. No em dashes in comments; use colons, periods, or commas. No bare domain tokens (enum names, identifiers) dropped without first naming the concept they represent, so the reader doesn't have to know the domain to parse the sentence. No references to PR-internal milestones that rot at merge (phase tokens like "Phase 3f"/"P2", "the brief"/"the plan", "pre-fix"/"the fix"/"as of the rewrite"/"(new)"); state the durable invariant in present tense instead, keeping only references to genuine runtime state ("the old grant") or a real incident ("on the live cluster"). Keep each rationale in exactly ONE place (reference it from elsewhere, never duplicate the same explanation across files). A green converge/reviewer cycle does not certify comment compliance; on a direct challenge, re-audit honestly against the rule rather than defending.
- Bias toward removal. When adding something "for completeness" or "for clarity" (a comment, a test, a commit body, a guard, a code path), default to NOT adding it; the bar is higher than your instinct. CLAUDE.md's existing rules are sharper than you apply them: commit style says "add detail below only when context isn't clear from the title"; comment rule says "only where logic isn't self-evident"; dead-code rule covers struct fields, tests, and parameters. Apply ruthlessly rather than over-explaining.

### Error Handling
- **Standard library only for errors.** `errors.New` for sentinels, `fmt.Errorf("%w")` for wrapping, `errors.Is`/`errors.As` for checking. No external error libraries.
- **Map errors to gRPC status codes in service handlers.** Use `status.Error(codes.X, "user-facing message")` and log the detailed error separately with `zap.Error(err)`. Don't leak internal details to callers.

### Design Patterns
- **Use typed representations over string conventions.** Don't encode structured data into string keys with prefix parsing. Use typed structs with enums from the start — string conventions are fragile and create implicit coupling.
- **Unify parallel patterns immediately.** When multiple attributes need the same concept (e.g., deletion), use one consistent mechanism everywhere. After each step, ask: "have I introduced a second way of expressing the same idea?"
- **Clean package APIs.** Each package should expose a clean API. Internal struct types, lock details, and implementation choices must not leak across package boundaries.
- **Noop implementations for optional features.** When a feature can be disabled (metrics, tracing), implement the same interface with no-ops rather than scattering nil checks. Initialize to no-op, wire the real implementation later via setter.
- **Don't promote derived data to first-class fields.** If a value lives in the source (a date or tag in body text) and a rebuildable projection can extract it, keep it there: a parallel first-class field is a second source of truth that drifts from the source. Reserve privileged fields for system-critical data (identity, clocks, partition/permission keys). State a layering rule, then apply it ruthlessly; don't carve convenience exceptions the derived layer already handles.

### Proto Message Design
- **Never build a shadow type system alongside a proto oneof.** If the proto already has a discriminator (oneof, enum), use it directly. Don't create a parallel Go enum that must stay in sync.
- **Put shared semantics at the shared level.** If every variant of a oneof carries the same field (e.g., `deleted`), that field belongs on the parent message, not duplicated across each variant.
- **Don't nest proto messages without a reason.** If the wrapper adds nothing beyond what the inner message has, inline the fields or use the inner message directly.

### Concurrency
- Don't add mutexes around write-once fields. If a field is set once before goroutines are spawned, the goroutine-spawn itself establishes happens-before — a mutex adds noise and implies the field is mutable when it isn't.
- Don't wrap simple field access in a getter that only adds a nil check for conditions that can't happen. If the field is guaranteed set by the time callers run, just use it directly.
- Every `for { select { ... } }` loop must have a `case <-ctx.Done()` branch. No exceptions.
- **No fire-and-forget goroutines.** Every goroutine must be tracked by a `WaitGroup` (or equivalent) and use a cancellable context. Bare `go func()` with `context.Background()` creates goroutines that outlive shutdown and panic on closed channels. Use `wg.Go()` with the service's context.
- Use `sync.Once` to guard channel closes when multiple code paths could trigger shutdown. Double-close panics.
- Shutdown ordering matters: stop accepting → drain active work → flush observability → close stores. Each layer waits for the previous.

### Performance
- Don't hand-calculate serialization sizes. Use the serialization library's own `Size()` methods — hand-counted varint bytes silently break when field numbers change.
- Batch lock acquisition on the receive side too. If you batch on send, the receive path should also take the lock once for the batch, not N times for N events.

### Workflow
- When `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is enabled, use agent teams (TeamCreate) for multi-package coordination work, not plain subagents. The user expects agent teams when they've enabled the feature. Subagents are fine for research/analysis but not for cross-package execution.

### Testing
- Use `require.Equal`, `require.Len`, `require.NoError`, etc. from `github.com/stretchr/testify/require` instead of manual `t.Fatalf` with format strings. Testify assertions are more readable and give better failure output.
- Test helpers must match production constructors. If a test helper builds a struct that a production constructor also builds, they must produce equivalent state. Divergence means tests exercise impossible configurations.
- Prefer `t.Cleanup()` over `defer` for test resource teardown — it works correctly with subtests and `t.Fatal`.
- Use `require.Eventually` for async assertions (peer connections, state convergence). Don't `time.Sleep` then assert.
- Use test harness structs with factory methods to keep test setup readable and reusable across subtests.

### Communication
- **Push back on suggestions that would make things worse.** If the user suggests a change (e.g. making something private) and there's a concrete reason it needs to stay as-is (e.g. another package references it), say so immediately rather than making the change and discovering the breakage. Don't blindly apply suggestions — explain the constraint and let the user decide with full information.

### Research & External Facts
- **Never compute costs/prices from memorised rates — look them up live.** Training-data pricing is stale: I billed Opus at the deprecated $15/$75 card when 4.5+ had dropped to $5/$25 (cache read $0.50), overstating a 30-day usage estimate by 3×. For any cost, quota, rate-limit, or pricing question, fetch the current numbers from the authoritative source (claude.com/pricing or platform.claude.com docs) before calculating, and state the rate card used. The same applies to any fast-moving external fact where the price/limit *is* the answer.
- **Pin toolchain and dependency versions from live sources, not training data.** When scaffolding or upgrading a project, check PyPI / endoflife.date / GitHub releases for current versions before writing any pin — I proposed Python 3.13 as "current" when 3.14 was the stable line, and the machine's brew-installed uv was a year stale. "Latest" in a user request means verified-latest, including the local tools (`uv`, `just`, etc.), not latest-as-of-training.
- **Check an API feature's documented limits before adopting it; mocked tests never catch request-shape rejections.** Anthropic structured outputs rejected a nested Pydantic schema live with 400 "Schema is too complex" (documented budgets: ≤24 optional params, ≤16 union-typed params per request) — the test suite faked the client, so it only surfaced in production. Second instance: the Python SDK refuses non-streaming `messages.create` when max_tokens implies a >10-minute run (32k output on opus trips it; 16k didn't) — use `messages.stream(...)` + `get_final_message()` for any call with large max_tokens. For schemas near/over budget, prompt for JSON and validate locally instead; and live-fire every distinct request variant before handing off (params like max_tokens are part of the shape — one variant passing says nothing about the others).
