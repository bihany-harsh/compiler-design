%option caseless
%option yylineno
%{
    #include <stdio.h>
    #include "qmark.tab.h"
%}

QUIZ            "quiz"
SINGLESELECT    "singleselect"
CHOICE          "choice"
CORRECT         "correct"
MULTISELECT     "multiselect"
MARKS           "marks"
DIGIT           [0-9]
INTEGER         {DIGIT}+
WS              [ \t\r\f\n]|\r\n
OPEN_TAG_ANG    "<"{WS}*
TAG_CLOSE       {WS}*">"
CLOSE_TAG_ANG   "<"{WS}*"/"{WS}*
EQL             "="
ASSIGN_MARKS    {WS}*{MARKS}{WS}*{EQL}{WS}*\"{WS}*{INTEGER}{WS}*\"
STRING          [^<>\n\s\t\r\f][^<>\n]*

%%

{WS}              
{OPEN_TAG_ANG}                      { return T_OPEN_TAG_ANG; }
{CLOSE_TAG_ANG}                     { return T_CLOSE_TAG_ANG; }
{TAG_CLOSE}                         { return T_TAG_CLOSE; }
{QUIZ}                              { return T_QUIZ; }           
{SINGLESELECT}                      { return T_SINGLESELECT; }
{CHOICE}                            { return T_CHOICE; }
{EQL}                               { return T_EQL; }
{CORRECT}                           { return T_CORRECT; }
{MARKS}                             { return T_MARKS; }
{INTEGER}                           { return T_INTEGER; }
"\""                                { return T_QUOTE; }
{STRING}                            { return T_STRING; }
.                                   { return T_OTHER; }


%%

int main(int argc, const char** argv) {

    if (argc > 1) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }

    yylex();

    return 0;
}
