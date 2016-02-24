#!/bin/bash
# this script touches files in scratrch
# to avoid killing automatically
# obviously for ocassional use...
cd ~/scratch
find . -atime +30 -exec touch {} \;

