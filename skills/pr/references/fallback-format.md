# No-template fallback format

Read this reference when no repository PR template applies or when the user explicitly requests the fallback format despite an existing template.

Keep the body brief and use this structure:

```markdown
## Summary

<the clearest visual summary, when useful>

<short explanation of what changed and why>

## Evidence

- **Before:** <observed prior behavior, artifact, or `N/A — not applicable`>
  **After:** <observed new behavior, artifact, or verification result>

## Merge Danger

**Rating:** <1–10>/10

**Door:** <one-way or two-way>

<short rationale tied to reversibility, blast radius, data/security impact, and verification confidence>

**Blast Radius:** <one-word description>

<optional potential ramifications of merge>
```

Use the score bands as an evidence-based calibration rather than pretend precision:

- **1–2:** trivial, local, and easily reversible.
- **3–4:** localized and low-risk with a clear rollback.
- **5–6:** moderate cross-boundary impact or meaningful verification gaps.
- **7–8:** broad impact, security or data sensitivity, or difficult verification or rollback.
- **9–10:** destructive, production-critical, or very difficult to reverse safely.

Choose one integer and explain the main drivers. Consider reversibility, blast radius, data/security impact, and verification confidence. A two-way door can still score high when its blast radius is large; a one-way door can score low when its effect is tightly contained and well verified.

When a direct before/after comparison is unavailable, use honest test, build, or output evidence, or write `N/A — not applicable`. Never invent a before state.
