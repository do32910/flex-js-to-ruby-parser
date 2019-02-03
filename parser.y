%{
  #include <cstdio>
  #include <iostream>
  using namespace std;

  extern "C" int yylex();
  extern int yyparse();
  extern FILE *yyin;
 
  void yyerror(const char *s);
%}

%union {
  int ival;
  float fval;
  char cval;
  char *sval;
}

// define the constant-string tokens:
%token TYPE
%token PRINTCOMMAND
%token END
%token QUOTATIONMARK
%token BRACKETCLOSE
%token BRACKETOPEN
%token SQBRACKETCLOSE
%token SQBRACKETOPEN
%token CURBRACKETOPEN
%token CURBRACKETCLOSE
%token COLON
%token FUNCTIONKEY
%token RETURN
%token EQUALS
%token COMMA
%token VARIABLEDECLARATION
%token LOCALVARIABLEDECLARATION
%token SWITCH
%token CASE
%token BREAK
%token <sval> SINGLELINECOMMENT

%token <sval> VARIABLENAME

// define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING


%%

parser: elements parser | elements;

elements: print | varDeclaration | functionDeclaration | simpleOperation | switchOperation
; 

print: printSimpleType | printArray;
printSimpleType:
  PRINTCOMMAND BRACKETOPEN { cout << "puts " ; } variable BRACKETCLOSE lineend
;
printArray:
  PRINTCOMMAND BRACKETOPEN { cout << "puts " ; } array BRACKETCLOSE lineend
;

varDeclaration: variableDeclaration | localVariableDeclaration;
variableDeclaration: VARIABLEDECLARATION VARIABLENAME { cout << "$" << $2 ; } lineend 
| VARIABLEDECLARATION VARIABLENAME EQUALS { cout << "$" << $2 << "=" ; } simpleOperation lineend 
;
localVariableDeclaration: LOCALVARIABLEDECLARATION VARIABLENAME { cout << $2 ;} lineend
| LOCALVARIABLEDECLARATION VARIABLENAME EQUALS { cout << $2 << "=" ;} simpleOperation lineend
;

functionDeclaration: FUNCTIONKEY VARIABLENAME { cout << "def " << $2; } BRACKETOPEN { cout << "(" ;} variableNames BRACKETCLOSE { cout << ")" ;} CURBRACKETOPEN functionOperations CURBRACKETCLOSE {cout << "\nend" ;} lineend;
;
functionOperations: {cout << "\n\t"; } varDeclaration 
| RETURN {cout << "\n\t" ;} simpleOperation 
| {cout << "\n\t"; } simpleOperation
| {cout << "\n\t"; } print
| functionOperations functionOperations
;
switchOperation: SWITCH BRACKETOPEN VARIABLENAME BRACKETCLOSE { cout << "case " << $3; } CURBRACKETOPEN switchCases CURBRACKETCLOSE { cout << "\nend"; } lineend;
;
switchCases: CASE lineend { cout << "when "; } variable COLON { cout << "\n\t"; } simpleOperation BREAK | switchCases switchCases
;
simpleOperation: variable | 
variable '+' {cout << "+"; } simpleOperation lineend
| variable '-' {cout << "-"; } simpleOperation lineend
| variable '/' {cout << "/"; } simpleOperation lineend
| variable '*' {cout << "*"; } simpleOperation lineend
| variable EQUALS {cout << "=" ;} simpleOperation lineend
;
variable: VARIABLENAME { cout << $1; free($1);} 
        | STRING { cout << $1; free($1);}
        | INT { cout << $1 ; }
        | FLOAT { cout << $1 ; }
;
array: SQBRACKETOPEN { cout << "[" ;} variables SQBRACKETCLOSE { cout << "]" ;}
;
variables: variable | variables COMMA {cout << "," ;} variable
;
variableNames: VARIABLENAME { cout << $1; free($1);} | variableNames COMMA {cout << "," ;} variableNames;

lineend: { cout << endl; }
%%


int main(int, char**) {
  FILE *myfile = fopen("data.file", "r");
  if (!myfile) {
    cout << "file not found" << endl;
    return -1;
  }
  yyin = myfile;
  yyparse();
}

void yyerror(const char *s) {
  cout << "Parsing error: " << s << endl;
  exit(-1);
}