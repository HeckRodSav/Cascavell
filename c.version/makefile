NAME = cascavell
EXTEND = c
LEXER_EXTEND = lex.$(EXTEND)
LEXER = $(NAME).$(LEXER_EXTEND).l
LEXER_C = $(NAME).$(LEXER_EXTEND)
PARSER_EXTEND = yacc.$(EXTEND)
PARSER = $(NAME).$(PARSER_EXTEND).Y
PARSER_C = $(NAME).$(PARSER_EXTEND)
RUNNER = $(NAME).$(EXTEND).run
FLEX = flex
YACC = bison
GCC = gcc
CFLAGS = -lfl -lm

recompile: clean $(RUNNER)
	echo Done

$(PARSER_C) : $(PARSER) $(LEXER)
	$(YACC) $< -o $@ -b $(LEXER) --defines

$(LEXER_C) : $(LEXER) $(PARSER_C)
	$(FLEX) -o $@ $< ;

$(RUNNER) : $(PARSER_C) $(LEXER_C) stack.c
	$(GCC) $^ -o $@ $(CFLAGS);

examples: $(RUNNER)
	./$(RUNNER) ../exemplos/exemplo.01.cll;\
	./$(RUNNER) ../exemplos/exemplo.02.cll;\

	# bison cascavell.yacc.c.y -o cascavell.yacc.c -b cascavell.lex.c.l --defines

.PHONY: test full clean clear

test:
	./$(RUNNER) ../testes.cll 

full:
	make clear recompile test examples

clean:
	rm -f ./$(LEXER_C) ./$(PARSER_C) ./$(NAME).cpp ./cascavell.yacc.h

clear: clean
	rm -f ./$(RUNNER)









# NAME = calc
# LEXER = $(NAME).l
# LEXER_C = $(NAME).lex.c
# YACCER = $(NAME).y
# YACCER_C = $(NAME).yac.c
# RUNNER = $(NAME).run
# FLEX = flex
# YACC = bison
# GCC = gcc
# CFLAGS = -lfl -lm

# recompile:
# 	make $(RUNNER)

# $(YACCER_C) : $(YACCER) $(LEXER)
# 	$(YACC) $< -o $@ -b $(LEXER) --defines

# $(LEXER_C) : $(LEXER) $(YACCER_C)
# 	$(FLEX) -o $@ $<

# $(RUNNER) : $(LEXER_C) $(YACCER_C)
# 	$(GCC) $^ -o $@ $(CFLAGS)

# .PHONY: clean test full clear

# full:
# 	make clean recompile test

# clean:
# 	rm -f ./*.c ./*.h ./*.cpp ./*.hh

# clear: clean
# 	rm -f ./*.run

# test:
# 	./$(RUNNER) < ../testes.txt