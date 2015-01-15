#!/bin/bash
# Proper header for a Bash script.
./dcc < samples/$1.frag > output.txt
diff output.txt samples/$1.out
echo DONE
