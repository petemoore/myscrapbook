#!/bin/bash

if [ -e "$HOME/.configuration" ]; then
    source "$HOME/.configuration"
fi

# ssh autocompletion (source)
# http://serverfault.com/questions/170361/how-to-edit-command-completion-for-ssh-on-bash
SSH_COMPLETE=( $(cut -f1 -d' ' ~/.ssh/known_hosts |\
                 tr ',' '\n' |\
                 sort -u |\
                 grep -e '[:alpha:]') )
complete -o default -W "${SSH_COMPLETE[*]}" ssh

# git completion bash
if [ -e "$GIT_COMPLETION_BASH" ]; then
    source "$GIT_COMPLETION_BASH"
fi

export GOPATH=~/go
alias cdgo='cd "${GOPATH}/src/github.com/petemoore"'
alias vigo='vi $(find . -name Godeps -prune -o -name "*.go" -print)'

export PS1='\[\033[01;35m\]\u\[\033[34m\]@\[\033[36m\]\h\[\033[00m\]:\[\033[01;33m\]\w\[\033[31m\]$(git branch -l 2>/dev/null | sed -n s/^*//p) \$\[\033[00m\] '
export PATH="/usr/local/bin:/Users/pmoore/git/tools/buildfarm/maintenance:/Users/pmoore/git/mozilla:${PATH}:/usr/local/mysql/bin:/Users/pmoore/AWS-ElasticBeanstalk-CLI-2.6.0/eb/macosx/python2.7:/Users/pmoore/hg/braindump/utils:${GOPATH}/bin:/Users/pmoore/rabbitmq_server-3.4.3/sbin"

# share history between bash shells
export PROMPT_COMMAND='history -a; history -r'

function ag { grep -r "${1}" .; }
export -f ag

ssh-add ~/.ssh/id_rsa
alias ssh='ssh -A'
alias p='patch -p1 -i -'
alias c='pastebin | pbcopy'
export PS1='\[\033[01;35m\]\u\[\033[34m\]@\[\033[36m\]\h\[\033[00m\]:\[\033[01;33m\]\w\[\033[31m\] \$\[\033[00m\] '
source ~/env.sh

function watch { while true; clear; date; do "${@}"; sleep 2; done; }
function venv {
    rm -rf ~/"venvs/${1}"
    virtualenv ~/"venvs/${1}"
    source ~/"venvs/${1}/bin/activate"
}

# Load rbenv automatically by adding
# the following to ~/.bash_profile:

eval "$(rbenv init -)"



### Added by the Heroku Toolbelt
export PATH="~/npm-global/bin:/usr/local/heroku/bin:$PATH"
export DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}:/usr/local/lib"
