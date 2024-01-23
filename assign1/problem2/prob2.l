%option caseless
%option yylineno

%{
#include <iostream>
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <string>
#include <unordered_map>
#include <vector>
#include <cctype>
#include <cstring>
#include <set>

using namespace std;

string TOK_KEYWORD = "KEYWORD";
string TOK_NAME = "NAME";
string TOK_INT_LITERAL = "INT_LITERAL";
string TOK_REAL_LITERAL = "REAL_LITERAL";
string TOK_LOGICAL_LITERAL = "LOGICAL_LITERAL";
string TOK_CHAR_LITERAL = "CHAR_LITERAL";
string TOK_OPERATOR = "OPERATOR";
string TOK_LABEL = "LABEL";
string TOK_SPECIAL_CHAR = "SPECIAL_CHAR";
string TOK_DELIM = "DELIMITER";

char* lower_string(const char* str) {
  if (str == NULL) 
    return NULL;
  char* p = new char[strlen(str) + 1];
  for (size_t i = 0; i < strlen(str); i++) {
    p[i] = (char)tolower(str[i]);
  }
  p[strlen(str)] = '\0';
  return p;
}

struct LEXEME_INFO {
  string TOK_TYPE;
  int COUNT;
  set<string> FORMS;
};

unordered_map<string, LEXEME_INFO> LEXEME_INFO_MAP;

void INSTALL_DATA(string TOK, bool case_insensitive) {
  if (case_insensitive) {
    char* l_yytext = lower_string(yytext);
    string l_yytext_str(l_yytext);
    delete[] l_yytext;
    if (LEXEME_INFO_MAP.find(l_yytext_str) == LEXEME_INFO_MAP.end()) {
      LEXEME_INFO info;
      info.TOK_TYPE = TOK;
      info.COUNT = 1;
      info.FORMS.insert(yytext);
      LEXEME_INFO_MAP[l_yytext_str] = info;
    } else {
      LEXEME_INFO_MAP[l_yytext_str].COUNT++;
      LEXEME_INFO_MAP[l_yytext_str].FORMS.insert(yytext);
    }
  } else {
    if (LEXEME_INFO_MAP.find(yytext) == LEXEME_INFO_MAP.end()) {
      LEXEME_INFO info;
      info.TOK_TYPE = TOK;
      info.COUNT = 1;
      info.FORMS.insert(yytext);
      LEXEME_INFO_MAP[yytext] = info;
    } else {
      LEXEME_INFO_MAP[yytext].COUNT++;
      LEXEME_INFO_MAP[yytext].FORMS.insert(yytext);
    }
  }
}

char error_string[256];
bool error_to_print = true;

void print_error() {
  if (error_to_print) {
    cout << error_string << endl;
  }
}

%}

