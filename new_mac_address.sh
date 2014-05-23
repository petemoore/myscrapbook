#!/bin/bash

# sudo ifconfig en0 ether $(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')
sudo ifconfig en0 ether '92:de:aa:4f:e7:a9'

