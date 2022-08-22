/* To \dos
1. Add ExprList
*/

%define parse.error detailed

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
    StmtAST *stmt_val;
    ExprAST *expr_val;
}

%token <str_val> IDENT FUNCTION ENDFUNCTION PROCEDURE ENDPROCEDURE RETURNS RETURN
%token <str_val> CALL DECLARE ASSIGN INTEGER
%token <str_val> IF THEN ELSE ENDIF WHILE ENDWHILE FOR TO NEXT
%token <str_val> LE GE NE MOD AND OR NOT
%token <int_val> INT_CONST

%type <ast_val> VarType FuncDef ProcDef Number Params Param
%type <block_val> Block
/* Stmt and Expr act as a mid */
%type <stmt_val> Stmt VarDecl VarAssign If While For Return
%type <expr_val> Expr VarExpr PrimaryExpr UnaryExpr BinaryExpr CallExpr

%left OR
%left AND
%left '=' NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/' MOD
%right NOT UMINUS UPLUS

%%

/*
CompUnit    ::= [CompUnit] (FuncDef | ProcDef | BLOCK);

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
    | Block {
        auto comp_unit = make_unique<CompUnitAST>();
        comp_unit->def = unique_ptr<BaseAST>($1);
        ast = move(comp_unit);
    }
    ;

Params
    : %empty
    | Param {
        auto ast = new ParamsAST();
        ast->params.push_back(unique_ptr<BaseAST>($1));
        $$ = move(ast);
    }
    | Params Param {
        $1->params->push_back(unique_ptr<BaseAST>($2));
    }
    ;

Param
    : IDENT ':' VarType {
        auto ast = new ParamAST();
        ast->ident = *unique_ptr<string>($1);
        ast->type = *unique_ptr<string>($3);
        ast = move(param);
    }
    ;

FuncDef
    : FUNCTION IDENT '(' Params ')' RETURNS VarType Block ENDFUNCTION {
        auto ast = new FuncDefAST();
        ast->ident = *unique_ptr<string>($2);
        ast->params = unique_ptr<BaseAST>($4);
        ast->var_type = unique_ptr<BaseAST>($7);
        ast->block = unique_ptr<BaseAST>($8);
        $$ = ast;
    }
    ;

ProcDef
    : PROCEDURE IDENT '(' Params ')' Block ENDPROCEDURE {
        auto ast = new ProcDefAST();
        ast->ident = *unique_ptr<string>($2);
        ast->params = unique_ptr<BaseAST>($4);
        ast->block = unique_ptr<BaseAST>($6);
        $$ = ast;
    }
    ;

Block
    : Stmt {
        auto ast = new BlockAST();
        ast->stmts->push_back(unique_ptr<StmtAST>($1));
        $$ = ast;
    }
    | Block Stmt {
        $1->stmts->push_back(unique_ptr<StmtAST>($2));
    }
    ;

Stmt
    : VarDecl
    | VarAssign 
    | If 
    | While 
    | For 
    | Return 
    ;

Expr
    : PrimaryExpr 
    | UnaryExpr 
    | BinaryExpr
    | CallExpr 
    ;

VarExpr
    : IDENT {
        auto ast = new VarExprAST();
        ast->name = *unique_ptr<string>($1);
        $$ = ast;
    }
    ;

PrimaryExpr
    : VarExpr {
        auto ast = new PrimaryExprAST();
        ast->expr = unique_ptr<ExprAST>($1);
        $$ = ast;
    }
    | Number {
        auto ast = new PrimaryExprAST();
        ast->expr = unique_ptr<ExprAST>($1);
        $$ = ast;
    }
    | '(' Expr ')' {
        auto ast = new PrimaryExprAST();
        ast->expr = unique_ptr<ExprAST>($2);
        $$ = ast;
    }
    ;

UnaryExpr
    : '+' Expr %prec UPLUS {
        auto ast = new UnaryExprAST();
        ast->op = *unique_ptr<string>(new string("+"));
        ast->expr = unique_ptr<BaseAST>($2);
        $$ = ast;
    }
    | '-' Expr %prec UMINUS {
        auto ast = new UnaryExprAST();
        ast->op = *unique_ptr<string>(new string("-"));
        ast->expr = unique_ptr<BaseAST>($2);
        $$ = ast;
    }
    | NOT Expr {
        auto ast = new UnaryExprAST();
        ast->op = *unique_ptr<string>(new string("NOT"));
        ast->expr = unique_ptr<BaseAST>($2);
        $$ = ast;
    }
    ;

BinaryExpr
    : Expr '+' Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("+"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr '-' Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("-"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr '*' Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("*"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr '/' Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("/"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr MOD Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("MOD"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr '=' Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("="));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr NE Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("<>"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr '>' Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string(">"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr '<' Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("<"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr LE Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("<="));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr GE Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string(">="));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr AND Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("AND"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | Expr OR Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<BaseAST>($1);
        ast->op = *unique_ptr<string>(new string("OR"));
        ast->rhs = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

CallExpr
    : CALL IDENT '(' ')' {
        auto ast = new CallAST();
        ast->ident = *unique_ptr<string>($2);
        $$ = ast;
    }
    ;

VarDecl
    : DECLARE IDENT ':' VarType {
        auto ast = new VarDeclAST();
        ast->ident = *unique_ptr<string>($2);
        ast->type = *unique_ptr<string>($4);
        $$ = ast;
    }
    ;

VarType
    : INTEGER
    ;

VarAssign
    : IDENT ASSIGN Expr {
        auto ast = new VarAssignAST();
        ast->ident = *unique_ptr<string>($1);
        ast->expr = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

If
    : IF Expr THEN Block ENDIF {
        auto ast = new IfAST();
        ast->cond = unique_ptr<BaseAST>($2);
        ast->block = unique_ptr<BaseAST>($4);
        $$ = ast;
    }
    | IF Expr THEN Block ELSE Block ENDIF {
        auto ast = new IfAST();
        ast->cond = unique_ptr<BaseAST>($2);
        ast->block = unique_ptr<BaseAST>($4);
        ast-> hasElse = 1;
        ast->elseBlock = unique_ptr<BaseAST>($6);
        $$ = ast;
    }
    ;

While
    : WHILE Expr Block ENDWHILE {
        auto ast = new WhileAST();
        ast->cond = unique_ptr<BaseAST>($2);
        ast->block = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

For
    : FOR IDENT ASSIGN Expr TO Expr Block NEXT {
        auto ast = new ForAST();
        ast->ident = *unique_ptr<string>($2);
        ast->exprFrom = unique_ptr<ExprAST>($4);
        ast->exprTo = unique_ptr<ExprAST>($6);
        ast->block = unique_ptr<BaseAST>($7);
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
    cerr << "\033[31;1m" << "error: " << msg << "\033[0m" << endl;
}
