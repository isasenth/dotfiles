# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

DOTFILES_PATH=~/.dotfiles/
# Load private environment variables if the file exists
if [ -f "$DOTFILES_PATH/zsh/.env" ]; then
  source "$DOTFILES_PATH/zsh/.env"
fi

# path for brew
export PATH="/opt/homebrew/Cellar/libpq/17.6/bin/:$PATH"
# path for poetry
export PATH="/Users/isase/.local/bin:$PATH"
# path for psql
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"


# --------------------
# alias custom command
# --------------------
export tf=~/tgk/takumi_force/dev/takumi-force-app
export tfc=$tf/client
export tfs=$tf/server

# --------------------
# alias custom command
# --------------------
alias ls='ls -GF'
alias la='ls -laGF'
# cdをするとlsをしてフォルダ内のファイル一覧を表示
alias cd='(){cd $1 && ls}'
# git logをグラフできれいに表示する
alias gl="git log --graph --branches --remotes --tags --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --abbrev-commit"
# tmuxペインパターン
alias ide='tmux split-window -h -l 25% && tmux split-window -v -l 66% && tmux select-pane -L'
# vim to nvim
alias vim='nvim'


alias dev-ssm-w=$AWS_START_SSM_SESSION_COMMAND_DEV_WRITABLE
alias prd-ssm-w=$AWS_START_SSM_SESSION_COMMAND_PRD_WRITABLE
alias prd-ssm-r=$AWS_START_SSM_SESSION_COMMAND_PRD_READONLY
alias prd-psql-admin='psql -h localhost -p 8888 -U prdtfrdsusername -d takumiforce'
alias prd-psql-write='psql -h localhost -p 8888 -U write_user -d takumiforce'
alias prd-psql-read='psql -h localhost -p 8888 -U readonly_user -d takumiforce'

# --------------------
# other native zsh settings
# --------------------
# disable "ctrl+D to close terminal"
set -o ignoreeof

setopt share_history

# 補完機能
# サブコマンドやファイルの候補を出す
# また、上下矢印で選択肢を移動して選択できる
autoload -U compinit
compinit
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' format '%B%d%b'

# --------------------
# fzf
# --------------------
# ctrl-u / ctrl-d で fzf のプレビューのページ送りをする
export FZF_DEFAULT_OPTS="--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down,ctrl-f:preview-page-down,ctrl-b:preview-page-up,ctrl-j:preview-down,ctrl-k:preview-up"

# ブランチ一覧から選択・ファジー検索できるようにする関数
# バッファの途中に選択したブランチ名が入る
# previewにそのブランチのgit logが表示される
# ctrl-g でこの関数を実行する
function fzf-git-select-branch() {
  local branch=`git branch -a --color=always | cut -c 3- | fzf-tmux --ansi -p 80% --preview 'git log --graph --pretty=format:"<%an - %cd> %s" --date=format:"%Y-%m-%d %H:%M" {} --' --preview-window 'wrap'`
  BUFFER="${BUFFER}${branch}"
  zle redisplay
}
zle -N fzf-git-select-branch
bindkey '^G' fzf-git-select-branch

# git logをfzfで表示する。
# 複数選択したのちにエンターキーでハッシュキーがBUFFERに入る。
# これはキーバインドせずにaliasするのでBUFFER操作はしない
function fzf-git-preview-log() {
local branch=`gl --color=always | fzf --ansi --track --no-sort --layout=reverse-list --multi --bind 'enter:execute(echo {+} | grep -o "[a-f0-9]\{7\}" | tr "\n" " ")+abort'`
  print -z $branch
}
zle -N fzf-git-preview-log
alias glp=fzf-git-preview-log

# バッファの最後の文字列をパスとして、そのパス内をfzfで検索する。
# 選択されたパスがバッファに入る。
# 例） `cp ~` でctrl-f → ~内でfzf検索する
# 例） `` でctrl-f → カレントディレクトリ内でfzf検索する
# fzf-find-directoryのみで十分かもなので今は利用していないが残している
function fzf-find-files() {
  sep=" "
  arguments=(${(ps.$sep.)BUFFER}) # バッファの文字列をスペースでsplitする
  fzf_path=${arguments[-1]:-.} # 最後の文字列をパスとして読み込み、存在しなければカレントディレクトリを指定
  fzf_path=${fzf_path:s/~/$HOME} # 文字列形式の~は動作しないため絶対パスに変換する
  local selected_path=`\
    find ${fzf_path} | \
      fzf-tmux \
      -p 80% \
      --height 80% \
      --preview 'if [[ -d {} ]]; then ls -aF {} ; else cat {}; fi'\
    ` # プレビューでは、ディレクトリならlsを、ファイルならcatをプレビューする。
  arguments[-1]=$selected_path # バッファの文字列部分を選択されたパスで置換する
  BUFFER="${arguments}" # バッファの更新
  CURSOR=$#BUFFER # バッファの末尾にカーソルを配置
  zle redisplay
}
zle -N fzf-find-files

# fzf-find-files のディレクトリ検索版
function fzf-find-directory() {
  sep=" "
  arguments=(${(ps.$sep.)BUFFER}) # バッファの文字列をスペースでsplitする
  fzf_path=${arguments[-1]:-.} # 最後の文字列をパスとして読み込み、存在しなければカレントディレクトリを指定
  fzf_path=${fzf_path:s/~/$HOME} # 文字列形式の~は動作しないため絶対パスに変換する
  local selected_path=`\
    find ${fzf_path} -type d | \
      fzf-tmux \
      --ansi \
      -p 80% \
      --height 80% \
      --preview 'ls -aFG {}'\
    `
  arguments[-1]=$selected_path # バッファの文字列部分を選択されたパスで置換する
  BUFFER="${arguments}" # バッファの更新
  CURSOR=$#BUFFER # バッファの末尾にカーソルを配置
  zle redisplay
}
zle -N fzf-find-directory
bindkey '^f' fzf-find-directory

# コマンド履歴からfzf検索
# ctrl-r でこの関数を実行する
function fzf-find-history() {
  local selected_command=`\
    history -n -50 | \
      fzf-tmux \
      -p 80% \
      --height 80% \
      --tac \
    ` # プレビューでは、ディレクトリならlsを、ファイルならcatをプレビューする。
  BUFFER="$selected_command" # バッファの更新
  CURSOR=$#BUFFER # バッファの末尾にカーソルを配置
  zle redisplay
}
zle -N fzf-find-history
bindkey '^r' fzf-find-history

# --------------------
# path and setup for nvm
# --------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm.
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion (works for zsh too)

# --------------------
# zsh packages
# --------------------
# load zinit - zsh package manager
source $HOMEBREW_PREFIX/opt/zinit/zinit.zsh

# zsh-autosuggestions - コマンドを予測して候補をグレーで出してくれる
zinit light zsh-users/zsh-autosuggestions

# powerlevel10k - promptのUIを良い感じにしてくれる
zinit ice depth=1; zinit light romkatv/powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# zsh-syntax-highlighting - コマンドをシンタックスハイライトしてくれる
# must be at the end of zshrc (after all widgets are configured)
zinit light zsh-users/zsh-syntax-highlighting

