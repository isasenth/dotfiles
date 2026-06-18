# dotfiles for vim

## Pre-requisites

- Homebrew のインストールと `brew install vim` の実施
  - vim のバージョンアップ、vim-plug のインストールで利用するため
- fzf
  - fzf.vim で利用するため
- the_silver_searcher(ag コマンド)
  - fzf.vim で利用するため
- (Optional) git-delta
  - git-delta があると、fzf.vim の git diff がより美しく表示される

## 使い方

Vim とプラグインの使い方

### native Vim

- :terminal
  - vim 内で terminal モードを開始
- colorschemes
  - [サイト](https://vimcolorschemes.com/)から良いのがあったら vim-plug にインストールして利用
- vimdiff
  - do/dp(obtain/put) で diff 間の反映ができる
- [insert モードでのキーバインディング](https://qiita.com/34ro/items/6163f595785ae99a632a)

### vim-plug

- インストール時
  - vimrc にインストールしたいプラグインを追加
  - vimrc を読み込み直して`:PlugInstall`
- アンインストール時
  - vimrc から不要なプラグインを消去
  - vimrc を読み込み直して`:PlugClean`

### coc

- プラグイン追加時
  - vimrc の `let g:coc_global_extensions` に追加
  - vimrc を読み込み直すと自動でインストールされる
- config の修正
  - coc-settings.json を書き換える
- ctrl-y → suggestions を反映する

### fzf

- :Commits
  - Git コミット一覧を diff プレビューで表示する
  - ctrl + y でハッシュをコピー
- :Commands
  - Vim コマンド一覧をリスト・ファジー検索
- 一般
  - tab/shift+tab で複数選択
  - ctrl-u/ctrl-d でプレビューのページ送りをする

### fugitive

- `:G`
  - コマンドパレットを表示
  - `=` で diff 表示
  - `s/u` で stage/unstage
  - `X` でファイルをリセット
  - `v` で部分選択
  - `cc` でコミットメッセージを編集 -> `:x` でコミット
- 特定のファイルを開いて `:0Gclog` でそのファイルの履歴を見る
  - 特定のコミットで<CR>でその時点のファイルを開く
- フォーカスが特定ファイルのバッファにある状態で、`:Gdiff <commit_id>` でそのコミットにおけるそのファイルとの diff を見る

### linediff

- 範囲選択 →`:Linediff`→ 比較先を範囲選択 →`:Linediff`をすると、新しいタブに２つの選択領域の diff が表示される
- diff の中で変更をし、保存をすると元ファイルに反映される。保存しなければ元ファイルは何も変わらない

### markdown-preview

- `:MarkdownPreview` でプレビュー開始
- `:MarkdownPreviewStop` でプレビュー停止
