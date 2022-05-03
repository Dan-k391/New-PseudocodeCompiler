%code requires {
    #include <iostream>
    #include <memory>
    #include <string>
    #include <vector>
    #include "AST.h"
}

%{

#include <iostream>
#include <memory>
#include <string>
#include <vector>
#include "AST.h"

int yylex();
void yyerror(unique_ptr<BaseAST> &ast, const char *msg);

using namespace std;

%}

%parse-param { unique_ptr<BaseAST> &ast }

%union {
    std::string *str_val;
    int int_val;
    BaseAST *ast_val;
    BlockAST *block_val;
}

%token <str_val> IDENT FUNCTION ENDFUNCTION PROCEDURE ENDPROCEDURE RETURNS RETURN
%token <str_val> DECLARE INTEGER NOT MOD AND OR
%token <int_val> INT_CONST

%type <ast_val> FuncDef ProcDef Ident Stmt Expr PrimaryExpr UnaryExpr BinaryExpr
%type <ast_val> Decl VarDecl VarType Assign VarAssign Return Number
%type <block_val> Block
%type <str_val> UnaryOp BinaryOp ArithOp RelOp

%%

/*
CompUnit    ::= [CompUnit] (FuncDef | ProcDef | Decl);

(* FuncDef *)
FuncDef     ::= "FUNCTION" Ident "(" [Params] ")" "RETURNS" VarType Block "ENDFUNCTION";
(* FuncDef *)

(* ProcDef *)
ProcDef     ::= "PROCEDURE" Ident "(" [Params] ")" Block "ENDPROCEDURE";
(* ProcDef *)

Params      ::= Param {"," Param};
Param       ::= Ident ":" VarType;

(* Block *)
Block       ::= {Stmt};
Stmt        ::= Decl | Assign | If | While | For | Return | Call;
(* Block *)

(* Expr *)
Expr        ::= PrimaryExpr | UnaryExpr | BinaryExpr;
PrimaryExpr ::= Ident | IntConst | RealConst | CharConst | StringConst | BoolConst | "(" Expr ")" | LVal;
UnaryExpr   ::= UnaryOp Expr;
UnaryOp     ::= "+" | "-" | "NOT";
BinaryExpr  ::= Expr BinaryOp Expr;
BinaryOp    ::= ArithOp | RelOp;
ArithOp     ::= "+" | "-" | "*" | "/" | "MOD";
RelOp       ::= "=" | "<" | ">" | "<=" | ">=" | "<>" | "AND" | "OR";
(* Expr *)

Decl        ::= (VarDecl | ArrDecl) Newline;
VarDecl     ::= "DECLARE" Ident ":" VarType;
VarType     ::= "INTEGER" | "REAL" | "CHAR" | "STRING" | "BOOLEAN";
ArrDecl     ::= "DECLARE" Ident ":" "ARRAY" "[" Bounds "]" "OF" VarType;
Bounds      ::= Bound {"," Bound};
Bound       ::= Lower ":" Upper;
Lower       ::= Expr;
Upper       ::= Expr;

Assign      ::= VarAssign | ArrAssign;
VarAssign   ::= Ident "<-" Expr Newline;
ArrAssign   ::= LVal "<-" Expr Newline;
LVal        ::= Ident ["[" Indexes "]"];
Indexes     ::= Index {"," Index};
Index       ::= Expr;

If          ::= "IF" Expr "THEN" Block ["ELSE" Block] "ENDIF" Newline;

While       ::= "WHILE" Expr Block "ENDWHILE" Newline;

For         ::= "FOR" Ident "<-" Expr "TO" Expr Block "NEXT" Newline;

Return      ::= "RETURN" Expr Newline;

Call        ::= "CALL" Ident "(" [ParamVals] ")" Newline;
ParamVals   ::= ParamVals {"," ParamVal};
ParamVal    ::= Expr;

Newline     ::= "\n";
*/

CompUnit
    : FuncDef {
        auto comp_unit = make_unique<CompUnitAST>();
        comp_unit->def = unique_ptr<BaseAST>($1);
        ast = move(comp_unit);
    }
    | ProcDef {
        auto comp_unit = make_unique<CompUnitAST>();
        comp_unit->def = unique_ptr<BaseAST>($1);
        ast = move(comp_unit);
    }
    ;

FuncDef
    : FUNCTION Ident '(' ')' RETURNS VarType Block ENDFUNCTION {
        auto ast = new FuncDefAST();
        ast->ident = unique_ptr<BaseAST>($2);
        ast->var_type = unique_ptr<BaseAST>($6);
        ast->block = unique_ptr<BaseAST>($7);
        $$ = ast;
    }
    ;

