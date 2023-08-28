#!/bin/sh
#
# Limit directory to a certain size.
# When quota is exceeded, delete oldest file(s) recursively.

thedir=$1
quota=$2
dirsize=$(du -sk "$thedir" | cut -f1)

echo
echo "dir-size-limiter: when directory size is above quota, delete oldest file(s)"
echo
echo "WARNING! This script has no safety/sanity checks. Use at your own risk!"
echo "(Currently it does nothing though)"
echo
echo "Directory to limit: $thedir"
echo "Current directory size=$dirsize"
echo "Quota: $quota"

echo "dir-size-limiter: done!"
