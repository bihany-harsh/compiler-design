%option caseless
%option yylineno
%option noyywrap
%{
    #include <stdio.h>
    #include "qparse.tab.h"
%}

WS              [ \t\n\r]+
OPEN_TAG        "<"
CLOSE_TAG       ">"
FSLASH          "/"
QUIZ            "quiz"
SINGLESELECT    "singleselect"
MULTISELECT     "multiselect"
MARKS           "marks"
EQL             "="
DQUOTE          \"
DIGIT           [0-9]
INTEGER         {DIGIT}+
CHOICE          "choice"
CORRECT         "correct"
STRING          ">"[^<>]*"<"

%%

{WS}                        
{OPEN_TAG}                  { return TOK_OPEN; }
{CLOSE_TAG}                 { return TOK_CLOSE; }
{QUIZ}                      { return TOK_QUIZ; }
{FSLASH}                    { return TOK_FSLASH; }
{SINGLESELECT}              { return TOK_SINGLESELECT; }
{MULTISELECT}               { return TOK_MULTISELECT; }
{MARKS}                     { return TOK_MARKS; }
{EQL}                       { return TOK_EQL; }
{DQUOTE}                    { return TOK_DQUOTE; }
{INTEGER}                   { return TOK_INTEGER; }
{CHOICE}                    { return TOK_CHOICE; }
{CORRECT}                   { return TOK_CORRECT; }
{STRING}                    { return TOK_STRING; }

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
