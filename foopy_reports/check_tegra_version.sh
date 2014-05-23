#!/bin/bash

for ((i=25; i<=128; i++))
do
    foopy="foopy${i}"
    ssh "cltbld@${foopy}"
