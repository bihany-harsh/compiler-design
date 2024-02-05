%{
  #include <stdio.h>
  #include <stdlib.h>
  #define MM 8

  long N_QUES = 0;
  long N_SINGLESELECT_QUES = 0;
  long N_MULTISELECT_QUES = 0;
  long N_CHOICES = 0;
  long N_CORRECT = 0;
  long N_MARKS = 0;
  
  long MARKS_ARRAY[MM] = {0};
  extern FILE *yyin;
%}

%token T_OPEN_TAG_ANG T_CLOSE_TAG_ANG T_TAG_CLOSE
%token T_QUIZ
%token T_SINGLESELECT
%token T_MULTISELECT
%token T_MARKS
%token T_CHOICE
%token T_CORRECT
%token T_STRING
%token T_INTEGER
%token T_EQL
%token T_QUOTE
%token T_OTHER

%%

quiz:                     t_quiz questions t_quiz_close { printf("quiz started\n"); };
t_quiz:                   T_OPEN_TAG_ANG T_QUIZ T_TAG_CLOSE;
t_quiz_close:             T_CLOSE_TAG_ANG T_QUIZ T_TAG_CLOSE;
questions:                question questions
                          | question { N_QUES++; printf("question: %d\n", N_QUES); };
question:                 singleselect_qa_pair
                          | multiselect_qa_pair;
singleselect_qa_pair:     t_singleselect question_text answer_options t_singleselect_close;
t_singleselect:           T_OPEN_TAG_ANG T_SINGLESELECT marks_attr T_TAG_CLOSE;
t_singleselect_close:     T_CLOSE_TAG_ANG T_SINGLESELECT T_TAG_CLOSE;
multiselect_qa_pair:      t_multiselect question_text answer_options t_multiselect_close;
t_multiselect:            T_OPEN_TAG_ANG T_MULTISELECT marks_attr T_TAG_CLOSE;
t_multiselect_close:      T_CLOSE_TAG_ANG T_MULTISELECT T_TAG_CLOSE;
marks_attr:               T_MARKS T_EQL T_QUOTE T_INTEGER T_QUOTE;
answer_options:           three_options
                          | four_options;
three_options:            correct two_choices
                          | choice correct choice
                          | two_choices correct;
four_options:             correct three_choices
                          | choice correct two_choices
                          | two_choices correct choice
                          | three_choices correct;
two_choices:              choice choice;
three_choices:            choice choice choice;
choice:                   t_choice answer_text t_choice_close;
t_choice:                 T_OPEN_TAG_ANG T_CHOICE T_TAG_CLOSE;
t_choice_close:           T_CLOSE_TAG_ANG T_CHOICE T_TAG_CLOSE;
correct:                  t_correct answer_text t_correct_close;
t_correct:                T_OPEN_TAG_ANG T_CORRECT T_TAG_CLOSE;
t_correct_close:          T_CLOSE_TAG_ANG T_CORRECT T_TAG_CLOSE;
question_text:            T_STRING;
answer_text:              T_STRING;

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