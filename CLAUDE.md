# CLAUDE.md

## Plugin Source Code

- Plugins installed by lazy.nvim live under `~/.local/share/nvim/lazy/<plugin-name>/`. When investigating a plugin's implementation, read it directly from that path — do not `git clone`.

## Docs

- `docs/ai_henkan.md` — design decisions and rationale for the AI romaji→Japanese conversion feature (`lua/r-okm/ai_henkan.lua`). Read it before modifying that module.

## Tests

- `tests/bufmenu/` — E2E tests for the bufmenu module (`lua/r-okm/bufmenu/`). Run them after modifying `lua/r-okm/bufmenu/` or `lua/plugins/spec/core/bufmenu.lua`:
  - All suites: `nvim --headless -S tests/bufmenu/run.lua` (~2 minutes; exits non-zero on failure)
  - Single suite: `nvim --headless -S tests/bufmenu/<suite>.lua`
- The tests drive a real TUI child nvim (with this config) in a PTY from a headless driver, so they exercise lazy-loading, keymaps, and rendering end-to-end. See `tests/bufmenu/harness.lua` for how observation works (`MenuDump` injection). Fixtures and dumps go to a per-run temp directory; no cleanup is needed.
- When fixing a bug in bufmenu, add a regression case to `tests/bufmenu/regressions.lua` (or the suite that covers the area).
