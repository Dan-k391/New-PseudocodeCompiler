%option noyywrap
%option nounput
%option noinput

%{

#include <cstdlib>
#include <string>
#include <memory>
#include <iostream>

// 因为 Flex 会用到 Bison 中关于 token 的定义
// 所以需要 include Bison 生成的头文件
#include "parser.tab.hpp"
#include "AST.h"

using namespace std;

void yyerror(const char *msg);
int cur_line = 1;

%}

/* 空白符和注释 */
NewLine       \n
WhiteSpace    [ \t\r]*
LineComment   "//".*$

Operator     [+\-*/=,:!<>()\[\]]

/* 标识符 */
Identifier    [a-zA-Z_][a-zA-Z0-9_]*

/* 整数字面量 */
Decimal       [1-9][0-9]*
Octal         0[0-7]*
Hexadecimal   0[xX][0-9a-fA-F]+

%%

{NewLine}       { cur_line++; }
{WhiteSpace}    { /* 忽略, 不做任何操作 */ }
{LineComment}   { /* 忽略, 不做任何操作 */ }

{Operator}      { yylval.str_val = new string(yytext); return yytext[0]; }

"DECLARE"       { yylval.str_val = new string(yytext); return DECLARE; }
"INTEGER"       { yylval.str_val = new string(yytext); return INTEGER; }
"FUNCTION"      { yylval.str_val = new string(yytext); return FUNCTION; }
"ENDFUNCTION"   { yylval.str_val = new string(yytext); return ENDFUNCTION; }
"PROCEDURE"     { yylval.str_val = new string(yytext); return PROCEDURE; }
"ENDPROCEDURE"  { yylval.str_val = new string(yytext); return ENDPROCEDURE; }
"RETURNS"       { yylval.str_val = new string(yytext); return RETURNS; }
"RETURN"        { yylval.str_val = new string(yytext); return RETURN; }

{Identifier}    { yylval.str_val = new string(yytext); return IDENT; }

{Decimal}       { yylval.int_val = strtol(yytext, nullptr, 0); return INT_CONST; }
{Octal}         { yylval.int_val = strtol(yytext, nullptr, 0); return INT_CONST; }
{Hexadecimal}   { yylval.int_val = strtol(yytext, nullptr, 0); return INT_CONST; }

.               { yyerror(yytext); }

%%

void yyerror(const char *msg) {
    cerr << "Unrecognized character at line " << cur_line << ": '" << msg << "'" << endl;
}
