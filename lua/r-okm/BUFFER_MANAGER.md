# Buffer Manager

bufferline.nvimとbento.nvimにインスパイアされたバッファ管理モジュール。

## 機能

### API

- **`cycle(direction)`**: バッファを循環的に切り替え
  - `direction`: 1 で次へ、-1 で前へ
  - bufferline.nvimの`cycle()`に相当

- **`move(direction)`**: 現在のバッファの順序を移動
  - `direction`: 1 で右へ、-1 で左へ
  - bufferline.nvimの`move()`に相当

- **`toggle_ui()`**: フローティングウィンドウでバッファリストを表示/非表示
  - bento.nvimのUIスタイルに相当
  - フォーカスせずに表示

### デフォルトキーマップ

- `<leader>b`: バッファマネージャーをトグル表示
- `]b`: 次のバッファへ移動 (cycle)
- `[b`: 前のバッファへ移動 (cycle)
- `]B`: バッファを右へ移動 (move)
- `[B`: バッファを左へ移動 (move)

### フローティングウィンドウの特徴

- フォーカスなしで表示（編集を続けながら確認可能）
- バッファ切り替え時に自動更新
- トグル動作（同じキーで開閉）

## カスタマイズ

```lua
require("r-okm.buffer_manager").setup({
  ui = {
    width = 60,        -- ウィンドウの幅
    height = 15,       -- ウィンドウの高さ
    border = "none",   -- ボーダースタイル ("none", "rounded", "single", etc.)
    position = "top-right", -- 位置: "center", "top-right", "top-left", "bottom-right", "bottom-left"
  },
  wrap_at_ends = true,  -- 端で折り返すか
})
```

## 実装の参考元

- [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim) - `cycle()`と`move()`のAPI
- [serhez/bento.nvim](https://github.com/serhez/bento.nvim) - フローティングウィンドウUI
