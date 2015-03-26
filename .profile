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

export PS1='\[\033[01;35m\]\u\[\033[34m\]@\[\033[36m\]\h\[\033[00m\]:\[\033[01;33m\]\w\[\033[31m\]$(git branch -l 2>/dev/null | sed -n s/^*//p) \$\[\033[00m\] '

# Setting PATH for Python 2.7
# The orginal version is saved in .profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH

export PATH="/Users/pmoore/git/tools/buildfarm/maintenance:/Users/pmoore/git/mozilla:${PATH}:/Users/pmoore/AWS-ElasticBeanstalk-CLI-2.6.0/eb/macosx/python2.7:/Users/pmoore/hg/braindump/utils:/Users/pmoore/rabbitmq_server-3.4.3/sbin"

function ag { grep -r "${1}" .; }
export -f ag

# Setting PATH for Python 2.7
# The orginal version is saved in .profile.pysave
PATH="~/npm-global/bin:/usr/local/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}:/usr/local/mysql/bin:/Users/pmoore/go/bin"
export PATH

ssh-add ~/.ssh/id_rsa
alias ssh='ssh -A'
alias p='patch -p1 -i -'
alias c='pastebin | pbcopy'

function watch { while true; clear; date; do "${@}"; sleep 2; done; }
export GOPATH=/Users/pmoore/go
function venv {
    rm -rf ~/"venvs/${1}"
    virtualenv ~/"venvs/${1}"
    source ~/"venvs/${1}/bin/activate"
}

# Load rbenv automatically by adding
# the following to ~/.bash_profile:

eval "$(rbenv init -)"


export DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}:/usr/local/lib"
source ~/env.sh
