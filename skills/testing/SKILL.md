---
name: testing
description: Testing standards for TypeScript and Effect projects using Bun and Vitest. Use when adding, reviewing, reorganizing, or improving tests, fixing regressions, increasing meaningful coverage, designing fixtures or test doubles, or verifying application behaviour.
license: MIT
metadata:
  author: mynameistito
  version: "1.0.0"
---

# Testing

Create tests that verify meaningful observable behaviour and protect production code against regressions. Treat coverage as evidence about risk, not as the objective.

## Workflow

### 1. Establish the local contract

Read the nearest `AGENTS.md`, package scripts, test configuration, TypeScript configuration, and representative existing tests. Identify the repository's runner, assertion style, module boundaries, Effect version, and any project-specific test helpers.

Use the repository's established commands and conventions when they are compatible with the rules below.

**Complete when:** the governing instructions, available test commands, and relevant local patterns are known.

### 2. Map the behaviour and choose the test level

Name the caller-visible behaviour under test, its important inputs, outputs, side effects, and failure modes. Choose the narrowest level that can prove it:

- **Unit:** isolated parsers, transformations, domain rules, calculations, state transitions, schemas, error mapping, pure utilities, or Effect services with lightweight test Layers.
- **Integration:** correctness that depends on multiple real components, such as service/repository boundaries, request handlers, Worker handling, Durable Objects, serialization, persistence, configuration, or Cloudflare binding adapters.
- **Regression:** a permanent reproduction of a reported bug, including the triggering input or state and the corrected result.

Prefer public interfaces and real seams. Test implementation details only when they contain meaningful independent logic or the interaction itself is contractual.

**Complete when:** the test level, observable contract, and risk-bearing branches are explicit.

### 3. Build the test around behaviour

Keep tests under the repository's `__tests__` directory. Use purpose-based subdirectories only when the suite needs them:

```text
__tests__/
├── unit/
├── integration/
├── regression/
├── fixtures/
└── helpers/
```

Name TypeScript test files `*.test.ts` or `*.test.tsx`. Keep fixtures small and purpose-specific. Use factories or builders when many tests need controlled variations of one domain object.

Cover the success path and the meaningful failure paths. Depending on the behaviour, include invalid input, malformed external data, missing configuration, unavailable dependencies, permission failures, timeout or retry exhaustion, duplicate operations, empty results, partial results, and unexpected but valid boundary values.

Assert returned domain values, typed failures, persisted state, emitted responses, and externally visible side effects. Prefer specific assertions over broad snapshots.

**Complete when:** each test explains a behaviour, uses readable local data, and asserts the result that matters to callers.

### 4. Test Effect programs through Effect

Test Effects through their public interfaces. Provide dependencies with Effect services and deterministic test Layers so external I/O, time, randomness, and failure injection remain controllable.

- Preserve typed error channels and assert typed failures explicitly when they are part of the contract.
- Use Effect-native time and scheduling facilities for retries, delays, schedules, and other time-dependent behaviour.
- Acquire and release scoped resources through the test's Effect runtime.
- Prefer shared Effect test helpers for runtime execution instead of scattering unsafe runtime calls through tests.
- Test service behaviour rather than private Layer construction details unless Layer composition is the subject under test.

**Complete when:** the test crosses the same service interface as production and preserves the Effect error, resource, and scheduling semantics that matter.

### 5. Choose test doubles honestly

Use this order when replacing a dependency:

1. A pure real implementation.
2. A lightweight in-memory implementation.
3. A deterministic fake.
4. A focused stub.
5. A mock only for a genuinely expensive, nondeterministic, unsafe, or external boundary.

Keep platform-independent domain and application logic separate from Cloudflare bindings. Test platform-independent Effect services normally. At Cloudflare boundaries, cover request parsing, response construction, environment mapping, Durable Object RPC and storage, Queue messages, scheduled handlers, D1, KV, R2, and application-owned Access validation when those behaviours are part of the contract.

Prefer test implementations supplied through Effect Layers over module-level mocking. Keep one-off fakes in the test that owns them; promote a reusable fake only when it faithfully implements a real observable seam.

**Complete when:** every substitute has a stated reason, the logic under test remains real, and the test double does not hide the behaviour being verified.

### 6. Make tests deterministic and isolated

Tests must produce the same result regardless of order or repetition. Control time, randomness, environment variables, external state, and generated identifiers where practical. Restore mutated global state and use unique resources for shared storage.

Treat flakiness as a defect. Identify the nondeterministic dependency, remove timing races, isolate mutable state, and verify the test repeatedly. Use sleeps, retries, and larger timeouts only when timing behaviour itself is under test.

**Complete when:** the affected tests pass repeatedly, in isolation and with the relevant suite, without relying on execution order or accidental timing.

### 7. Verify and review the result

Run the narrowest relevant test command first, then expand verification according to the change. Prefer existing repository scripts. Typical commands are:

```text
bun test
bun test __tests__/unit/example.test.ts
bun run test
bun run typecheck
bun run lint
bun run format
```

Review coverage reports as a diagnostic. Prioritize untested domain branches, error paths, security-sensitive behaviour, integration boundaries, and previously reported bugs over trivial lines.

**Complete when:** relevant tests pass, applicable typecheck, lint, and formatting checks pass, and every remaining verification failure is reported with its cause.

## Reference Rules

### Regression tests

Keep regression tests after the fix. Encode the original input or state, the expected corrected behaviour, and any boundary condition that made the bug possible. A regression test is permanent protection, not a temporary debugging artifact.

### Snapshots

Use snapshots only when the complete serialized representation is intentionally part of the contract and reviewers can inspect changes meaningfully. Keep snapshots small and pair them with explicit behavioural assertions where useful.

### Coverage

Use coverage to find risk, not to justify meaningless tests or exclusions. Investigate difficult branches instead of ignoring them, and prefer meaningful branch, error-path, and domain coverage over superficial line coverage.
