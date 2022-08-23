#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Verifier.h"
#include "CodeGen.h"
#include "AST.h"

Value *NumberAST::codegen() {
    return ConstantFP::get(TheContext, APFloat(value));
}

Value *IdentAST::codeGen() {
    Value *V = NamedValues[name];
    if (!V)
        return LogErrorV("Unknown variable name");
    return V;
}

Value *BinaryAST::codeGen() {
    Value *L = left->codeGen();
    if (!L)
        return nullptr;
    Value *R = right->codeGen();
    if (!R)
        return nullptr;

    switch (op) {
        case '+':
            return Builder.CreateFAdd(L, R, "addtmp");
        case '-':
            return Builder.CreateFSub(L, R, "subtmp");
        case '*':
            return Builder.CreateFMul(L, R, "multmp");
        case '/':
            return Builder.CreateFDiv(L, R, "divtmp");
        default:
            return LogErrorV("invalid binary operator");
    }
}


Value *UnaryAST::codeGen() {
    Value *Operand = expr->codeGen();
    if (!Operand)
        return nullptr;

    switch (op) {
        case '-':
            return Builder.CreateFNeg(Operand, "negtmp");
        default:
            return LogErrorV("invalid unary operator");
    }
}

Value *CallAST::codeGen() {
    Function *CalleeF = module->getFunction(callee);
    if (!CalleeF)
        return LogErrorV("Unknown function referenced");

    return Builder.CreateCall(CalleeF, ArgsV, "calltmp");
}


