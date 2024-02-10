%{
    #include <stdio.h>
    #include <stdlib.h>

    extern FILE *yyin;
    extern int yylineno;
    extern char* yytext;

    char error_string[256];

    int yylex(void);
    void yyerror (char const *s) {
      fprintf (stderr, "%s\n", s);
      exit(1);
    }
%}

%token TOK_LBRACKET TOK_RBRACKET TOK_FSLASH
%token TOK_QUIZ TOK_SINGLESELECT TOK_MULTISELECT TOK_CHOICE TOK_CORRECT
%token TOK_MARKS TOK_EQL
%token TOK_STRING

%union {
  int NUM;
  char* STR;
}

%%

quiz:                           TOK_LBRACKET TOK_QUIZ TOK_RBRACKET questions TOK_LBRACKET TOK_FSLASH TOK_QUIZ TOK_RBRACKET ;
questions:                      questions singleselect
                                | questions multiselect
                                | ;
singleselect:                   TOK_LBRACKET TOK_SINGLESELECT TOK_MARKS TOK_EQL TOK_STRING TOK_RBRACKET options TOK_LBRACKET check { printf("the correct case 1\n"); };
                                | options_ TOK_LBRACKET TOK_FSLASH TOK_SINGLESELECT TOK_RBRACKET { printf("error 1A\n"); /* error detection - no opening tag */ }
                                | TOK_LBRACKET TOK_FSLASH TOK_SINGLESELECT TOK_RBRACKET { printf("error 1B\n"); /* error detection - no opening tag */ };
check:                          TOK_FSLASH TOK_SINGLESELECT TOK_RBRACKET
                                | error { printf("error 1C\n"); /* error detection - no closing tag */ };
multiselect:                    TOK_LBRACKET TOK_MULTISELECT TOK_MARKS TOK_EQL TOK_STRING TOK_RBRACKET options TOK_LBRACKET TOK_FSLASH TOK_MULTISELECT TOK_RBRACKET { printf("the correct case 2\n"); }
                                | options_ TOK_LBRACKET TOK_FSLASH TOK_MULTISELECT TOK_RBRACKET { printf("error 2A\n"); /* error detection - no opening tag */ }
                                | TOK_LBRACKET TOK_FSLASH TOK_MULTISELECT TOK_RBRACKET { printf("error 2B\n"); /* error detection - no opening tag */ };
options_:                       options_ option
                                | option ;
options:                        options option
                                | ;
option:                         correct
                                | choice ;
correct:                        TOK_LBRACKET TOK_CORRECT TOK_RBRACKET TOK_LBRACKET TOK_FSLASH TOK_CORRECT TOK_RBRACKET ;
choice:                         TOK_LBRACKET TOK_CHOICE TOK_RBRACKET TOK_LBRACKET TOK_FSLASH TOK_CHOICE TOK_RBRACKET ;

%%

int main(int argc, const char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yyparse();

    return 0;
}