ProcDef
    : PROCEDURE Ident '(' ')' Block ENDPROCEDURE {
        auto ast = new ProcDefAST();
        ast->ident = unique_ptr<BaseAST>($2);
        ast->block = unique_ptr<BaseAST>($5);
        $$ = ast;
    }
    ;

Ident
    : IDENT{
        auto ast = new IdentAST();
        ast->value = *unique_ptr<string>($1);
        $$ = ast;
    }
    ;

Block
    : Stmt {
        auto ast = new BlockAST();
        ast->stmts->push_back(unique_ptr<BaseAST>($1));
        $$ = ast;
    }
    | Block Stmt {
        $1->stmts->push_back(unique_ptr<BaseAST>($2));
    }
    ;

Stmt
    : Return {
        auto ast = new StmtAST();
        ast->stmt = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | Decl {
        auto ast = new StmtAST();
        ast->stmt = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | Assign {
        auto ast = new StmtAST();
        ast->stmt = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    ;

Expr
    : PrimaryExpr {
        auto ast = new ExprAST();
        ast->expr = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | UnaryExpr {
        auto ast = new ExprAST();
        ast->expr = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | BinaryExpr {
        auto ast = new ExprAST();
        ast->expr = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    ;

PrimaryExpr
    : Ident {
        auto ast = new PrimaryExprAST();
        ast->expr = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | Number {
        auto ast = new PrimaryExprAST();
        ast->expr = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | '(' Expr ')' {
        auto ast = new PrimaryExprAST();
        ast->expr = unique_ptr<BaseAST>($2);
        $$ = ast;
    }
    ;

UnaryExpr
    : UnaryOp Expr {
        auto ast = new UnaryExprAST();
        ast->op = *unique_ptr<string>($1);
        ast->expr = unique_ptr<BaseAST>($2);
        $$ = ast;
    }
    ;

UnaryOp
    : '+' {
        $$ = new string("+");
    }
    | '-' {
        $$ = new string("-");
    }
    | NOT {
        $$ = new string("NOT");
    }
    ;

BinaryExpr
    : Expr BinaryOp Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>($2);
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

BinaryOp
    : ArithOp {
        $$ = $1;
    }
    | RelOp {
        $$ = $1;
    }
    ;

ArithOp
    : '+' {
        $$ = new string("+");
    }
    | '-' {
        $$ = new string("-");
    }
    | '*' {
        $$ = new string("*");
    }
    | '/' {
        $$ = new string("/");
    }
    | MOD {
        $$ = new string("MOD");
    }
    ;

RelOp
    : '=' {
        $$ = new string("=");
    }
    | '<' '>' {
        $$ = new string("<>");
    }
    | '<' {
        $$ = new string("<");
    }
    | '>' {
        $$ = new string(">");
    }
    | '<' '=' {
        $$ = new string("<=");
    }
    | '>' '=' {
        $$ = new string(">=");
    }
    | AND {
        $$ = new string("AND");
    }
    | OR {
        $$ = new string("OR");
    }
    ;

Decl
    : VarDecl {
        auto ast = new DeclAST();
        ast->decl = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    ;

VarDecl
    : DECLARE IDENT ':' VarType {
        auto ast = new VarDeclAST();
        ast->ident = *unique_ptr<string>($2);
        ast->type = unique_ptr<BaseAST>($4);
        $$ = ast;
    }
    ;

VarType
    : INTEGER {
        auto ast = new VarTypeAST();
        ast->type = *unique_ptr<string>($1);
        $$ = ast;
    }
    ;

Assign
    : VarAssign {
        auto ast = new AssignAST();
        ast->assign = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    ;

VarAssign
    : IDENT '<' '-' Expr {
        auto ast = new VarAssignAST();
        ast->ident = *unique_ptr<string>($1);
        ast->expr = unique_ptr<BaseAST>($4);
        $$ = ast;
    }
    ;

Return
    : RETURN Expr {
        auto ast = new ReturnAST();
        ast->expr = unique_ptr<BaseAST>($2);
        $$ = ast;
    }
    ;

Number
    : INT_CONST {
        auto ast = new NumberAST();
        ast->value = *unique_ptr<int>(new int($1));
        $$ = ast;
    }
    ;

%%

void yyerror(unique_ptr<BaseAST> &ast, const char *msg) {
    cerr << "error: " << msg << endl;
}
