NAME = cascavell
EXTEND = cpp
LEXER = $(NAME).lex.$(EXTEND).l
LEXER_CPP = $(NAME).$(EXTEND)
RUNNER = $(NAME).$(EXTEND).run
FLEX = flex
GPP = g++
CCFLAGS = -lfl -std=c++11

recompile:
	make $(RUNNER)

$(LEXER_CPP) : $(LEXER)
	$(FLEX) -+ -o $@ $<;

$(RUNNER) : $(LEXER_CPP)
	$(GPP) $< -o $@ $(CCFLAGS);

.PHONY: test full clean clear

test:
	./$(RUNNER) ../testes.cll 

full:
	make clear recompile test

clean:
	rm -f ./*.c ./*cpp ./*.h

clear: clean
	rm -f ./*.run
