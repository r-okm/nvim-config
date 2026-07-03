# CLAUDE.md

## Plugin Source Code

- Plugins installed by lazy.nvim live under `~/.local/share/nvim/lazy/<plugin-name>/`. When investigating a plugin's implementation, read it directly from that path — do not `git clone`.

## Docs

- `docs/ai_henkan.md` — design decisions and rationale for the AI romaji→Japanese conversion feature (`lua/r-okm/ai_henkan.lua`). Read it before modifying that module.
