# husen.nvim

bufferline.nvimとbento.nvimにインスパイアされたバッファ管理プラグイン。

## 機能

- **Floating Window UI**: bento.nvimスタイルのフローティングウィンドウでバッファリストを表示
- **Buffer Navigation**: bufferline.nvimスタイルのバッファ切り替え/並び替えAPI

## API

- **`cycle(direction)`**: バッファを循環的に切り替え
  - `direction`: 1 で次へ、-1 で前へ

- **`move(direction)`**: 現在のバッファの順序を移動
  - `direction`: 1 で右へ、-1 で左へ

- **`toggle_ui()`**: フローティングウィンドウでバッファリストを表示/非表示

## セットアップ

```lua
require("husen").setup({
  ui = {
    width = nil,           -- nil で自動幅、数値で固定幅
    position = "top-right", -- "top-right", "top-left", "bottom-right", "bottom-left", "center"
    offset_x = 0,
    offset_y = 0,
  },
  wrap_at_ends = true,     -- 端で折り返すか
  keymaps = {
    toggle = "<leader>b",  -- false で無効化、文字列でカスタムキー
    cycle_next = "]b",
    cycle_prev = "[b",
    move_next = "]B",
    move_prev = "[B",
  },
})
```

## 実装の参考元

- [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim) - `cycle()`と`move()`のAPI
- [serhez/bento.nvim](https://github.com/serhez/bento.nvim) - フローティングウィンドウUI
