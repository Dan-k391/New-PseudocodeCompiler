#pragma once
#ifndef AST_H
#define AST_H

#include <iostream>
#include <vector>
#include <memory>
#include <string>

using std::vector;
using std::string;
using std::unique_ptr;
using std::make_unique;
using std::cout;
using std::endl;


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
Block       ::= {Block} Stmt;
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

class BaseAST;

typedef vector<unique_ptr<BaseAST>> StmtList;

class BaseAST {
public:
    virtual ~BaseAST() = default;
    virtual string getTypeName() const = 0;
    virtual void dump(string prefix) const = 0;
};

class CompUnitAST : public BaseAST {
public:
    unique_ptr<BaseAST> def;

    string getTypeName() const override {
        return "CompUnit";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        def->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class FuncDefAST : public BaseAST {
public:
    // 还是直接使用字符串作为参数名，不多套一层了
    // 还是得套😂
    unique_ptr<BaseAST> ident;
    unique_ptr<BaseAST> var_type;
    unique_ptr<BaseAST> block;

    string getTypeName() const override {
        return "FuncDef";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        ident->dump(prefix + "  ");
        var_type->dump(prefix + "  ");
        block->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class ProcDefAST : public BaseAST {
public:
    // 还是直接使用字符串作为参数名，不多套一层了
    // 还是得套😂
    unique_ptr<BaseAST> ident;
    unique_ptr<BaseAST> block;

    string getTypeName() const override {
        return "ProcDef";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        ident->dump(prefix + "  ");
        block->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class IdentAST : public BaseAST {
public:
    string value;

    string getTypeName() const override {
        return "Ident";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        cout << prefix << "  " << "Value: " << value << endl;
        cout << prefix << "}" << endl;
    }
};

class BlockAST : public BaseAST {
public:
    unique_ptr<StmtList> stmts = make_unique<StmtList>();

    string getTypeName() const override {
        return "Block";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "[" << endl;
        for (auto& stmt : *stmts) {
            stmt->dump(prefix + "  ");
        }
        cout << prefix << "]" << endl;
    }
};

class StmtAST : public BaseAST {
public:
    unique_ptr<BaseAST> stmt;

    string getTypeName() const override {
        return "Stmt";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        stmt->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class ExprAST : public BaseAST {
public:
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "Expr";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        expr->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class PrimaryExprAST : public BaseAST {
public:
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "PrimaryExpr";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        expr->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class UnaryExprAST : public BaseAST {
public:
    string op;
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "UnaryExpr";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        cout << prefix << "  " << "Op: " << op << endl;
        expr->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class BinaryExprAST : public BaseAST {
public:
    unique_ptr<BaseAST> lhs;
    string op;
    unique_ptr<BaseAST> rhs;

    string getTypeName() const override {
        return "BinaryExpr";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        lhs->dump(prefix + "  ");
        cout << prefix << "  " << "Op: " << op << endl;
        rhs->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class DeclAST : public BaseAST {
public:
    unique_ptr<BaseAST> decl;

    string getTypeName() const override {
        return "Decl";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        decl->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class VarDeclAST : public BaseAST {
public:
    string ident;
    unique_ptr<BaseAST> type;

    string getTypeName() const override {
        return "VarDecl";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        cout << prefix << "  " << "Ident: " << ident << "," << endl;
        type->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class VarTypeAST : public BaseAST {
public:
    string type;

    string getTypeName() const override {
        return "VarType";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << ": " << type << "," << endl;
    }
};

class AssignAST : public BaseAST {
public:
    unique_ptr<BaseAST> assign;

    string getTypeName() const override {
        return "Assign";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        assign->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class VarAssignAST : public BaseAST {
public:
    string ident;
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "VarAssign";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        cout << prefix << "  " << "Ident: " << ident << "," << endl;
        expr->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class ReturnAST : public BaseAST {
public:
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "Return";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << "{" << endl;
        expr->dump(prefix + "  ");
        cout << prefix << "}" << endl;
    }
};

class NumberAST : public BaseAST {
public:
    int value;

    string getTypeName() const override {
        return "Number";
    }

    void dump(string prefix) const override {
        cout << prefix << getTypeName() << ": " << value << "," << endl;
    }
};

#endif
