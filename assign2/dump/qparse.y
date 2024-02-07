%{
  #include <stdio.h>
  #include <stdlib.h>
  #define MM 8
  extern FILE *yyin;

  int yylex(void);
  void yyerror (char const *s) {
    fprintf (stderr, "%s\n", s);
  }
%}

%token TOK_OPEN TOK_CLOSE TOK_FSLASH
%token TOK_QUIZ
%token TOK_SINGLESELECT
%token TOK_MULTISELECT
%token TOK_MARKS
%token TOK_EQL
%token TOK_DQUOTE
%token TOK_INTEGER
%token TOK_CHOICE
%token TOK_CORRECT
%token TOK_STRING

%%

quiz:                   TOK_OPEN TOK_QUIZ body TOK_FSLASH TOK_QUIZ TOK_CLOSE;
body:                   TOK_STRING questions;
questions:              singleselect_ques questions
                        | multiselect_ques questions
                        | ;
singleselect_ques:      TOK_SINGLESELECT TOK_MARKS TOK_EQL TOK_DQUOTE TOK_INTEGER TOK_DQUOTE TOK_STRING single_ques_options TOK_FSLASH TOK_SINGLESELECT TOK_STRING;
multiselect_ques:       TOK_MULTISELECT TOK_MARKS TOK_EQL TOK_DQUOTE TOK_INTEGER TOK_DQUOTE TOK_STRING multi_ques_options TOK_FSLASH TOK_MULTISELECT TOK_STRING;
single_ques_options:    three_or_four_choices correct;
multi_ques_options:     three_or_four_choices correct_options;
three_or_four_choices:  choice choice choice
                        | choice choice choice choice;
choice:                 TOK_CHOICE TOK_STRING TOK_FSLASH TOK_CHOICE TOK_STRING;
correct_options:        correct correct correct
                        | correct correct correct correct;
correct:                TOK_CORRECT TOK_STRING TOK_FSLASH TOK_CORRECT TOK_STRING;

%%

int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
    return 1;
  }

  FILE *file = fopen(argv[1], "r");
  if (!file) {
    perror("Opening file failed");
    return 1;
  }

  yyin = file;
  yyparse();
  fclose(file);

  return 0;
}