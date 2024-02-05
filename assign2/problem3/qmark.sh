#!/bin/bash

flex -o qscan.c qmark.l  
bison -d qmark.y

gcc -o qparse.out qscan.c qmark.tab.c -lfl
    
./qparse.out ./test.html