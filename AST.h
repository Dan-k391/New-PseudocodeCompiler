#pragma once
#ifndef __AST_H__
#define __AST_H__

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

class BaseAST;

typedef vector<unique_ptr<BaseAST>> StmtList;

class BaseAST {
protected:
    const char *midPREFIX = "├─ ";
    const char *endPREFIX = "└─ ";
public:
    virtual ~BaseAST() = default;
    virtual string getTypeName() const = 0;
    // 判断先判isLast再判else
    virtual void dump(string prefix, bool isLast) const = 0;
    // virtual Value *codeGen() const = 0;
};

class CompUnitAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;126m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> def;

    string getTypeName() const override {
        return "CompUnit";
    }

    void dump(string prefix, bool isLast) const override {
        // dump with color
        cout << prefix << this->colSTART << getTypeName() << this->colEND << endl;
        def->dump(prefix, 1);
    }

    // Value *codeGen() override;
};

// 留到后面改进dump函数
class FuncDefAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    // 还是直接使用字符串作为参数名，不多套一层了
    // 还是得套😂
    unique_ptr<BaseAST> ident;
    unique_ptr<BaseAST> var_type;
    unique_ptr<BaseAST> block;

    string getTypeName() const override {
        return "FuncDef";
    }

    void dump(string prefix, bool isLast) const override {
        cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
        ident->dump(prefix + "│  ", 0);
        var_type->dump(prefix + "│  ", 0);
        block->dump(prefix, 0);
    }

    // Value *codeGen() override;
};

// 留到后面改进dump函数
class ProcDefAST : public BaseAST {
protected:
    const char *colSTART = "\033[34;1m";
    const char *colEND = "\033[0m";
public:
    // 还是直接使用字符串作为参数名，不多套一层了
    // 还是得套😂
    unique_ptr<BaseAST> ident;
    unique_ptr<BaseAST> block;

    string getTypeName() const override {
        return "ProcDef";
    }

    void dump(string prefix, bool isLast) const override {
        cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
        ident->dump(prefix + "│  ", 0);
        block->dump(prefix + "│  ", 0);
    }

    // Value *codeGen() override;
};

class IdentAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;208m";
    const char *colEND = "\033[0m";
public:
    string name;

    string getTypeName() const override {
        return "Ident";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << ": " << name << endl;
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << ": " << name << endl;
        }
    }

    // Value *codeGen() override;
};

class BlockAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;6m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<StmtList> stmts = make_unique<StmtList>();

    string getTypeName() const override {
        return "Block";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            for(auto stmt = stmts->begin(); stmt != stmts->end(); stmt++) {
                if (stmt == stmts->end() - 1) {
                    (*stmt)->dump(prefix + "   ", 1);
                } else {
                    (*stmt)->dump(prefix + "   ", 0);
                }
            }
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            for(auto stmt = stmts->begin(); stmt != stmts->end(); stmt++) {
                if (stmt == stmts->end() - 1) {
                    (*stmt)->dump(prefix + "│  ", 1);
                } else {
                    (*stmt)->dump(prefix + "│  ", 0);
                }
            }
        }
    }

    // Value *codeGen() override;
};

class StmtAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> stmt;

    string getTypeName() const override {
        return "Stmt";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            stmt->dump(prefix + "   ", 0);
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            stmt->dump(prefix + "│  ", 0);
        }
    }

    // Value *codeGen() override;
};

class ExprAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;220m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "Expr";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            expr->dump(prefix + "   ", 1);
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            expr->dump(prefix + "│  ", 1);
        }
    }

    // Value *codeGen() override;
};

class PrimaryExprAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;220m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "PrimaryExpr";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            expr->dump(prefix + "   ", 1);
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            expr->dump(prefix + "│  ", 1);
        }
    }

    // Value *codeGen() override;
};

class UnaryExprAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;220m";
    const char *colEND = "\033[0m";
public:
    string op;
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "UnaryExpr";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << "->Op: " << op << endl;
            expr->dump(prefix + "   ", 1);
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << "->Op: " << op << endl;
            expr->dump(prefix + "│  ", 1);
        }
    }

    // Value *codeGen() override;
};

class BinaryExprAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;220m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> lhs;
    string op;
    unique_ptr<BaseAST> rhs;

    string getTypeName() const override {
        return "BinaryExpr";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << "->Op: " << op << endl;
            lhs->dump(prefix + "   ", 0);
            rhs->dump(prefix + "   ", 1);
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << "->Op: " << op << endl;
            lhs->dump(prefix + "│  ", 0);
            rhs->dump(prefix + "│  ", 1);
        }
    }

    // Value *codeGen() override;
};

class DeclAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> decl;

    string getTypeName() const override {
        return "Decl";
    }

    void dump(string prefix, bool isLast) const override {
        cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
        decl->dump(prefix + "   ", 1);
    }

    // Value *codeGen() override;
};

class VarDeclAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    // 先多套一层，看后期能否简化
    unique_ptr<BaseAST> ident;
    unique_ptr<BaseAST> type;

    string getTypeName() const override {
        return "VarDecl";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            ident->dump(prefix + "   ", 0);
            type->dump(prefix + "   ", 1);
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            ident->dump(prefix + "│  ", 0);
            type->dump(prefix + "│  ", 1);
        }
    }

    // Value *codeGen() override;
};

class VarTypeAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;220m";
    const char *colEND = "\033[0m";
public:
    string type;

    string getTypeName() const override {
        return "VarType";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << ": " << type << endl;
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << ": " << type << endl;
        }
    }

    // Value *codeGen() override;
};

class AssignAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> assign;

    string getTypeName() const override {
        return "Assign";
    }

    void dump(string prefix, bool isLast) const override {
        cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
        assign->dump(prefix + "   ", 1);   
    }

    // Value *codeGen() override;
};

class VarAssignAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    // 先多套一层，看后期能否简化
    unique_ptr<BaseAST> ident;
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "VarAssign";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            ident->dump(prefix + "   ", 0);
            expr->dump(prefix + "   ", 1);
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            ident->dump(prefix + "│  ", 0);
            expr->dump(prefix + "│  ", 1);
        }
    }

    // Value *codeGen() override;
};

class IfAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> cond;
    unique_ptr<BaseAST> block;
    bool hasElse = 0;
    unique_ptr<BaseAST> elseBlock;

    string getTypeName() const override {
        return "If";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            cond->dump(prefix + "   ", 0);
            // 比较细节的写法
            if (hasElse) {
                block->dump(prefix + "   ", 0);
                elseBlock->dump(prefix + "   ", 1);
            } else {
                block->dump(prefix + "   ", 1);
            }
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            cond->dump(prefix + "│  ", 0);
            if (hasElse) {
                block->dump(prefix + "│  ", 0);
                elseBlock->dump(prefix + "│  ", 1);
            } else {
                block->dump(prefix + "│  ", 1);
            }
        }
    }

    // Value *codeGen() override;
};

class WhileAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> cond;
    unique_ptr<BaseAST> block;

    string getTypeName() const override {
        return "While";
    }

    void dump(string prefix, bool isLast) const override {
        cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
        cond->dump(prefix + "   ", 0);
        block->dump(prefix + "   ", 1);
    }

    // Value *codeGen() override;
};

class ForAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> ident;
    unique_ptr<BaseAST> exprFrom;
    unique_ptr<BaseAST> exprTo;
    unique_ptr<BaseAST> block;

    string getTypeName() const override {
        return "For";
    }

    void dump(string prefix, bool isLast) const override {
        cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
        ident->dump(prefix + "   ", 1);
        exprFrom->dump(prefix + "   ", 1);
        exprTo->dump(prefix + "   ", 1);
        block->dump(prefix + "   ", 1);
    }

    // Value *codeGen() override;
};

class ReturnAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;51m";
    const char *colEND = "\033[0m";
public:
    unique_ptr<BaseAST> expr;

    string getTypeName() const override {
        return "Return";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            expr->dump(prefix + "   ", 1);
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << endl;
            expr->dump(prefix + "│  ", 0);
        }
    }

    // Value *codeGen() override;
};

class NumberAST : public BaseAST {
protected:
    const char *colSTART = "\033[38;5;82m";
    const char *colEND = "\033[0m";
public:
    int value;

    string getTypeName() const override {
        return "Number";
    }

    void dump(string prefix, bool isLast) const override {
        if (isLast) {
            cout << prefix << this->endPREFIX << this->colSTART << getTypeName() << this->colEND << ": " << value << endl;
        } else {
            cout << prefix << this->midPREFIX << this->colSTART << getTypeName() << this->colEND << ": " << value << endl;
        }
    }

    // Value *codeGen() override;
};

#endif
