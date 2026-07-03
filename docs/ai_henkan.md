# ai_henkan — ローマ字→日本語 AI 変換

nvim 内でローマ字を Claude を使って日本語(かな漢字交じり文)へ変換する機能。エンジンは `lua/r-okm/ai_henkan.lua`。

このドキュメントは、コードや git 履歴から読み取れない設計判断(「なぜこうなっているか」)を記録する。実装を変更する前に一読すること。

## 実行方式: `claude -p` 常駐

- `claude -p` を `--input-format stream-json` で**常駐**させ、プロセスを使い回す。単発起動は 5〜8 秒だが、常駐で 2.5〜4 秒/回(実測)。OAuth のまま動作し追加費用なし。
- バックエンド差し替え(API 直叩き / Copilot CLI)は**不採用**(2026-06-09 決定):
  - Anthropic API 直叩きは最速(1〜2s)だが API キー別課金が必要。OAuth トークンは Messages API に使えない。
  - Copilot CLI は既定モデルが Claude Sonnet 4.6 で Copilot サブスクのまま使えるが、単発 12.5s と遅く、常駐化は ACP が必要で複雑。
- WSL2 高速化の `CLAUDE_CODE_SKIP_WINDOWS_PROFILE` は claude 2.1.169 環境では**無効**と実証済み(powershell.exe は 0 回、reg.exe 2 回 ~0.1s のみ)。

## モデル / プロンプト

- モデル/effort はベンチ済みで **sonnet / low で確定**。opus は遅くムラが大きい割に精度の上積みなし。haiku は雑談混入・誤訳で失格。effort はこのタスクでは精度にほぼ無関係。
- システムプロンプトは `--append-system-prompt` ではなく **`--system-prompt`(本体プロンプトを置換)** を使う。append だと Claude Code 本体のエージェント用プロンプトが残り、指示文っぽい入力(例 `...sitai`, `tasuketekudasai`)が変換されず会話応答に化ける。置換すれば解消。OAuth でも動作する。
- スペース区切り入力は語区切りヒントとして Claude に渡す(出力には残さない)。同音異義語などの難ケースで精度が向上する(ベンチで確認)。

## プロセス管理

- busy 中のリクエストは FIFO キューイング(pump 方式)。
- N=30 回 or アイドル 5 分でプロセス再起動。
- nvim 終了時(VimLeavePre)は jobstop(SIGTERM、約 2 秒待ち)ではなく **SIGKILL**(`vim.loop.kill(jobpid, "sigkill")`、0.03 秒)で落とす。終了高速化のため。
- kill 処理は `kill_job()` ヘルパに集約(timeout / restart / idle / VimLeavePre 共通)。
- タイムアウト処理の順序に注意: finish→pump→jobstop の順だと次リクエストを巻き添え kill / 混線しうる。**pump せず current を先に nil 化 → `kill_job()` → on_exit が pump する**順にすること。
- prewarm: `M.prewarm()`(ensure_job のみ)を `config/autocmd.lua` の InsertEnter(once=true)で呼び、初回変換の起動待ちを短縮(実測 2.45s→1.74s)。autocmd.lua は起動時に require されるためモジュールも起動時ロードされる。

## 編集セマンティクス

- ノーマルモードは**オペレータ**(`<leader>j` + テキストオブジェクト/モーション、例 `<leader>jiw`)。`M.op` を operatorfunc に設定して `g@`。`<leader>jj` で現在行、`:AIHenkan` も現在行。挿入モードは `<C-j>`(convert_insert・挿入継続)、ビジュアルは `<leader>j`(`:<C-u>` 経由で convert_visual、V/v 対応)。矩形(block)は未対応。
- range extmark で非同期変換中の範囲ズレに追従する。charwise は `nvim_buf_get_text` / `set_text` でマルチバイト前後を保持。
- charwise の `'>` / `']` は最終文字の**先頭バイト**を指すため、`charwise_end_col`(`vim.str_utf_end`)で文字境界に揃える。マルチバイト混在選択での途中切れ防止。
- 空白の扱い: convert_region は前後の空白(インデント・直前直後スペース)を温存し、core のみ変換する。
- undo: `undojoin` は不採用。変換を独立 undo にする方が戻しやすい。
- カーソル: 変換後は変換テキスト末尾(挿入位置の終端 = cs + #out[1]。行末ではない)へ移動し、オペレータの先頭戻りを上書きする。end_col は行バイト長でクランプ。変換中にユーザーがよそへ移動していたら触らない。

## UI

- 変換中インジケータ: 範囲追従 extmark に `virt_text={{" [変換中…]","AIHenkanProgress"}}`(`virt_text_pos="eol"`)を付与。完了/エラー時の extmark 削除で自動消去。開始時 notify は廃止(virt_text が代替)、完了時 vim.notify は維持。
- ハイライト `AIHenkanProgress` は Comment に default link(ユーザー上書き可)。
- 挿入モードで候補選択を将来やる場合は `complete()`(`mode()=='i'` ガード + word=""/abbr)で。

## その他の判断

- win↔buf 不一致対策は不要(current buf は必ず現 win の buf)。
- idle_timer は `close()` すること。
