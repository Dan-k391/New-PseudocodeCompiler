TARGET_EXEC = compiler
OBJS = scanner.yy.o parser.tab.o main.o
DEPS = $(OBJS:.o=.d)

$(TARGET_EXEC): $(OBJS)
	clang++ -o $@ $(OBJS)

%.o: %.cpp
	clang++ -c -o $@ $<

# Flex
scanner.yy.cpp: scanner.l parser.tab.hpp
	flex -o $@ $<

parser.tab.hpp: parser.tab.cpp

# Bison
parser.tab.cpp: parser.y
	bison -d -o $@ $<

clean: 
	rm -rf *.o compiler parser.tab.hpp parser.tab.cpp scanner.yy.cpp

-include $(DEPS)
