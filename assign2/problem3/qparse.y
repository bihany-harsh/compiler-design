%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdbool.h>
  #include <unistd.h>

  extern FILE *yyin;

  extern int yylineno;

  static int MM = 8;

  int N_ques = 0;
  int N_singleselect = 0;
  int N_multiselect = 0;
  int N_choices = 0;
  int N_correct = 0;
  int N_marks = 0;
  int N_quess[8] = {0};

  int tags_correct = 0;
  int tags_choice = 0;

  char error_string[256];

  bool error_detected = false;

  void print_info(void) {
    printf("Number of questions: %d\n", N_ques);
    printf("Number of singleselect questions: %d\n", N_singleselect);
    printf("Number of multiselect questions: %d\n", N_multiselect);
    printf("Number of answer choices: %d\n", N_choices);
    printf("Number of correct answers: %d\n", N_correct);
    printf("Total marks: %d\n", N_marks);
    for(int i = 0; i < MM; i++) {
      printf("Number of %d mark questions: %d\n", i+1, N_quess[i]);
    }
    return;
  }

  int yylex(void);
  void yyerror (char const *s) {
    error_detected = true;
    print_info();
    printf("\n\n");
    fprintf (stderr, "%s\n", s);
    exit(1);
  }
%}

%union {
  int NUM;
  char* STR;
}

%token TOK_OPEN TOK_CLOSE TOK_FSLASH
%token TOK_QUIZ
%token TOK_SINGLESELECT
%token TOK_MULTISELECT
%token TOK_MARKS
%token TOK_EQL
%token TOK_DQUOTE
%token <NUM> TOK_INTEGER
%token TOK_CHOICE
%token TOK_CORRECT
%token TOK_STRING

%%

quiz:                   TOK_OPEN TOK_QUIZ body TOK_FSLASH TOK_QUIZ TOK_CLOSE;
body:                   TOK_STRING questions;
questions:              singleselect_ques questions
                        | multiselect_ques questions
                        | ;
singleselect_ques:      TOK_SINGLESELECT TOK_MARKS TOK_EQL TOK_DQUOTE TOK_INTEGER TOK_DQUOTE TOK_STRING ques_options TOK_FSLASH TOK_SINGLESELECT TOK_STRING {
  if (tags_correct != 1 || tags_choice < 3 || tags_choice > 4) {
    snprintf(error_string, sizeof(error_string), "line no: %d \t Error in multi select questions: in terms of number of choice and correct tags.", yylineno);
    yyerror(error_string);
  } else {
    if ($5 > MM || $5 < 1) {
      snprintf(error_string, sizeof(error_string), "line no: %d \t Error in multi select question: marks between 1 and 8", yylineno);
      yyerror(error_string);
    } else {
      N_marks += $5;
      N_quess[$5 - 1]++;
      N_ques++;
      N_singleselect++;
      N_correct += tags_correct;
      N_choices += tags_choice;
      tags_choice = 0;
      tags_correct = 0;
    }
  }
};
multiselect_ques:       TOK_MULTISELECT TOK_MARKS TOK_EQL TOK_DQUOTE TOK_INTEGER TOK_DQUOTE TOK_STRING ques_options TOK_FSLASH TOK_MULTISELECT TOK_STRING {
  if (tags_correct < 1 || tags_correct > tags_choice || tags_choice < 3 || tags_choice > 4) {
    snprintf(error_string, sizeof(error_string), "line no: %d \t Error in multi select questions: in terms of number of choice and correct tags.", yylineno);
    yyerror(error_string);
  } else {
    if ($5 > MM || $5 < 1) {
      snprintf(error_string, sizeof(error_string), "line no: %d \t Error in multi select question: marks between 1 and 8", yylineno);
      yyerror(error_string);
    } else {
      N_marks += $5;
      N_quess[$5 - 1]++;
      N_ques++;
      N_multiselect++;
      N_correct += tags_correct;
      N_choices += tags_choice;
      tags_choice = 0;
      tags_correct = 0;
    }
  }
};
ques_options:           option_tags;
option_tags:            option_tag option_tags
                        | option_tag;
option_tag:             choice { tags_choice++; }
                        | correct { tags_correct++ };
choice:                 TOK_CHOICE TOK_STRING TOK_FSLASH TOK_CHOICE TOK_STRING;
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

  if (!error_detected) {
    print_info();
  }

  return 0;
}