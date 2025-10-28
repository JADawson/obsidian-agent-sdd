# Prompt: obsidian.create

Purpose: Create a note of a given type using the appropriate template, placing it in the correct vault folder with required frontmatter.

Inputs:
- type: idea|goal|project|area (optional; defaults to idea)
- title: string
- description: string (optional)
- approve: flag to apply after showing diff (optional)

Behavior:
- Use `.obsidian/templates/<type>.v1.md` to scaffold content
- Fill `<id>`, `<Title>`, and `<YYYY-MM-DD>` placeholders
- Enforce curated tags and general frontmatter
- Place file under numbered folder per constitution (Idea→`0) Ideas/`, Goal→`1) Goals/`, Project→`2) Projects/`, Area→`3) Areas/`)
- Dry-run by default; show diff and trace; require `-Approve` (or `-DryRun:$false`) to write

Examples:

> obsidian.create type=idea title="Lightweight capture" description="Quick capture flow with curated tags"
> obsidian.create title="Just a thought" -Approve
