# nvim-config

Personal Neovim configuration files.

## Installation

```bash
git clone https://github.com/r-okm/nvim-config ~/.config/nvim
```

## Directory Structure

```text
.
├── init.lua                       # Neovim configuration entry point
├── edit_command_line.lua          # Entry point for EDIT_COMMAND_LINE mode
├── after/
│   ├── ftdetect/                  # File type detection settings
│   ├── ftplugin/                  # File type specific configurations
│   └── lsp/                       # LSP specific settings
├── lua/
│   ├── config/                    # Config modules activated just by `require`
│   │   ├── options.lua            # Neovim options
│   │   ├── keymaps.lua            # Key mappings
│   │   ├── autocmd.lua            # Autocommands
│   │   ├── lsp.lua                # LSP configurations
│   │   └── usercommand.lua        # User commands
│   ├── plugins/
│   │   ├── init.lua               # Plugin entry point
│   │   └── spec/
│   │       ├── core/              # Core plugins
│   │       ├── edit_command_line/ # Plugins enabled in EDIT_COMMAND_LINE mode
│   │       └── theme/             # Theme plugins
│   └── r-okm/
│       ├── types/                 # Type definitions
│       ├── ft-config.lua          # File type specific configurations
│       └── util.lua               # Utility functions
├── snippets/                      # Custom snippet definitions
├── lazy-lock.json                 # Plugin version lock file
└── mason-lock.json                # Mason package lock file
```