LETTERS                 [A-Za-z]
DIGITS                  [0-9]
UNDERSCORE              _
SPECIAL_CHARS           " "|\\|"{"|"}"|","|"."|":"|";"|"!"|\"|"~"|"?"|\'|"`"|"^"|"|"|"$"|"#"|"@"
ALPHANUMERIC            {LETTERS}|{DIGITS}|{UNDERSCORE}
NAMES                   {LETTERS}({ALPHANUMERIC}){0,62}
KEYWORDS                (?i:allocatable|allocate|assign|associate|asynchronous|backspace|bind|call|case|class|close|common|contains|continue|cycle|codimension|contiguous|critical|data|deallocate|deferred|dimension|do|else|elsewhere|end|endfile|endif|entry|equivalence|exit?|external|enum|enumerator|extends|forall|final|flush|format|function|goto|generic|import|if|implicit|inquire|intrinsic|include|interface|intent|lock|module|nopass|namelist|nullify|open|only|operator|optional|parameter|pause|print|program|pointer|private|pass|protected|procedure|public|read|return|recursive|result|rewind|rewrite|save|stop|subroutine|select|sequence|submodule|target|then|use|value|unlock|volatile|while|write)
DIGIT_STRING            {DIGITS}+
KIND_PARAM              {DIGIT_STRING}|{NAMES}
INT_LITERAL             {DIGIT_STRING}(_{KIND_PARAM})?
SIGNIFICAND             ({DIGIT_STRING}"."{DIGIT_STRING}?)|"."{DIGIT_STRING}
EXPONENT_LETTER         "E"|"D"
SIGN                    "+"|"-"
SIGNED_INT              {SIGN}?{DIGIT_STRING}
REAL_LITERAL            ({SIGNIFICAND}({EXPONENT_LETTER}{DIGIT_STRING})?(_{KIND_PARAM})?)|({DIGIT_STRING}{EXPONENT_LETTER}{SIGNED_INT})(_{KIND_PARAM})?
LOGICAL_LITERAL         (".TRUE."(_{KIND_PARAM})?)|(".FALSE."(_{KIND_PARAM})?)
CHAR_LITERAL            \"[^\'\"]*\"|\'[^\'\"]*\'
REL_OPERATOR            ".EQ."|".NE."|".LT."|".LE."|".GT."|".GE."|"=="|"/="|"<"|"<="|">"|">="
INTRINSIC_OPERATOR      "**"|"*"|"/"|{SIGN}|"//"|{REL_OPERATOR}|".NOT."|".AND."|".OR."|".EQV."|".NEQV."
OPERATOR                "="|{INTRINSIC_OPERATOR}|"&&"|"<<"|">>"|"||"
DELIM                   "("|")"|"/"|"["|"]"|"(/"|"/)"
COMMENTS                "!"[^\n]*(\n)?
WS                      [ \t\r\f\n]|\r\n

%%

{COMMENTS}|{WS}
{KEYWORDS}                                { INSTALL_DATA(TOK_KEYWORD, true);  }
{NAMES}                                   { INSTALL_DATA(TOK_NAME, true); }
{INT_LITERAL}                             { INSTALL_DATA(TOK_INT_LITERAL, true); }
{REAL_LITERAL}                            { INSTALL_DATA(TOK_REAL_LITERAL, true); }
{LOGICAL_LITERAL}                         { INSTALL_DATA(TOK_LOGICAL_LITERAL, true); }
{CHAR_LITERAL}                            { INSTALL_DATA(TOK_CHAR_LITERAL, true); }
{OPERATOR}                                { INSTALL_DATA(TOK_OPERATOR, true); }
{DELIM}                                   { INSTALL_DATA(TOK_DELIM, true); }
{SPECIAL_CHARS}                           { INSTALL_DATA(TOK_SPECIAL_CHAR, true); }

  /* ERROR CASES */
  
  /* Names with length more than 63 */
{LETTERS}{ALPHANUMERIC}{63,}              { snprintf(error_string, sizeof(error_string), "line no.: %d \t Names are limited to be of length less than equal to 63", yylineno); print_error(); }
  /* Invalid Identifier */
(({DIGITS}|{UNDERSCORE})+){NAMES}         { snprintf(error_string, sizeof(error_string), "line no.: %d \t An identifier name starts with a letter.", yylineno); print_error(); }
   /* Invalid strings */
(\"([^\'\"]*\'[^\'\"]*)+\")               { snprintf(error_string, sizeof(error_string), "line no.: %d \t Errorneous string `%s`.", yylineno, yytext); print_error(); }
  /* Invalid strings - without closing apostophe */
\"[^\"]*                                  { snprintf(error_string, sizeof(error_string), "line no.: %d \t Errorneous string `%s`.", yylineno, yytext); print_error(); }
 



%%

int main (int argc, char **argv) {
  for (int i = 1; i < argc; ++i) {
    if (string(argv[i]) == "--no-error-print") {
      error_to_print = false;
      for (int j = i; j < argc - 1; ++j) {
        argv[j] = argv[j + 1];
      }
      --argc;
      break;
    }
  }

  if (argc > 1) {
    yyin = fopen(argv[1], "r");
  } else {
    yyin = stdin;
  }

  if (error_to_print) {
    cout << "ERROR" << endl;
  }

  yylex();

  if (error_to_print) {
    cout << endl << endl;
  }
  
  vector<pair<string, string>> P_LEXEMES;
  for (auto &[normalized, info]: LEXEME_INFO_MAP) {
      for (const string &form: info.FORMS) {
        P_LEXEMES.push_back({form, normalized});
      }
    }
    sort(P_LEXEMES.begin(), P_LEXEMES.end());
    cout << "TOKEN\t\tCOUNT\t\tLEXEME" << endl;
    cout << "________________________________________" << endl;
    for (auto &[form, normalized]: P_LEXEMES) {
      if (LEXEME_INFO_MAP[normalized].TOK_TYPE.length() <= 7) {
        cout << LEXEME_INFO_MAP[normalized].TOK_TYPE << "\t\t" << LEXEME_INFO_MAP[normalized].COUNT << "\t\t" << form << endl;
      } else {
        cout << LEXEME_INFO_MAP[normalized].TOK_TYPE << "\t" << LEXEME_INFO_MAP[normalized].COUNT << "\t\t" << form << endl;
      }
    }
    return 0;


}
