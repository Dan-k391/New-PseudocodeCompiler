TARGET_EXEC = compiler
OBJS = scanner.yy.o parser.tab.o CodeGen.o main.o
DEPS = $(OBJS:.o=.d)
LLVMCONFIG = llvm-config
CPPFLAGS = `$(LLVMCONFIG) --cxxflags --ldflags --system-libs --libs core`

$(TARGET_EXEC): $(OBJS)
	clang++ $(CPPFLAGS) -g -o $@ $(OBJS)

%.o: %.cpp
	clang++ $(CPPFLAGS) -c -o $@ $<

# Flex
scanner.yy.cpp: scanner.l parser.tab.hpp
	flex -o $@ $<

parser.tab.hpp: parser.tab.cpp

# Bison
parser.tab.cpp: parser.y
	bison -d -o $@ $<

clean: 
	rm -rf *.o compiler parser.tab.hpp parser.tab.cpp scanner.yy.cpp
