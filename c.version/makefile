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

examples: $(RUNNER)
	./$(RUNNER) ../exemplos/exemplo.01.cll;\
	./$(RUNNER) ../exemplos/exemplo.02.cll;\

.PHONY: test full clean clear

test:
	./$(RUNNER) ../testes.cll 

full:
	make clear recompile test examples

clean:
	rm -f ./$(LEXER_C) ./$(NAME).cpp 

clear: clean
	rm -f ./$(RUNNER)
