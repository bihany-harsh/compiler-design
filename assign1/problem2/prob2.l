%option caseless
%option yylineno

%{
#include <iostream>
#include <string>

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


%}

LETTERS                 [A-Za-z]
DIGITS                  [0-9]
UNDERSCORE              _
SPECIAL_CHARS           " "|\\|"{"|"}"|","|"."|":"|";"|"!"|\"|"~"|"?"|\'|"`"|"^"|"|"|"$"|"#"|"@"
ALPHANUMERIC            {LETTERS}|{DIGITS}|{UNDERSCORE}
NAMES                   {LETTERS}({ALPHANUMERIC}){,62}
KEYWORDS                allocatable|allocate|assign|associate|asynchronous|backspace|bind|call|case|class|close|common|contains|continue|cycle|codimension|contiguous|critical|data|deallocate|deferred|dimension|do|else|elsewhere|end|endfile|endif|entry|equivalence|exit?|external|enum|enumerator|extends|forall|final|flush|format|function|goto|generic|import|if|implicit|inquire|intrinsic|include|interface|intent|lock|module|nopass|namelist|nullify|open|only|operator|optional|parameter|pause|print|program|pointer|private|pass|protected|procedure|public|read|return|recursive|result|rewind|rewrite|save|stop|subroutine|select|sequence|submodule|target|then|use|value|unlock|volatile|while|write
DIGIT_STRING            {DIGITS}+
KIND_PARAM              {DIGIT_STRING}|{NAMES}
INT_LITERAL             {DIGIT_STRING}(_{KIND_PARAM})?
SIGNIFICAND             ({DIGIT_STRING}.({DIGIT_STRING})?)|.{DIGIT_STRING}
EXPONENT_LETTER         E|D
SIGN                    +|-
SIGNED_INT              ({SIGN})?{DIGIT_STRING}
REAL_LITERAL            ({SIGNIFICAND}({EXPONENT_LETTER}{DIGIT_STRING})?(_{KIND_PARAM})?)|({DIGIT_STRING}{EXPONENT_LETTER}{SIGNED_INT})(_{KIND_PARAM})?
LOGICAL_LITERAL         (".TRUE."(_{KIND_PARAM})?)|(".FALSE."(_{KIND_PARAM})?)
CHAR_LITERAL            \"[^\'\"]*\"|\'[^\'\"]*\'
REL_OPERATOR            ".EQ."|".NE."|".LT."|".LE."|".GT."|".GE."|"=="|"/="|"<"|"<="|">"|">="
INTRINSIC_OPERATOR      "**"|"*"|"/"|{SIGN}|"//"|{REL_OPERATOR}|".NOT."|".AND."|".OR."|".EQV."|".NEQV."
OPERATOR                {INTRINSIC_OPERATOR}|"&&"|"<<"|">>"|"||"
DELIM                   "("|")"|"/"|"["|"]"|"(/"|"/)"
COMMENTS                ^![^\n]*(\n)?
WS                      [ \t\r\f\n]|\r\n
  /* TODO: LABELS specification */

%%




%%


