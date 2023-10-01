#!/usr/bin/env python3
"""
Keep directory size within given quota by deleting oldest files
"""

# ============================================================================ #

import argparse
import sys
import time
from os import stat_result
from pathlib import Path
from shutil import disk_usage

# ============================================================================ #

def parse_args() -> argparse.Namespace:

	parser = argparse.ArgumentParser()

	# TODO: add size suffix (kb, MB, ...) parsing
	parser.add_argument('-s', '--size',
	                    type=int,
	                    help="limit directory size")

	parser.add_argument('-n', '--numfiles',
	                    type=int,
	                    help="limit number of files in the directory")

	# TODO: parse as string with possible trailing '%'
	parser.add_argument('-p', '--percent',
	                    type=float,
	                    help="limit directory size as percent of disk (volume) size")

	parser.add_argument('--include',
	                    nargs='*',
	                    help="only delete files matching given glob pattern[s]")

	parser.add_argument('--exclude',
	                    nargs='*',
	                    help="don't delete files matching given glob pattern[s]")

	parser.add_argument('-r', '--recursive',
	                    help="include subdirectories (default: only delete files at given level)")

	parser.add_argument('--dirignore',
	                    nargs='*',
	                    default='.git',
	                    help="if recursing, ignore subdirs matching given pattern[s] (default: %(default)s)")

	parser.add_argument('--delete',
	                    action='store_true',
	                    help="actually delete files (default: only print file list)")

	# TODO: allow multiple directories (they'll be processed as one)
	parser.add_argument('dir',
	                    nargs='+',
	                    help="director[y|ies] to process")

	args = parser.parse_args(args=None if sys.argv[1:] else ['--help'])

	if not args.dir:
		parser.error('no directory specified')
	elif not (args.size or args.numfiles or args.percent):
		parser.error('no quota specified')

	return args

# ============================================================================ #

def dir_size(p: Path) -> int:
	size: int = 0
	for child in p.rglob("*"):
		size += child.stat(follow_symlinks=False).st_size
		# print(time.asctime(time.gmtime(child.stat(follow_symlinks=False).st_mtime)))
	return size

# ============================================================================ #

def scan_tree(rootdir: Path, dirignore: str, fileignore: str):
	"""
	Recursively scan directory tree, yielding file entries

	Args:
		rootdir (Path): _description_
		dirignore (str): glob pattern of ignored dirs (TODO: accept list of patterns)
		fileignore (str): glob pattern of ignored files (TODO: accept list of patterns)

	Yields:
		_type_: _description_
	"""
	for entry in rootdir.iterdir():
		if (entry.is_dir()
		   and not entry.is_symlink()
		   and not (entry.name in dirignore)):
			yield from scan_tree(entry, dirignore, fileignore)
		elif entry.is_file() and \
		     not entry.is_symlink() and \
		     not Path(entry.name).match(fileignore):
			yield entry
		else:
			continue

# ============================================================================ #

def main() -> int:

	args = parse_args()

	dirpath = Path(args.dir)
	# Allow root dir to be a symlink
	if not dirpath.is_dir():
		raise NotADirectoryError("path is not a directory")

	entries: list[stat_result] = []
	dirsize = dir_size(dirpath)
	oversize: int = 0

	print("Directory size: ", dirsize, "bytes")

	pattern = "*"
	if args.include:
		pattern = args.include
	if args.recursive:
		pattern = "**/" + pattern

	if args.size:
		print("Absolute size quota: ", args.size, "bytes")
		if dirsize > args.size:
			oversize = dirsize - args.size
			print("Directory is over quota by: ", oversize, "bytes")

	if args.percent:
		quota: int = disk_usage(dirpath).total * args.percent // 100
		print("Disk usage quota: ", quota, "bytes")
		if dirsize > quota:
			oversize = dirsize - quota
			print("Directory is over quota by: ", oversize, "bytes")

	if oversize >= dirsize:
		raise ValueError("quota can't be satisfied")

	return 0

# ============================================================================ #

if __name__ == '__main__':
	sys.exit(main())
