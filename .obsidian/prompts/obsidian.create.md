# Prompt: obsidian.create

Purpose: Create a note of a given type using the appropriate template, placing it in the correct vault folder with required frontmatter.

Inputs:
- type: idea|goal|project|area (optional; infer if omitted)
- title: string
- description: string (optional)

Behavior:
- Use `.obsidian/templates/<type>.v1.md` to scaffold content
- Enforce curated tags and general frontmatter
- Place file under numbered folder per constitution (Idea→`0) Ideas/`, Goal→`1) Goals/`, Project→`2) Projects/`, Area→`3) Areas/`)
- Dry-run by default; require approval to write

Example:

> obsidian.create type=idea title="Lightweight capture" description="Quick capture flow with curated tags"
