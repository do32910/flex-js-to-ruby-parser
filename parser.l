%{
    #include <cstdio>
  #include "parser.tab.h"
  extern "C" int yylex();  
%}
%%
[ \t\n; ]                    ;
console\.log                 { return PRINTCOMMAND; }
var                          { return VARIABLEDECLARATION; }
let                          { return LOCALVARIABLEDECLARATION; }
function                     { return FUNCTIONKEY; }
return                       { return RETURN; }
switch                       { return SWITCH; }
case                         { return CASE; }
break                        { return BREAK; }
\{                           { return CURBRACKETOPEN; }
\}                           { return CURBRACKETCLOSE; }
\(                           { return BRACKETOPEN; }
\)                           { return BRACKETCLOSE; }
\"                           { return QUOTATIONMARK; }
\:                           { return COLON; }
[\*\/\+\-]                   { return yytext[0]; }
\"([a-zA-Z0-9\ ]+)\"         {  yylval.sval = strdup(yytext); return STRING; }
[_a-zA-Z]([a-zA-Z_$0-9]*)    {yylval.sval = strdup(yytext);  return VARIABLENAME; }
\[                           { return SQBRACKETOPEN; }
\]                           { return SQBRACKETCLOSE; }
\,                           { return COMMA; }
=                            { return EQUALS; }
[0-9]+\.[0-9]+               { yylval.fval = atof(yytext); return FLOAT; }
[0-9]+                       { yylval.ival = atoi(yytext); return INT; }
%%