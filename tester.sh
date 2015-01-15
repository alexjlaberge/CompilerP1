#!/bin/bash
# Proper header for a Bash script.

for input in `ls samples/*.frag samples/*.decaf | grep -v "/bad"`
do
        echo -ne "Testing ${input}..."
        ./dpp < ${input} | ./dcc | diff -q \
                `echo ${input} | sed -e "s/\..*/\.out/"` - && echo
done
