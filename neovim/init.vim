"--------------------
" settings for native vim
"--------------------
" TrueColorを有効化する
set termguicolors
" You might have to force true color when using regular vim inside tmux as the
" colorscheme can appear to be grayscale with "termguicolors" option enabled.
" detail: https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" set vim menu to english
let $LANG = 'en_US'

" set encodings
set encoding=utf8
set fenc=utf-8

" バックスペースで文字消去が動作するようにする
set backspace=indent,eol,start

" ステータスラインを常に表示(0:表示しない、1:2つ以上ウィンドウがある時だけ表示)
set laststatus=2

" 行番号を表示
set number relativenumber
" フォーカスのあたっているペインは相対、それ以外は絶対
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" カーソル行を強調
set cursorline

" インデント関連
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2

" ステータスバーでのディレクトリ移動の挙動を設定
set wildmenu
set wildmode=longest,list,full

" 小文字検索の場合大文字小文字区別しないが、大文字検索の場合する
set ignorecase
set smartcase
" 検索結果をハイライト
set hlsearch
" インクリメンタル検索
set incsearch

" 対応する括弧を強調
set showmatch matchtime=1

" 行をまたいで移動
set whichwrap=b,s,h,l,<,>,[,],~

" 折返し行でも上下に移動
nnoremap j gj
nnoremap k gk

" ESC二回でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" シンタックスハイライト
syntax on

" change cursor shape in normal mode and insert mode
let &t_SI = "\e[5 q"
let &t_EI = "\e[2 q"

" make regexp faster for syntax highlighting
" (or else vim will hang up)
set re=0

" vim上でyankした内容をOSのクリップボードにコピーする
set clipboard=unnamed

" :source $VIMRUNTIMEmacros/matchit.vim
set nocompatible
filetype plugin on
runtime macros/matchit.vim

" ターミナルがフォーカスされているか否かで背景色を変える
" tmuxでフォーカスのあたっているペインをわかりやすくするためで、tmuxと色を揃えている
augroup DynamicBG
  autocmd!
  " アクティブ時の背景色→（例：黒）
  autocmd FocusGained * highlight Normal ctermbg=234 guibg=#2E3440 
  " 非アクティブ時の背景色→（例：グレー）
  autocmd FocusLost   * highlight Normal ctermbg=236 guibg=#3b424f
augroup END


