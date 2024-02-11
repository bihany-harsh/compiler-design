%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <unistd.h>
  #include <ctype.h>
  #include <stdbool.h>
  #include <string.h>

  #define MM 8

  extern FILE *yyin;
  extern int yylineno;
  extern char* yytext;
  
  int N_ques = 0;
  int N_singleselect = 0;
  int N_multiselect = 0;
  int N_choices = 0;
  int N_correct = 0;
  int N_marks = 0;
  int N_quess[8] = {0};

  int n_correct = 0;
  int n_choice = 0;

  char error_string[512];

  int yylineno_ = 0;

  bool error_detected = false;

  int _marks = 0;
  char* _tag = NULL;

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

  int is_ws(char c) {
    return c == ' ' || c == '\t' || c == '\n' || c == '\r';
  }

  int extract_number(char* str) {
    char* p = str + 1;
    while(*p && is_ws(*p)) p++;
    int val, ch_read = 0;
    if (sscanf(p, "%d%n", &val, &ch_read) == 1) {
      p += ch_read;
      while (*p && *p != '\"') {
        if (!is_ws(*p)) {
          return 0;
        }
        p++;
      }
      _marks = val;
      return 1;
    }
    return 0;
  }

  /* 0-> singleselect
    1 -> multiselect */
  void handle_questions(int qtype) {
    if (!qtype) {
      if ((n_correct != 1 || n_choice < 3 || n_choice > 4)) {
        snprintf(error_string, sizeof(error_string), "line no.: %d \t Error in single select question: in terms of number of choice and correct tags.", yylineno);
        yyerror(error_string);
      }
    } else {
      if (n_correct < 1 || n_correct > n_choice || n_choice < 3 || n_choice > 4) {
        snprintf(error_string, sizeof(error_string), "line no.: %d \t Error in multiple select question: in terms of number of choice and correct tags.", yylineno);
        yyerror(error_string);
      }
    }
    if (_marks > MM || _marks < 1) {
      snprintf(error_string, sizeof(error_string), "line no.: %d \t Marks should be in the range 1-8.", yylineno_);
      yyerror(error_string);
    }
    N_marks += _marks;
    N_quess[_marks - 1]++;
    N_ques++;
    if (!qtype) {
      N_singleselect++;
    } else {
      N_multiselect++;
    }
    N_correct += n_correct;
    N_choices += n_choice;
    n_choice = 0;
    n_correct = 0;
    _marks = 0;
  }
%}


%union {
  int NUM;
  char* STR;
}

%token TOK_LBRACKET TOK_RBRACKET TOK_FSLASH
%token TOK_QUIZ 
%token <STR> TOK_SINGLESELECT 
%token <STR> TOK_MULTISELECT 
%token TOK_CHOICE TOK_CORRECT
%token TOK_MARKS TOK_EQL
%token <STR> TOK_STRING

%%

quiz:                           TOK_LBRACKET TOK_QUIZ TOK_RBRACKET questions TOK_LBRACKET TOK_FSLASH TOK_QUIZ TOK_RBRACKET ;
questions:                      questions singleselect
                                | questions multiselect
                                | ;
singleselect:                   TOK_LBRACKET TOK_SINGLESELECT { _tag = malloc(sizeof(strlen($2) + 1)); strcpy(_tag, $2); } marks_attr { yylineno_ = yylineno; } TOK_RBRACKET options TOK_LBRACKET check_for_close
                                | options_ TOK_LBRACKET TOK_FSLASH TOK_SINGLESELECT { _tag = malloc(sizeof(strlen($4) + 1)); strcpy(_tag, $4); } TOK_RBRACKET { /* error detection - no opening tag */ 
                                  snprintf(error_string, sizeof(error_string), "line no.: %d \t No opening tag (%s).", yylineno_, _tag);
                                  free(_tag);
                                  _tag = NULL;
                                  yyerror(error_string);
                                }
                                | TOK_LBRACKET TOK_FSLASH TOK_SINGLESELECT { _tag = malloc(sizeof(strlen($3) + 1)); strcpy(_tag, $3); } TOK_RBRACKET { /* error detection - no opening tag */ 
                                  snprintf(error_string, sizeof(error_string), "line no.: %d \t No opening tag (%s).", yylineno, _tag);
                                  free(_tag);
                                  _tag = NULL;
                                  yyerror(error_string);
                                };
multiselect:                    TOK_LBRACKET TOK_MULTISELECT { _tag = malloc(sizeof(strlen($2) + 1)); strcpy(_tag, $2); } marks_attr { yylineno_ = yylineno; } TOK_RBRACKET options TOK_LBRACKET check_for_close
                                | options_ TOK_LBRACKET TOK_FSLASH TOK_MULTISELECT { _tag = malloc(sizeof(strlen($4) + 1)); strcpy(_tag, $4); } TOK_RBRACKET { /* error detection - no opening tag */ 
                                  snprintf(error_string, sizeof(error_string), "line no.: %d \t No opening tag (%s).", yylineno_, _tag);
                                  free(_tag);
                                  _tag = NULL;
                                  yyerror(error_string);
                                }
                                | TOK_LBRACKET TOK_FSLASH TOK_MULTISELECT { _tag = malloc(sizeof(strlen($3) + 1)); strcpy(_tag, $3); } TOK_RBRACKET { /* error detection - no opening tag */ 
                                  snprintf(error_string, sizeof(error_string), "line no.: %d \t No opening tag (%s).", yylineno, _tag);
                                  free(_tag);
                                  _tag = NULL;
                                  yyerror(error_string);
                                };
marks_attr:                     TOK_MARKS TOK_EQL TOK_STRING {
                                  if (!extract_number($3)) {
                                    snprintf(error_string, sizeof(error_string), "line no.: %d \t Marks should be natural numbers.", yylineno);
                                    yyerror(error_string);
                                  }
                                }
                                | TOK_MARKS TOK_EQL TOK_RBRACKET { 
                                  snprintf(error_string, sizeof(error_string), "line no.: %d \t Enclose the marks in double quotes.", yylineno);
                                  yyerror(error_string);
                                  /* double quote error */ } ;
check_for_close:                TOK_FSLASH TOK_SINGLESELECT TOK_RBRACKET {
                                  handle_questions(0);
                                }
                                | TOK_FSLASH TOK_MULTISELECT TOK_RBRACKET {
                                    handle_questions(1);
                                  }
                                | every_id { /* error detection - no closing tag */ 
                                  snprintf(error_string, sizeof(error_string), "line no.: %d \t No closing tag (%s).", yylineno, _tag);
                                  free(_tag);
                                  _tag = NULL;
                                  yyerror(error_string);
                                }
                                | TOK_FSLASH check_for_close_;
check_for_close_:               every_id { /* error detection - no closing tag */ 
                                  snprintf(error_string, sizeof(error_string), "line no.: %d \t No closing tag (%s).", yylineno, _tag);
                                  free(_tag);
                                  _tag = NULL;
                                  yyerror(error_string);
                                }
options_:                       options_ option
                                | option { yylineno_ = yylineno; } ;
options:                        options option
                                | ;
option:                         correct { n_correct++; }
                                | choice { n_choice++; } ;
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

  if (!error_detected) {
    print_info();
  }

  return 0;
}
