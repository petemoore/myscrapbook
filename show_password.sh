#!/bin/bash

# gpg --no-tty -d pete.txt.gpg
gpg -d "$(dirname "${0}")/pete.txt.gpg" 2>/dev/null
