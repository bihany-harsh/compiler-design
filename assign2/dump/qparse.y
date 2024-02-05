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

%token T_OPEN_TAG_ANG T_CLOSE_TAG_ANG T_TAG_CLOSE
%token T_QUIZ
%token T_STRING
%token T_SINGLESELECT
%token T_MARKS
%token T_EQL
%token T_INTEGER
%token T_QUOTE
%token T_OTHER

%%

quiz:                           t_quiz questions_and_t_quiz_close { printf("quiz tag detected\n"); };
questions_and_t_quiz_close:     optional_questions t_quiz_close { printf("questions and quiz close detected\n"); };
t_quiz:                         T_OPEN_TAG_ANG T_QUIZ T_TAG_CLOSE;
t_quiz_close:                   T_CLOSE_TAG_ANG T_QUIZ T_TAG_CLOSE;
optional_questions:             questions
                                | /* empty */;
questions:                      question questions
                                | question;
question:                       singleselect_qa_pair;
                                /*| multiselect_qa_pair*/
singleselect_qa_pair:           t_singleselect question_text single_correct_answer_options t_singleselect_close;
t_singleselect:                 T_OPEN_TAG_ANG T_SINGLESELECT marks_attr T_TAG_CLOSE;
t_singleselect_close:           T_CLOSE_TAG_ANG T_SINGLESELECT T_TAG_CLOSE;
question_text:                  T_STRING;
marks_attr:                     T_MARKS T_EQL T_QUOTE T_INTEGER T_QUOTE;
single_correct_answer_options:  T_STRING T_QUOTE; /* yet to be defined proper */

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