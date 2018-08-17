NAME = cascavell
EXTEND = c
LEXER = $(NAME).lex.$(EXTEND).l
LEXER_C = $(NAME).$(EXTEND)
RUNNER = $(NAME).$(EXTEND).run
FLEX = flex
GCC = gcc
CFLAGS = -lfl

recompile:
	make $(RUNNER)

$(LEXER_C) : $(LEXER)
	$(FLEX) -o $@ $< ;

$(RUNNER) : $(LEXER_C)
	$(GCC) $< -o $@ $(CFLAGS);

.PHONY: test full clean clear

test:
	./$(RUNNER) ../testes.cll 

full:
	make clear recompile test

clean:
	rm -f ./*.c ./*cpp ./*.h

clear: clean
	rm -f ./*.run
