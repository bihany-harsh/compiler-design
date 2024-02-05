%option caseless
%option yylineno
%option noyywrap
%{
    #include <stdio.h>
    #include "qparse.tab.h"
%}

QUIZ            "quiz"
SINGLESELECT    "singleselect"
MARKS           "marks"
WS              [ \t\n]+
OPEN_TAG_ANG    "<"{WS}*
TAG_CLOSE       {WS}*">"
CLOSE_TAG_ANG   "<"{WS}*"/"{WS}*
STRING          [^\s\n<>][^\n<>]*
EQL             "="
DIGIT           [0-9]
INTEGER         {DIGIT}+


%%

{WS}                                { /*Ignore whitespace*/ }
{OPEN_TAG_ANG}                      { return T_OPEN_TAG_ANG; }
{CLOSE_TAG_ANG}                     { return T_CLOSE_TAG_ANG; }
{TAG_CLOSE}                         { return T_TAG_CLOSE; }
{QUIZ}                              { return T_QUIZ; }
{SINGLESELECT}                      { return T_SINGLESELECT; }
{EQL}                               { return T_EQL; }
{MARKS}                             { return T_MARKS; }
"\""                                { return T_QUOTE; }
{INTEGER}                           { return T_INTEGER; }
{STRING}                            { return T_STRING; }
.                                   { return T_OTHER; }


%%

// int main(int argc, const char** argv) {

//     if (argc > 1) {
//         yyin = fopen(argv[1], "r");
//     } else {
//         yyin = stdin;
//     }

//     yylex();

//     return 0;
// }
