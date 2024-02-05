#!/bin/bash

flex -o qscan.c qscan.l  
bison -d qparse.y

gcc qscan.c qparse.tab.c -lfl
    
./a.out ./test.html