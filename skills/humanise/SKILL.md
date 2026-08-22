---
name: humanise
description: Humanise a user-provided draft when it sounds generic, machine-like, over-polished, or AI-generated; audit AI-sounding patterns, rewrite while preserving meaning and voice, or explain and rate the change when requested.
license: MIT
metadata:
  author: mynameistito
  version: "1.0.0"
---

# Humanise

Make a draft feel written by its actual author: audit AI-sounding patterns, then rewrite with more concrete, context-aware language while preserving meaning, intent, facts, and baseline tone.

## Guardrail

Treat writing signs as clues, not authorship proof. Describe prose as "AI-sounding", "machine-like", "generic", or "synthetic"; never claim that a person or tool wrote it based on style alone.

Load `references/signs-of-ai-writing.md` before the audit unless it is already in the current context.

## Workflow

1. **Read the brief.** Establish the purpose, audience, requested format, and intended tone from the user's context. If a required fact or audience detail is missing and changing it could alter the meaning, ask one focused question; otherwise proceed with the strongest evidence in the draft. Completion: the rewrite has a defined audience, purpose, and tone, or the missing decision has been surfaced.
2. **Audit the draft.** Use the reference as a heuristic. Mark only patterns that materially affect how this draft reads, and distinguish a stylistic observation from a factual problem. Check inflated claims, vague attribution, promotional language, canned structure, repetitive rhythm, over-neat parallelism, unnecessary formatting, placeholder or meta language, and other relevant signs. Completion: every audit point names an observable pattern and its effect; no point asserts authorship.
3. **Rewrite for texture.** Preserve every named fact, commitment, date, quote, technical meaning, stance, and requested level of formality. Replace broad abstractions with details already present, use plain nouns and verbs, vary rhythm, and keep useful uncertainty or preference. Use contractions, fragments, or informality only when the established voice supports them. Completion: the revision addresses each material audit point without inventing context, facts, anecdotes, or confidence.
4. **Check fidelity.** Compare the source and revision for dropped or changed facts, altered commitments, unsupported claims, tone drift, and accidental overcorrection. For serious legal, medical, financial, or otherwise consequential claims, flag unsupported assertions instead of strengthening them. Completion: the final text passes the fidelity check, or each unresolved issue is explicitly flagged beside the rewrite.
5. **Deliver the requested shape.** Use the compact output below unless the user asks for another format. Give 2-4 short change bullets; for a tiny draft, combine the audit and explanation. Put a direct replacement first when requested. Add ratings only when requested or clearly useful. Completion: the response contains exactly the sections useful for the request and no forced rating or redundant explanation.

## Output Format

Default to this compact format:

```markdown
**Audit**
- ...

**Rewrite**
...

**What changed**
- ...

**Human feel**
Original: N/10
Revised: N/10
```

Ratings are optional. Omit them for a quick rewrite unless the user asks for them or they clarify the result.
