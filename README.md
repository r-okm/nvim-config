# nvim-config

Personal Neovim configuration files.

## Installation

```bash
git clone https://github.com/r-okm/nvim-config ~/.config/nvim
```

## Directory Structure

```text
.
├── init.lua                # Neovim configuration entry point
├── after/
│   ├── ftdetect/           # File type detection settings
│   ├── ftplugin/           # File type specific configurations
│   └── lsp/                # LSP specific settings
├── lua/
│   ├── config/             # Base configurations
│   │   ├── options.lua     # Neovim options
│   │   ├── keymaps.lua     # Key mappings
│   │   ├── autocmd.lua     # Autocommands
│   │   ├── lsp.lua         # LSP configurations
│   │   └── usercommand.lua # User commands
│   ├── plugins/            # Plugin management
│   │   ├── init.lua        # Lazy.nvim setup
│   │   └── spec/           # Plugin configurations
│   │       ├── core/       # Core plugin configurations
│   │       └── theme/      # Theme plugin configurations
│   └── r-okm/              # Utility functions and modules
├── snippets/               # Custom snippet definitions
├── lazy-lock.json          # Plugin version lock file
└── mason-lock.json         # Mason package lock file
```
