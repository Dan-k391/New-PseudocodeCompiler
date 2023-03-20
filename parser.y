%define parse.error verbose

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
    double real_val;
    BaseAST *ast_val;
    BlockAST *block_val;
    StmtAST *stmt_val;
    ExprAST *expr_val;
}

%token <str_val> OUTPUT
%token <str_val> IDENT FUNCTION ENDFUNCTION PROCEDURE ENDPROCEDURE RETURNS RETURN CALL
%token <str_val> DECLARE ASSIGN INTEGER REAL
%token <str_val> IF THEN ELSE ENDIF WHILE ENDWHILE FOR TO NEXT
%token <str_val> LE GE NE MOD AND OR NOT
/* %token <int_val> INT_CONST */
%token <real_val> NUMBER_CONST

%type <ast_val> FuncDef ProcDef
%type <block_val> Block
/* Stmt and Expr act as mid */
%type <stmt_val> Stmt Output Return VarDecl VarAssign If While For
%type <expr_val> Expr Number VarExpr PrimaryExpr UnaryExpr BinaryExpr
%type <str_val> BinaryOp UnaryOp VarType

%left OR
%left AND
%left '=' NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/' MOD
%right UNARY

%%

CompUnit
    : FuncDef {
        auto comp_unit = make_unique<CompUnitAST>();
        comp_unit->def = unique_ptr<BaseAST>($1);
        ast = std::move(comp_unit);
    }
    | ProcDef {
        auto comp_unit = make_unique<CompUnitAST>();
        comp_unit->def = unique_ptr<BaseAST>($1);
        ast = std::move(comp_unit);
    }
    | Block {
        auto comp_unit = make_unique<CompUnitAST>();
        comp_unit->def = unique_ptr<BaseAST>($1);
        ast = std::move(comp_unit);
    }
    ;

FuncDef
    : FUNCTION IDENT '(' ')' RETURNS VarType Block ENDFUNCTION {
        auto ast = new FuncDefAST();
        ast->ident = *unique_ptr<string>($2);
        ast->type = *unique_ptr<string>($6);
        ast->block = unique_ptr<BaseAST>($7);
        $$ = ast;
    }
    ;

ProcDef
    : PROCEDURE IDENT '(' ')' Block ENDPROCEDURE {
        auto ast = new ProcDefAST();
        ast->ident = *unique_ptr<string>($2);
        ast->block = unique_ptr<BaseAST>($5);
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

Expr
    : PrimaryExpr
    | UnaryExpr
    | BinaryExpr
    ;

VarExpr
    : IDENT {
        auto ast = new VarExprAST();
        ast->ident = *unique_ptr<string>($1);
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
    : UnaryOp Expr %prec UNARY {
        auto ast = new UnaryExprAST();
        ast->op = *unique_ptr<string>($1);
        ast->expr = unique_ptr<ExprAST>($2);
        $$ = ast;
    }
    ;

UnaryOp
    : '+' { $$ = new string("+"); }
    | '-' { $$ = new string("-"); }
    | NOT { $$ = new string("NOT"); }
    ;

BinaryExpr
    : Expr BinaryOp Expr {
        auto ast = new BinaryExprAST();
        ast->lhs = unique_ptr<ExprAST>($1);
        ast->op = *unique_ptr<string>($2);
        ast->rhs = unique_ptr<ExprAST>($3);
        $$ = ast;
    }
    ;

BinaryOp
    : '+' { $$ = new string("+"); }
    | '-' { $$ = new string("-"); }
    | '*' { $$ = new string("*"); }
    | '/' { $$ = new string("/"); }
    | MOD { $$ = new string("MOD"); }
    | '=' { $$ = new string("="); }
    | NE { $$ = new string("<>"); }
    | '>' { $$ = new string(">"); }
    | '<' { $$ = new string("<"); }
    | LE { $$ = new string("<="); }
    | GE { $$ = new string(">="); }
    | AND { $$ = new string("AND"); }
    | OR { $$ = new string("OR"); }
    ;

Stmt
    : Output
    | Return
    | VarDecl
    | VarAssign
    | If
    | While
    | For
    ;

Output
    : OUTPUT Expr {
        auto ast = new OutputAST();
        ast->expr = unique_ptr<ExprAST>($2);
        $$ = ast;
    }
    ;

Return
    : RETURN Expr {
        auto ast = new ReturnAST();
        ast->expr = unique_ptr<ExprAST>($2);
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
    | REAL
    ;

VarAssign
    : IDENT ASSIGN Expr {
        auto ast = new VarAssignAST();
        ast->ident = *unique_ptr<string>($1);
        ast->expr = unique_ptr<ExprAST>($3);
        $$ = ast;
    }
    ;

If
    : IF Expr THEN Block ENDIF {
        auto ast = new IfAST();
        ast->cond = unique_ptr<ExprAST>($2);
        ast->block = unique_ptr<BaseAST>($4);
        $$ = ast;
    }
    | IF Expr THEN Block ELSE Block ENDIF {
        auto ast = new IfAST();
        ast->cond = unique_ptr<ExprAST>($2);
        ast->block = unique_ptr<BaseAST>($4);
        ast->hasElse = 1;
        ast->elseBlock = unique_ptr<BaseAST>($6);
        $$ = ast;
    }
    ;

While
    : WHILE Expr Block ENDWHILE {
        auto ast = new WhileAST();
        ast->cond = unique_ptr<ExprAST>($2);
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

Number
    : NUMBER_CONST {
        auto ast = new NumberAST();
        ast->value = *unique_ptr<double>(new double($1));
        $$ = ast;
    }
    ;

%%

void yyerror(unique_ptr<BaseAST> &ast, const char *msg) {
    cerr << "\033[31;1m" << "error: " << msg << "\033[0m" << endl;
}
