#!/bin/bash

sudo cp -pr "$(dirname "${0}")/system-connections" /etc/NetworkManager/
sudo chown -R root:root /etc/NetworkManager/system-connections
