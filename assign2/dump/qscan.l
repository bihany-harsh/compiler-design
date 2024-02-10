%option caseless
%option yylineno
%option noyywrap
%{
    #include <stdio.h>
    #include "qparse.tab.h"
%}

WS                      [ \t\n\r]+
LBRACKET                "<"
RBRACKET                ">"
FSLASH                  "/"
QUIZ                    "quiz"
SINGLESELECT            "singleselect"
MULTISELECT             "multiselect"
MARKS                   "marks"
EQL                     "="
STRING                  \"[^\"]+\"
CHOICE                  "choice"
CORRECT                 "correct"


%%

{WS}                { /* ignore whitespace */ }
{LBRACKET}          { return TOK_LBRACKET; }
{RBRACKET}          { return TOK_RBRACKET; }
{FSLASH}            { return TOK_FSLASH; }
{QUIZ}              { return TOK_QUIZ; }
{SINGLESELECT}      { return TOK_SINGLESELECT; }
{MULTISELECT}       { return TOK_MULTISELECT; }
{MARKS}             { return TOK_MARKS; }
{EQL}               { return TOK_EQL; }
{STRING}            { return TOK_STRING; }
{CHOICE}            { return TOK_CHOICE; }
{CORRECT}           { return TOK_CORRECT; }
.                   { /* ignore everything else */ }

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
