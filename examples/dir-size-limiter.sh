#!/usr/bin/env bash
#
# Limit directory to a certain size.
# When quota is exceeded, delete oldest file(s) recursively.

DIRECTORY=$1
QUOTA=$2
DIRSIZE=$(du -sk "$DIRECTORY" | cut -f1)

echo
echo "dir-size-limiter: when directory size is above quota, delete oldest file(s)"
echo
echo "WARNING! This script has no safety/sanity checks. Use at your own risk!"
echo "(Currently it does nothing though)"
echo
echo "Directory to limit: $DIRECTORY"
echo "Current directory size: $DIRSIZE"
echo "Quota: $QUOTA"

echo "dir-size-limiter: done!"
