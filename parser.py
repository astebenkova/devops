#! /usr/bin/env python3.6
from argparse import ArgumentParser
from sys import exit


parser = ArgumentParser(description="Let's say it does nothing. Just. Like. You.")
parser.add_argument("filename", help="The file to check")
parser.add_argument("--version", "-v", action="version", version="%(prog)s 1.0.0")

args = parser.parse_args()

try:
    f = open(args.filename)
    lines = f.readlines()
    # lines.reverse()
except FileNotFoundError as err:
    print(f"Are you silly?\n{err}")
    exit(1)
else:
    for line in lines:
        print(line)

    print(f"Amount of lines in the file: {len(lines)}")
