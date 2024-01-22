#!/bin/bash

flex -o prob2.cpp prob2.l
g++ --std=c++17 -w prob2.cpp -ll

if [ $# -lt 1 ]; then
	echo "Usage: $0 <testcase path> <-y/nil>"
	exit 1
fi

f=$1

if [ "$2" == "-y" ]; then
	./a.out "$f"
else
	./a.out --no-error-print "$f"
fi
