#!/bin/bash
while true
do
    ssh -L 8080:localhost:9999 people.mozilla.org
done
