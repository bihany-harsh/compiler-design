%option caseless
%option yylineno
%{
    #include <iostream>
    #include <algorithm>
    #include <cmath>
    #include <cstdlib>
    #include <string>
    #include <format>
    #include <unordered_map>
    #include <vector>
    using namespace std;

    static int F_LIMIT = 6;

    string TOK_KEYWORD = "KEYWORD";
    string TOK_OPERATOR = "OPERATOR";
    string TOK_ID = "IDENTIFIER";
    string TOK_STRING = "STRING";
    string TOK_DELIM = "DELIMITER";
    string TOK_INT = "INTEGER";
    string TOK_FLOAT = "FLOATING_POINT";
    string TOK_HEX = "HEXADECIMAL";

    vector<string> LEXEMES;
    unordered_map<string, int> LEXEME_COUNT;
    unordered_map<string, string> LEXEME_TOK;
    
    vector<string>::iterator LEXEMES_IT;

    char error_string[256];

    bool error_to_print = true;

    bool find_string() {
      LEXEMES_IT = find(LEXEMES.begin(), LEXEMES.end(), yytext);
      if (LEXEMES_IT == LEXEMES.end())
          return false;
      else
          return true;
    }

    void install_data(string TOK) {
        LEXEMES.push_back(yytext);
        LEXEME_TOK[yytext] = TOK;
        LEXEME_COUNT[yytext]++;
    }

    void execute(string TOK) {
      if (!find_string()) {
        install_data(TOK);
      } else {
        LEXEME_COUNT[yytext]++;
      }
    }

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
0{1,}{HEXDIGIT}+(x|X){HEXDIGIT}*                     { snprintf(error_string, sizeof(error_string), "line no.: %d \t Hexadecimal numbers preceeded by 0x.", yylineno); print_error(); }
0(x|X){HEXDIGIT}*"."{HEXDIGIT}*             { snprintf(error_string, sizeof(error_string), "line no.: %d \t Hexadecimal decimal not allowed.", yylineno); print_error(); }
  /* Leading zeroes */
(0(x|X)0{1,}{HEXDIGIT}+)|(0{1,}{DIGIT}+)    { snprintf(error_string, sizeof(error_string), "line no.: %d \t Leading zeroes not allowed.", yylineno); print_error(); }
  /* Six decimal digits */
{WHOLE}"."{DIGIT}{7,}                       { snprintf(error_string, sizeof(error_string), "line no.: %d \t No more than 6 decimal digits allowed.", yylineno); print_error(); }
  /* Invalid float without the whole number part */
"."{DIGIT}+                                 { snprintf(error_string, sizeof(error_string), "line no.: %d \t Did you mean 0%s.", yylineno, yytext); print_error(); }

  /* TODO Invalid strings to be checked. */
  /* TODO multiline nature of comments. */


{COMMENT}
{WS}
{KEYWORD}                                   { execute(TOK_KEYWORD); }
{OPERATOR}                                  { execute(TOK_OPERATOR); }
{STRING}                                    { execute(TOK_STRING); }
{DELIM}                                     { execute(TOK_DELIM); }
{FLOAT}                                     { execute(TOK_FLOAT); }
{WHOLE}                                     { execute(TOK_INT); }
{HEX}                                       { execute(TOK_HEX); }
{ID}                                        { execute(TOK_ID); }

  /* SOME ERROR CASES */

  /* Invalid Identifier */
({DIGIT}+){ID}                              { snprintf(error_string, sizeof(error_string), "line no.: %d \t An identifier name starts with a letter.", yylineno); print_error(); }
  /* Assignment operator */
"="                                         { snprintf(error_string, sizeof(error_string), "line no.: %d \t Did you mean EQL or :=?", yylineno); print_error(); } 
.                                           { snprintf(error_string, sizeof(error_string), "line no.: %d \t Unrecognized character %s.", yylineno, yytext); }

%%
int main (int argc, char **argv) {
    ++argv, --argc;
    if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
    else
        yyin = stdin;

    yylex();

    sort(LEXEMES.begin(), LEXEMES.end());
    
    for (string LEXEME: LEXEMES) {
        cout << LEXEME << "\t" << LEXEME_TOK[LEXEME] << "\t" << LEXEME_COUNT[LEXEME] << endl;
    }
    return 0;
}
