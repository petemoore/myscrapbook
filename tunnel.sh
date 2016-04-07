#!/bin/bash
while true
do
    ssh -L 8080:localhost:6697 people.mozilla.org
done