"--------------------
" plugins
"--------------------
call plug#begin('~/.vim/plugged')

  " ----------
  " linediff - take diff of any selected line areas
  " ----------
  Plug 'AndrewRadev/linediff.vim'

  " ----------
  " markdown-preview - live preview markdown files with browser
  " ----------
  Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
  nmap <Leader>m <Plug>MarkdownPreviewToggle

  " ----------
  " nerdcommenter - set comments in file
  " ----------
  Plug 'preservim/nerdcommenter'
  let g:NERDSpaceDelims = 1
  let g:NERDDefaultAlign = 'left'
  let g:NERDCommentEmptyLines = 1

  " ----------
  " vim-fugitive - use git functions in vim
  " ----------
  Plug 'tpope/vim-fugitive'
  " :G と打つと自動で :vertical Git に展開される
  " 縦長なほうが見やすいため
  cnoreabbrev <expr> G  (getcmdtype() ==# ':' && getcmdline() ==# 'G')  ? 'vert Git'  : 'G'

  " ----------
  " fern and related plugins - file explorer in vim
  " ----------
  Plug 'lambdalisue/fern.vim'

  " make vim's default file explorer to fern
  Plug 'lambdalisue/fern-hijack.vim'
  " <Leader>e でファイルエクスプローラーを表示し、開いているファイルまでのツリーを展開する
  nmap <Leader>e :Fern . -reveal=%<CR>
  " 隠しファイルを表示する
  let g:fern#default_hidden=1

  " preview files in fern
  Plug 'yuki-yano/fern-preview.vim'
  " 各種ショートカットキーの設定
  function! s:fern_settings() abort
    nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
    nmap <silent> <buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
    nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
    nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
    nmap <silent> <buffer> S <Plug>(fern-action-open:below)
  endfunction
  augroup fern-settings
    autocmd!
    autocmd FileType fern call s:fern_settings()
  augroup END

  " show git status in files in fern
  Plug 'lambdalisue/fern-git-status.vim'

  " show file type icons in fern
  Plug 'lambdalisue/fern-renderer-nerdfont.vim'
  Plug 'lambdalisue/nerdfont.vim'
  let g:fern#renderer = 'nerdfont'

  " ----------
  " auto-pairs - auto input other pair of brackets
  " ----------
  Plug 'jiangmiao/auto-pairs'

  " ----------
  " fzf and related plugins - fuzzy search
  " ----------
  Plug 'junegunn/fzf', { 'do': { -> fzf#install()  }  }
  Plug 'junegunn/fzf.vim'
  " ファイル名検索 - :Filesコマンドではgitignoreされているファイルも検索対象になるため、agを利用
  nmap <Leader>f :call fzf#run(fzf#vim#with_preview(fzf#wrap({'source': 'ag --hidden -g ""', 'options': '--multi'})))<CR>
  " 全ファイル検索 - gitignoreされているファイルも含む。:Filesコマンドでは隠しファイルが表示されてないためfindを利用
  nmap <Leader>af :call fzf#run(fzf#vim#with_preview(fzf#wrap({'source': 'find .', 'options': '--multi'})))<CR>
  " 全文検索 - 隠しファイルも表示し、.gitディレクトリは無視する構成
  nmap <Leader><S-f> :call fzf#vim#ag('', fzf#vim#with_preview({'source': 'ag --hidden --ignore-dir .git .', 'options': '--multi'}), 0)<CR>
  " ファイル名を検索から除外する場合） nmap <Leader><S-f> :call fzf#vim#ag('', fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), 0)<CR>
  " gitファイル検索 - :GFilesコマンドでは、ファイルエクスプローラーでエラーになり実行ができないので自作
  nmap <Leader>g :call fzf#vim#gitfiles("", fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}))<CR>
  " gitコミット検索（logのl）
  nmap <Leader>l :Commits!<CR>

  " ----------
  " coc
  " ----------
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " install coc extensions
  let g:coc_global_extensions = ['coc-json', 'coc-snippets', 'coc-eslint', 'coc-yaml', 'coc-tsserver', 'coc-pyright', 'coc-prettier']

  " Remap keys for gotos
  nmap <silent> gd :call CocAction("jumpDefinition", v:false)<CR>
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " Use K to show documentation in preview window
  nnoremap <silent> K :call <SID>show_documentation()<CR>
  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Use <c-@> to trigger completion.
  inoremap <silent><expr> <c-@> coc#refresh()


  " Use [g and ]g to navigate diagnostics
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Add status line support, for integration with other plugin, checkout :h coc-status
  set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  " scroll documentation with <C-f> / <C-b>
  if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  endif

  " ----------
  " vim-airline - customize visual of status line
  " ----------
  Plug 'vim-airline/vim-airline'
  " show full ui of airline, including symbols
  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.colnr = ' ℅:'
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ' :'
  let g:airline_symbols.maxlinenr = '☰ '
  let g:airline_symbols.dirty='⚡'

  " 現在のモードが表示されるのをOFFにする
  let g:airline_section_a = ''
  " 現在のブランチが表示されるのをOFFにする
  " let g:airline_section_b = ''
  " 現在開いているファイルパスの代わりに、ファイル名のみを表示する
  let g:airline_section_c = '%t'
  " 開いているファイルの言語を非表示にする
  let g:airline_section_x = ''
  " 文字エンコードを非表示にする
  let g:airline_section_y = ''
  " 行位置などを非表示にする
  let g:airline_section_z = ''

  " ----------
  "  claudecode
  "  ----------
  Plug 'folke/snacks.nvim'
  Plug 'coder/claudecode.nvim'
  " ClaudeCode内から他のウィンドウに <leader>c h/j/k/l で移動できるようにする
  tmap <leader>c <C-\><C-n><C-w>
  " ファイルパス 'path/to/fle' 形式でをクリップボードコピーする
  nmap <leader>y :let @+ = expand('%')<cr>
  " ファイルパスと選択行を 'file/to/path#L1-10' 形式でクリップボードコピーする
  vnoremap <leader>y :<C-u>let @+ = expand('%') . '#L' . line("'<") . '-' . line("'>")<CR>
  " Vim外のClaude Codeがファイルを変更したとき、ウィンドウのフォーカス時に変更をリロードする
  " au FocusGained,BufEnter,WinEnter,FileChangedShell * :silent! checktime

  " Vim外であった変更と、Vimで行った変更が競合したとき、それぞれのdiffを取る。
  " 左ペインが保存済ファイルで、右ペインがVimで編集中のバッファ。
  " 左の変更を見ながら右を最新にし、右を保存する。
  command! Diff vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis

  " ----------
  "  colorschemes
  " ----------
  Plug 'arcticicestudio/nord-vim'
  " diffを見やすくする
  let g:nord_uniform_diff_background = 1
  augroup nord-theme-overrides
    autocmd!
    " 未使用の変数の色をグレーに変更（元は白で分かりづらい）
    autocmd ColorScheme nord highlight CocFadeOut cterm=underline gui=underline guifg=#808080
    " コメントの色を見やすく変更
    autocmd ColorScheme nord highlight Comment  guifg=#808080
  augroup END

  Plug 'cocopon/iceberg.vim'
  " あまり良くなかった
  " Plug 'catppuccin/vim', { 'as': 'catppuccin' }
  " Plug 'sainnhe/everforest'
  " Plug 'bluz71/vim-nightfly-colors', { 'as': 'nightfly' }
  " Plug 'haishanh/night-owl.vim'
  " Plug 'embark-theme/vim', { 'as': 'embark', 'branch': 'main' }
  " Plug 'pineapplegiant/spaceduck', { 'branch': 'main' }
  " Plug 'joshdick/onedark.vim'
  " Plug 'kristijanhusak/vim-hybrid-material'
  " Plug 'Rigellute/rigel'
  " Plug 'arzg/vim-colors-xcode'

  " :Inspecthiでhighlightカラーを教えてくれる
  Plug 'cocopon/inspecthi.vim'
  

  " ----------
  " might use later
  " ----------
  " Plug 'stsewd/fzf-checkout.vim'
  " Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production', 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'] }
  " Plug 'haishanh/night-owl.vim'
  " Plug 'rafi/awesome-vim-colorschemes'
  " Plug 'Yggdroot/indentLine'
  " Syntax highlighting for MDX files
  " Plug 'jxnblk/vim-mdx-js'

call plug#end()

" set colorscheme
color nord
set background=dark


lua << EOF
require("claudecode").setup({
  terminal = {
    snacks_win_opts = {
      position = "left",
      width = 0.4,
      height = 1.0,
      border = "rounded",
      keys = {
        claude_hide = { "<leader>cc", function(self) self:hide() end, mode = "t", desc = "Hide" },
      },
    }
  },
})
EOF
