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
  string TOK_OPERATOR = "OPERATOR";
  string TOK_ID = "IDENTIFIER";
  string TOK_STRING = "STRING";
  string TOK_DELIM = "DELIMITER";
  string TOK_INT = "INTEGER";
  string TOK_FLOAT = "FLOATING_POINT";
  string TOK_HEX = "HEXADECIMAL";
  

  char* lower_string(const char* str) {
    if (str == NULL) {
      return NULL;
    }

    char* p = new char[strlen(str) + 1];
    for (size_t i = 0; i < strlen(str); ++i) {
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

KEYWORD         array|begin|boolean|comment|continue|do|double|else|end|false|for|if|integer|label|list|long|own|procedure|step|switch|then|true|until|value|while
OPERATOR        and|or|leq|lt|geq|gt|not|eql|neq|":="|"+"|"-"|"*"|"/"|"%"|"^"|"|"|"&"|"<<"|">>"
WS              [ \t\r\f\n]|\r\n
DELIM           ";"|":"|","|\'|\"|"["|"]"|"{"|"}"|"("|")"
COMMENT         \{[^\}]*\}
DIGIT           [0-9]
HEXDIGIT        [0-9A-Fa-f]
LETTER          [a-zA-Z]
WHOLE           0|([1-9][0-9]*)
FLOAT           {WHOLE}"."{DIGIT}{1,6}
HEX             0(x|X)(0|([1-9A-Fa-f][0-9A-Fa-f]*))
STRING          \"[^\'\"]*\"|\'[^\'\"]*\'
ID              (?-i:{LETTER}({LETTER}|{DIGIT})*)

%%

  /* ERROR CASES */
  /* A special case of 00..0x... */
0{1,}{HEXDIGIT}+(x|X){HEXDIGIT}*            { snprintf(error_string, sizeof(error_string), "line no.: %d \t Hexadecimal numbers preceeded by 0x.", yylineno); print_error(); }
  /* Hexadecimal decimal */
0(x|X){HEXDIGIT}*"."{HEXDIGIT}*             { snprintf(error_string, sizeof(error_string), "line no.: %d \t Hexadecimal decimal not allowed.", yylineno); print_error(); }
  /* Leading zeroes */
(0(x|X)0{1,}{HEXDIGIT}+)|(0{1,}{DIGIT}+)    { snprintf(error_string, sizeof(error_string), "line no.: %d \t Leading zeroes not allowed.", yylineno); print_error(); }
  /* Six decimal digits */
{WHOLE}"."{DIGIT}{7,}                       { snprintf(error_string, sizeof(error_string), "line no.: %d \t No more than 6 decimal digits allowed.", yylineno); print_error(); }
  /* Invalid float without the whole number part */
"."{DIGIT}+                                 { snprintf(error_string, sizeof(error_string), "line no.: %d \t Did you mean 0%s.", yylineno, yytext); print_error(); }
   /* Invalid strings */
(\"[^\'\"]*\'[^\'\"]*\")|(\'[^\'\"]*\"[^\'\"]*\')   { snprintf(error_string, sizeof(error_string), "line no.: %d \t Errorneous string `%s`.", yylineno, yytext); print_error(); }
\"[^\"]*|\'[^']*                            { snprintf(error_string, sizeof(error_string), "line no.: %d \t Errorneous string `%s`.", yylineno, yytext); print_error(); }


{COMMENT}
{WS}
{KEYWORD}                                   { INSTALL_DATA(TOK_KEYWORD, true); }
{OPERATOR}                                  { INSTALL_DATA(TOK_OPERATOR, true); }
{STRING}                                    { INSTALL_DATA(TOK_STRING, false); }
{DELIM}                                     { INSTALL_DATA(TOK_DELIM, false); }
{FLOAT}                                     { INSTALL_DATA(TOK_FLOAT, false); }
{WHOLE}                                     { INSTALL_DATA(TOK_INT, false); }
{HEX}                                       { INSTALL_DATA(TOK_HEX, false); }
{ID}                                        { INSTALL_DATA(TOK_ID, false); }

  /* SOME ERROR CASES */

  /* Invalid Identifier */
({DIGIT}+){ID}                              { snprintf(error_string, sizeof(error_string), "line no.: %d \t An identifier name starts with a letter.", yylineno); print_error(); }
  /* Assignment operator */
"="                                         { snprintf(error_string, sizeof(error_string), "line no.: %d \t Did you mean EQL or :=?", yylineno); print_error(); } 
.                                           { snprintf(error_string, sizeof(error_string), "line no.: %d \t Unrecognized character %s.", yylineno, yytext); print_error(); }

%%
int main (int argc, char **argv) {
    for (int i = 1; i < argc; ++i) {
        if (std::string(argv[i]) == "--no-error-print") {
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
