" Neovim-Qt only: loaded by nvim-qt after init.lua, ignored by the TUI and other GUIs.
if !exists('g:GuiLoaded')
  finish
endif

" Same face and size as the Windows Terminal profile defaults.
" The non-EAW variant keeps ambiguous-width glyphs half-width, matching 'ambiwidth' single.
GuiFont! UDEV Gothic 35NF:h11
GuiLinespace 2
