#include <cassert>
#include <cstdio>
#include <iostream>
#include <memory>
#include <string>
#include "AST.h"

using namespace std;

extern FILE *yyin;
extern int yyparse(unique_ptr<BaseAST> &ast);

int main(int argc, const char *argv[]) {
    assert(argc == 2);
    auto input = argv[1];

    yyin = fopen(input, "r");
    assert(yyin);

    unique_ptr<BaseAST> ast;
    auto ret = yyparse(ast);
    assert(!ret);

    // dump AST
    ast->dump("", 0);
    cout << endl;
    
    return 0;
}
