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
FLOAT           {WHOLE}"."{DIGIT}{1, 6}
HEX             0(x|X)(0|([1-9A-Fa-f][0-9A-Fa-f]*))
STRING          \"[^\'\"]*\"|\'[^\'\"]*\'
ID              (?-i:{LETTER}({LETTER}|{DIGIT})*)

%%

{COMMENT}
{WS}
{KEYWORD}                                     { if(!find_string()) { install_data(TOK_KEYWORD); } }
{OPERATOR}                                    { if(!find_string()) { install_data(TOK_OPERATOR); } }
{DELIM}                                       { if(!find_string()) { install_data(TOK_DELIM); } }
{WHOLE}                                       { if(!find_string()) { install_data(TOK_INT); } }
{HEX}                                         { if(!find_string()) { install_data(TOK_HEX); } }
{FLOAT}                                       { if(!find_string()) { install_data(TOK_FLOAT); } }
{STRING}                                      { if(!find_string()) { install_data(TOK_STRING); } }
{ID}                                          { if(!find_string()) { install_data(TOK_ID); } }

.                                             { printf("line no: %d \t Unrecognized character.\n", yylineno); }

%%

int main (int argc, char **argv) {
    ++argv, --argc;  /* skip over program name */
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
