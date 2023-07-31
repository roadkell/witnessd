#!/bin/sh
#
# Limit directory to a certain size.
# When quota is exceeded, delete oldest file(s) recursively.

echo "dir-size-limiter: when directory size is above quota, delete oldest file(s)"

echo "$1"
echo "$2"

echo "dir-size-limiter: done!"
