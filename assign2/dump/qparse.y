%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>

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

%define parse.error verbose

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
singleselect:                   TOK_LBRACKET TOK_SINGLESELECT marks_attr TOK_RBRACKET options TOK_LBRACKET check_for_close ;
                                | options_ TOK_LBRACKET TOK_FSLASH TOK_SINGLESELECT TOK_RBRACKET { /* error detection - no opening tag */ }
                                | TOK_LBRACKET TOK_FSLASH TOK_SINGLESELECT TOK_RBRACKET { /* error detection - no opening tag */ };
multiselect:                    TOK_LBRACKET TOK_MULTISELECT marks_attr TOK_RBRACKET options TOK_LBRACKET check_for_close
                                | options_ TOK_LBRACKET TOK_FSLASH TOK_MULTISELECT TOK_RBRACKET { /* error detection - no opening tag */ }
                                | TOK_LBRACKET TOK_FSLASH TOK_MULTISELECT TOK_RBRACKET { /* error detection - no opening tag */ };
marks_attr:                     TOK_MARKS TOK_EQL TOK_STRING
                                | TOK_MARKS TOK_EQL TOK_RBRACKET { /* double quote error */ } ;
check_for_close:                TOK_FSLASH TOK_SINGLESELECT TOK_RBRACKET
                                | TOK_FSLASH TOK_MULTISELECT TOK_RBRACKET
                                | every_id { /* error detection - no closing tag */ }
                                | TOK_FSLASH check_for_close_;
check_for_close_:               every_id { /* error detection - no closing tag */ }
options_:                       options_ option
                                | option ;
options:                        options option
                                | ;
option:                         correct
                                | choice ;
correct:                        TOK_LBRACKET TOK_CORRECT TOK_RBRACKET TOK_LBRACKET TOK_FSLASH TOK_CORRECT TOK_RBRACKET ;
choice:                         TOK_LBRACKET TOK_CHOICE TOK_RBRACKET TOK_LBRACKET TOK_FSLASH TOK_CHOICE TOK_RBRACKET ;
every_id:                       TOK_CHOICE | TOK_CORRECT | TOK_QUIZ | TOK_SINGLESELECT | TOK_MULTISELECT;
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
