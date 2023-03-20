%option noyywrap
%option nounput
%option noinput

%{

#include <cstdlib>
#include <string>
#include <memory>
#include <iostream>

#include "parser.tab.hpp"
#include "AST.h"

using namespace std;

void yyerror(const char *msg);
int cur_line = 1;

%}

NewLine       \n
WhiteSpace    [ \t\r]*
LineComment   "//".*$

Operator      [+\-*/=,:!<>()\[\]]

Identifier    [a-zA-Z_][a-zA-Z0-9_]*

/* 数字 */
/* Int           [0-9]+ */
Number        [0-9]+\.?[0-9]*

%%

{NewLine}       { cur_line++; }
{WhiteSpace}    { /* 忽略, 不做任何操作 */ }
{LineComment}   { /* 忽略, 不做任何操作 */ }

{Operator}      { yylval.str_val = new string(yytext); return yytext[0]; }

"OUTPUT"        { yylval.str_val = new string(yytext); return OUTPUT; }

"FUNCTION"      { yylval.str_val = new string(yytext); return FUNCTION; }
"ENDFUNCTION"   { yylval.str_val = new string(yytext); return ENDFUNCTION; }
"PROCEDURE"     { yylval.str_val = new string(yytext); return PROCEDURE; }
"ENDPROCEDURE"  { yylval.str_val = new string(yytext); return ENDPROCEDURE; }
"RETURNS"       { yylval.str_val = new string(yytext); return RETURNS; }
"RETURN"        { yylval.str_val = new string(yytext); return RETURN; }
"CALL"          { yylval.str_val = new string(yytext); return CALL; }
"DECLARE"       { yylval.str_val = new string(yytext); return DECLARE; }
"<-"            { yylval.str_val = new string(yytext); return ASSIGN; }
"INTEGER"       { yylval.str_val = new string(yytext); return INTEGER; }
"REAL"          { yylval.str_val = new string(yytext); return REAL; }
"IF"            { yylval.str_val = new string(yytext); return IF; }
"THEN"          { yylval.str_val = new string(yytext); return THEN; }
"ELSE"          { yylval.str_val = new string(yytext); return ELSE; }
"ENDIF"         { yylval.str_val = new string(yytext); return ENDIF; }
"WHILE"         { yylval.str_val = new string(yytext); return WHILE; }
"ENDWHILE"      { yylval.str_val = new string(yytext); return ENDWHILE; }
"FOR"           { yylval.str_val = new string(yytext); return FOR; }
"TO"            { yylval.str_val = new string(yytext); return TO; }
"NEXT"          { yylval.str_val = new string(yytext); return NEXT; }
"<="            { yylval.str_val = new string(yytext); return LE; }
">+"            { yylval.str_val = new string(yytext); return GE; }
"<>"            { yylval.str_val = new string(yytext); return NE; }
"MOD"           { yylval.str_val = new string(yytext); return MOD; }
"AND"           { yylval.str_val = new string(yytext); return AND; }
"OR"            { yylval.str_val = new string(yytext); return OR; }
"NOT"           { yylval.str_val = new string(yytext); return NOT; }

{Identifier}    { yylval.str_val = new string(yytext); return IDENT; }

{Number}        { yylval.real_val = strtof(yytext, nullptr); return NUMBER_CONST; }

.               { yyerror(yytext); }

%%

void yyerror(const char *msg) {
    cerr << "Unrecognized character at line " << cur_line << ": '" << msg << "'" << endl;
}
