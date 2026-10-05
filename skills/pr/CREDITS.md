# Credits

This skill is an adaptation of the following work:

- **Matt Pocock** for the reference [`pr` skill](https://github.com/mattpocock/skills/tree/main/skills/engineering/pr), whose PR-body workflow and fallback structure provide the starting point.
- **Dex Horthy** and **HumanLayer** for the visual-summary guidance adapted from the [`show-me` skill](https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md), including the use of pseudocode, call trees, component/file trees, Mermaid diagrams, and focused diffs.

The implementation here is rewritten for repository-template precedence, evidence collection, safe local drafting, and evidence-based Merge Danger scoring. It does not depend on either upstream skill at runtime.
