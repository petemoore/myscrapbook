#!/bin/bash

# This script gets called as soon as the sshd daemon has been setup on
# the target machine. This script runs directly on the target machine
# itself. It runs as the user that was specified to setup_cygwin.bat
# script, which probably needs to be an admin on the target machine.

# It currently performs the following steps:
#
#     1) Sets the prompt to a pretty description of the current directory
#     2) Generates a unique private/public key pair for this user
#     3) Sets the VI options (colours, line numbers, tab stops...)
#     4) Create ssh keys

# The script should intelligently identify for each step if it has
# already been done, and if so, not redo it - so the script can be run
# on a regular basis without having an adverse effect on an installation.

set -e

function add_if_missing {
    LINE="${1}"
    FILE="${2}"
    grep -Fx "${LINE}" "${FILE}" >/dev/null 2>&1 || echo "${LINE}" >> "${FILE}"
}

echo "Running setup.sh script..."
echo

echo "  * Setting PS1 environment variable in .bashrc"
add_if_missing 'export PS1='"'"'\[\033[01;35m\]\u\[\033[34m\]@\[\033[36m\]\h\[\033[00m\]:\[\033[01;33m\]\w\[\033[31m\] \$\[\033[00m\] '"'" ~/.bashrc
echo "  * Making sure ~/env.sh gets sourced in .bashrc"
add_if_missing 'source ~/env.sh' ~/.bashrc
echo "  * Making sure there is a pair of public/private keys"
[ ! -e ~/.ssh/id_rsa ] || [ ! -e ~/.ssh/id_rsa.pub ] && ssh-keygen -b 1024 -t rsa -N '' -f ~/.ssh/id_rsa
echo "  * Setting syntax highlighting in vi"
add_if_missing 'syntax on' ~/.vimrc
echo "  * Setting colour scheme in vi"
add_if_missing 'colorscheme murphy' ~/.vimrc
echo "  * Enabling line numbers in vi"
add_if_missing 'set number' ~/.vimrc
echo "  * Setting tab to four spaces in vi"
add_if_missing 'set tabstop=4' ~/.vimrc

# Example: set up new drive mappings:
# echo "  * Setting up J:\ drive to map to \\\\server1234\\d$"
# net use J: '/DELETE' >/dev/null 2>&1 || true
# net use J: '\\server1234\d$' 'password' '/USER:domainX\userY' '/PERSISTENT:YES' >/dev/null 2>&1

echo
echo "Setup script completed successfully."
