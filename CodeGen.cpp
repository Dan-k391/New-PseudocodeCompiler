#include "CodeGen.h"
#include <cstddef>
#include <llvm-16/llvm/IR/IRBuilder.h>
#include <llvm-16/llvm/IR/LLVMContext.h>
#include <memory>


Value* logError(const char *str) {
    cout << "error: " << str;
    return nullptr;
}

static void initializeModuleAndPassManager() {
    context = make_unique<LLVMContext>();
    module = make_unique<Module>("my cool jit", *context);
    builder = make_unique<IRBuilder<>>(*context);

    fpm = make_unique<legacy::FunctionPassManager>(module.get());
    fpm->add(createInstructionCombiningPass());
    fpm->add(createReassociatePass());
    fpm->add(createGVNPass());
    fpm->add(createCFGSimplificationPass());

    fpm->doInitialization();
}

Value* CompUnitAST::codeGen() {
    initializeModuleAndPassManager();
    this->codeGenDump();
    Value* ret = this->def->codeGen();
    if (!ret) 
        return logError("error in compunit");
    return ret;
}

Function* FuncDefAST::codeGen() {
    this->codeGenDump();
    return nullptr;
}

Function* ProcDefAST::codeGen() {
    this->codeGenDump();
    return nullptr;
}

Value* BlockAST::codeGen() {
    this->codeGenDump();
    for (auto &stmt: *this->stmts) {
        Value* ret = stmt->codeGen();
        if (!ret)
            return nullptr;
    }
}

Value* NumberAST::codeGen() {
    this->codeGenDump();
    return ConstantFP::get(*context, APFloat(this->value));
}

Value* VarExprAST::codeGen() {
    this->codeGenDump();
    Value* V = namedValues[this->ident];
    if (!V)
        return logError("Unknown variable name");
    return V;
}

Value* PrimaryExprAST::codeGen() {
    this->codeGenDump();
    return expr->codeGen();
}

Value* BinaryExprAST::codeGen() {
    this->codeGenDump();
    Value* L = this->lhs->codeGen();
    if (!L)
        return logError("invalid right hand side binary operation");
    Value* R = this->rhs->codeGen();
    if (!R)
        return logError("invalid right hand side binary operation");
    
    if (this->op == "+")
        return builder->CreateFAdd(L, R, "addtmp");
    else if (this->op == "-")
        return builder->CreateFSub(L, R, "subtmp");
    else if (this->op == "*")
        return builder->CreateFMul(L, R, "multmp");
    else if (this->op == "/")
        return builder->CreateFDiv(L, R, "divtmp");
    else
        return logError("invalid binary operator");
}


Value* UnaryExprAST::codeGen() {
    this->codeGenDump();
    Value* Operand = this->expr->codeGen();
    if (!Operand)
        return nullptr;

    if (this->op == "+")
        return Operand;
    else if (this->op == "-")
        return builder->CreateFNeg(Operand, "negtmp");
    else
        return logError("invalid unary operator");
}

Value* VarDeclAST::codeGen() {
    this->codeGenDump();
}

Value* VarAssignAST::codeGen() {
    this->codeGenDump();
    Value* V = namedValues[this->ident];
    if (!V)
        return logError("Unknown variable name");

    Value* R = this->expr->codeGen();
    if (!R)
        return logError("invalid right hand side binary operation");

    builder->CreateStore(R, V);
    return R;
}

Value* IfAST::codeGen() {
}

Value* WhileAST::codeGen() {
}

Value* ForAST::codeGen() {
}

Value* ReturnAST::codeGen() {
}

Value* OutputAST::codeGen() {
}
