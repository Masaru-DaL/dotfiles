# -----------------------------
# Alias
# -----------------------------
alias ls=''
alias ll='exa -al'
alias cat='bat'

# git
alias gb='git branch'
alias gc='git checkout'
alias gbd='git branch -D'
alias ga='git add . && git status'
alias gp='git pull origin $(git branch --show-current)'

# terraform
alias tplan='terraform plan'
alias taaa='terraform apply -auto-approve'
alias td='terraform destroy'

# -----------------------------
# Warp
# -----------------------------
# 引数にタブの名前を渡す
newtab() {
	osascript <<EOF
	tell application "System Events"
		# 新しいタブを開く
    keystroke "t" using command down

		# タブに名前を付ける
		keystroke "r" using command down
		delay 0.5
		keystroke "$1"
		keystroke return

		# 画面を分割する
		keystroke "d" using command down
		delay 0.5
		keystroke "[" using command down
		delay 0.5
		keystroke "d" using {command down, shift down}
		delay 1

		# 各画面で実行する
		keystroke "cmatrix"
		keystroke return
		delay 0.5
		keystroke "[" using command down
		keystroke "sl"
		keystroke return
		delay 0.5
		keystroke "[" using command down
		keystroke "neofetch"
		keystroke return
	end tell
EOF
}

# 関数を呼び出す場合
# newtab "YourTabName"


## cd -> ls(HOMEじゃない場合)
chpwd() {
	if [[ $(pwd) != $HOME ]]; then;
		exa
	fi
}

# モジュールの有効化
## color
autoload -Uz colors && colors
## tab補完
autoload -Uz compinit && compinit

export CLICOLOR=1

# pathの追加
typeset -U path PATH
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /Library/Apple/usr/bin
)

# completions / autosuggestions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  autoload -Uz compinit && compinit
fi

## suggestionsの色を変更
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=180'

# 空行を追加するようにする
add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}
precmd() { add_newline }

# zsh-git-prompt
source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh

function left-prompt {
  name_t='075m%}'      # user name text clolr
  name_b='237m%}'    # user name background color
  path_t='191m%}'     # path text clolr
  path_b='026m%}'   # path background color
  arrow='087m%}'   # arrow color
  text_color='%{\e[38;5;'    # set text color
  back_color='%{\e[30;48;5;' # set background color
  reset='%{\e[0m%}'   # reset
  sharp='\uE0B0'      # triangle

  user="${back_color}${name_b}${text_color}${name_t}"
  dir="${back_color}${path_b}${text_color}${path_t}"
  echo "${user}%m@($(arch))${back_color}${path_b}${text_color}${name_b}${sharp} ${dir}%c ${reset}${text_color}${path_b}${sharp}${reset}\n${text_color}${arrow}-> ${reset}"
}

PROMPT=`left-prompt`

# git ブランチ名を色付きで表示させるメソッド
function rprompt-git-current-branch {
  local branch_name st branch_status

  branch='\ue0a0'
  color='%{\e[38;5;' #  文字色を設定
  green='114m%}'
  red='001m%}'
  yellow='227m%}'
  blue='033m%}'
  reset='%{\e[0m%}'   # reset

  # if [ ! -e  ".git" ]; then
  if [ ! -e  ".git" ]; then
    # git 管理されていないディレクトリは何も返さない
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全て commit されてクリーンな状態
    branch_status="${color}${green}${branch}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # git 管理されていないファイルがある状態
    branch_status="${color}${red}${branch}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git add されていないファイルがある状態
    branch_status="${color}${red}${branch}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commit されていないファイルがある状態
    branch_status="${color}${yellow}${branch}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "${color}${red}${branch}!(no branch)${reset}"
    return
  else
    # 上記以外の状態の場合
    branch_status="${color}${blue}${branch}"
  fi
  # ブランチ名を色付きで表示する
  echo "${branch_status}$branch_name${reset}"
}

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

# プロンプトの右側にメソッドの結果を表示させる
RPROMPT='`rprompt-git-current-branch`'

# macOS 12 Monterey 以降ではデフォルトパス内に python コマンドが存在しないため、エイリアスを設定しないと git_super_status が機能しません。
alias python="python3"

# インストールしたコマンドを即認識させる
zstyle ":completion:*:commands" rehash 2

# enchancd
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

export TERM=xterm-256color

#スライム
TEXTDIR=~/DQ/text
NUM=$(($RANDOM % 100))
#スライム 40%の確率 (RANGE: 0-39)
if [ $NUM -lt 40 ]; then
  sed -e 's/^/\t/g' $TEXTDIR/slime.txt
  [ $PROMPT = "ON" ] &&  prompt "スライム" "\t\t\t"
#ベス 25%の確率 (RANGE: 40-64)
elif [ $NUM -lt 65 ]; then
  sed -e 's/^/\t/g' $TEXTDIR/slime-beth.txt
  [ $PROMPT = "ON" ] &&  prompt "スライムベス" "\t\t\t"
#バブル 20%の確率 (RANGE: 65-84)
elif [ $NUM -lt 85 ]; then
  cat $TEXTDIR/bubble-slime.txt
  [ $PROMPT = "ON" ] &&  prompt "バブルスライム" "\t\t"
#メタル 10%の確率 (RANGE: 85-94)
elif [ $NUM -lt 95 ]; then
  sed -e 's/^/\t/g' $TEXTDIR/metal-slime.txt
  [ $PROMPT = "ON" ] &&  prompt "メタルスライム" "\t\t"
#はぐれ 4%の確率 (RANGE: 95-98)
elif [ $NUM -lt 99 ]; then
  cat $TEXTDIR/hagure-metal.txt
  [ $PROMPT = "ON" ] &&  prompt "はぐれメタル" "\t\t\t"
#3種盛り 1%の確率 (RANGE: 99)
elif [ $NUM -eq 99 ]; then
  cat $TEXTDIR/slime-allstar.txt
  [ $PROMPT = "ON" ] &&  prompt "allstar"
fi

# Settings for fzf
export PATH="$PATH:$HOME/.fzf/bin"
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS='--height 30% --border'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# 小文字でも大文字ディレクトリ、ファイルを補完できるようにする
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# GoのPATHの追加
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export GOBIN=$HOME/go/bin

# tmux起動コマンド
#!/bin/bash
# alias @tmux="tmux new-session \; split-window -h -p 50 \; select-pane -t 1 \; split-window -v -p 30 \; send-keys -t 1 neofetch Enter \; select-pane -t 2 \; clock-mode \; select-pane -t 0"

export TMUX_TMPDIR=/tmp/tmp.tmux
export WORDCHARS='*?_.[]~-=&;!#$%^(){}<> '

export PATH=$PATH:/usr/local/mysql-8.0.26-macos11-arm64/bin
export PATH=$PATH:/Users/masaru/.tfenv/bin

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/masaru/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/masaru/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/masaru/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/masaru/google-cloud-sdk/completion.zsh.inc'; fi

export PATH=$PATH:/path/to/google-cloud-sdk/bin

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
