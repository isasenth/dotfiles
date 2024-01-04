# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# --------------------
# alias custom command
# --------------------
alias ls='ls -F'
alias la='ls -la'
# cdをするとlsをしてフォルダ内のファイル一覧を表示
alias cd='(){cd $1 && ls}'
# git logをグラフできれいに表示する
alias gl="git log --graph --branches --remotes --tags --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --abbrev-commit"
# tmuxペインパターン
alias ide='tmux split-window -h -p 15 && tmux split-window -v -p 33'

# --------------------
# other native zsh settings
# --------------------
# disable "ctrl+D to close terminal"
set -o ignoreeof

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
export FZF_DEFAULT_OPTS="--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"

# ブランチ一覧から選択・ファジー検索できるようにする関数
# バッファの途中に選択したブランチ名が入る
# previewにそのブランチのgit logが表示される
# ctrl-g でこの関数を実行する
function fzf-git-select-branch() {
  local branch=`git branch -a | cut -c 3- | fzf-tmux -p 80% --preview 'git log --graph --pretty=format:"<%an - %cd> %s" --date=format:"%Y-%m-%d %H:%M" {} --' --preview-window 'wrap'`
  BUFFER="${BUFFER}${branch}"
  zle redisplay
}
zle -N fzf-git-select-branch
bindkey '^G' fzf-git-select-branch

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
      -p 80% \
      --height 80% \
      --preview 'ls -aF {}'\
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
    ` # プレビューでは、ディレクトリならlsを、ファイルならcatをプレビューする。
  BUFFER="$selected_command" # バッファの更新
  CURSOR=$#BUFFER # バッファの末尾にカーソルを配置
  zle redisplay
}
zle -N fzf-find-history
bindkey '^r' fzf-find-history

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
