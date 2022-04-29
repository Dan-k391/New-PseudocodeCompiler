%code requires {
    #include <memory>
    #include <string>
    #include "AST.h"
}

%{

#include <iostream>
#include <memory>
#include <string>
#include "AST.h"

int yylex();
void yyerror(unique_ptr<BaseAST> &ast, const char *s);

using namespace std;

%}

%parse-param { unique_ptr<BaseAST> &ast }

%union {
    std::string *str_val;
    int int_val;
    BaseAST *ast_val;
}

%token <str_val> IDENT FUNCTION ENDFUNCTION PROCEDURE ENDPROCEDURE RETURNS RETURN
%token <str_val> DECLARE INTEGER
%token <int_val> INT_CONST

%type <ast_val> FuncDef ProcDef Block Stmt Decl VarDecl VarType Assign Return
%type <int_val> Number

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
    : FUNCTION IDENT '(' ')' RETURNS VarType Block ENDFUNCTION {
        auto ast = new FuncDefAST();
        ast->ident = *unique_ptr<string>($2);
        ast->var_type = unique_ptr<BaseAST>($6);
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
        ast->stmt = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | Stmt Block {
        auto ast = new BlockAST();
        ast->stmt = unique_ptr<BaseAST>($1);
        ast->block = unique_ptr<BaseAST>($2);
        $$ = ast;
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

Return
    : RETURN Number {
        auto ast = new ReturnAST();
        ast->number = *unique_ptr<int>(new int($2));
        $$ = ast;
    }
    ;

Number
    : INT_CONST {
        $$ = $1;
    }
    ;

%%

void yyerror(unique_ptr<BaseAST> &ast, const char *s) {
    cerr << "error: " << s << endl;
}
