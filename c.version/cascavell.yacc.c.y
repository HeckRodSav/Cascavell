%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "stack.h"
#include "syntaxTree.h"
  
/* na verdade ele adicio ao lexico um código gerado pelo sintatico*/


#ifndef BUFFER_SIZE
#define BUFFER_SIZE 50
#endif

void yyerror(char *);
extern int yylex();
extern int yylineno, yycolumnno;
extern char* yytext;
extern FILE *yyin;
extern FILE *yyout;

extern char buffer[];
extern int blankCount;
extern int identation;
extern int lastIdent;
extern int lastTkSize;

extern Stack tabulationStack;

%}


%start    entrada
%token    KEY_ERROR
%token    KEY_ID    KEY_INTEGER    KEY_REAL
%right    KEY_EQUAL
%left     KEY_IS_EQUAL    KEY_IS_NOT_EQUAL    KEY_LESSER_EQUAL    KEY_GREATER_EQUAL    KEY_LESSER    KEY_GREATER    KEY_OR    KEY_AND
%left     KEY_PLUS    KEY_MINUS
%left     KEY_ASTERISK    KEY_SLASH    KEY_PERCENT
%left     KEY_EXCLAMATION    KEY_CARET    KEY_TILDE    KEY_PIPE    KEY_AMPERSAND    KEY_COMMA
%left     KEY_COLON    KEY_INTERROGATION
%token    KEY_LINEBREAK
%token    KEY_BRACKET_R_L    KEY_BRACKET_R_R    KEY_BRACKET_B_L    KEY_BRACKET_B_R    KEY_BRACKET_C_L    KEY_BRACKET_C_R
%token    KEY_MORE_IDENTATION    KEY_LESS_IDENTATION
%token    KEY_RESERVED_WORD_VOID    KEY_RESERVED_WORD_IF    KEY_RESERVED_WORD_ELSE    KEY_RESERVED_WORD_INT    KEY_RESERVED_WORD_DOUBLE    KEY_RESERVED_WORD_FLOAT    KEY_RESERVED_WORD_CHA   R KEY_RESERVED_WORD_BOOL    KEY_RESERVED_WORD_WHILE    KEY_RESERVED_WORD_RETURN    KEY_RESERVED_WORD_TRUE    KEY_RESERVED_WORD_FALSE


%%
entrada : /* vazia */
        ;

condicional : KEY_RESERVED_WORD_IF logic KEY_COLON cmd elser \
                {
                $$ = newStatementNode(_If);
                $$ -> subNode[0] = $2;
                $$ -> subNode[1] = $4;
                $$ -> subNode[2] = $2;
                }
            ;

elser   :   { $$ = NULL;}
        | KEY_RESERVED_WORD_ELSE cmd \
            {
                $$ = newStatementNode(_Else);
                $$ = subNode[0] = $2;
            }
        ;

aritim : 
       ;  
              
logic : KEY_RESERVED_WORD_TRUE { }   /* True */
      | KEY_RESERVED_WORD_FALSE { }  /* False */
      | logic KEY_IS_EQUAL logic { }  /* == */
      | logic KEY_IS_NOT_EQUAL logic { }  /* != */
      | logic KEY_OR logic { }  /* || */
      | logic KEY_AND logic { }  /* && */
      | logic KEY_AND logic { }  /* && */
      | KEY_BRACKET_R_L logic KEY_BRACKET_R_R { } /* (logic) */
      ;

cmd : /**/
    | KEY_MORE_IDENTATION cmd KEY_LESS_IDENTATION { }
    | cmd KEY_LINEBREAK cmd {}
    | condicional { }
    ;

%%


int main( const int argc, const char *argv[ ])
{
    char localBuff[BUFFER_SIZE] = "Cascavell_Compilation";
    memset(buffer, '\0', BUFFER_SIZE);
    if (argc >= 2)
    {
        yyin  = fopen(argv[1], "r");
        memset(localBuff, '\0', BUFFER_SIZE);
        strncpy ( localBuff, argv[1], strlen(argv[1])-3 );
        if (argc >= 3) yyout = fopen(argv[2], "w");
    }
    sprintf(buffer, "%sc.log", localBuff);
    FILE *logger = fopen(buffer, "w");

    memset(buffer, '\0' ,BUFFER_SIZE);
    int codigo;
    if(!stack_isFull(&tabulationStack)) stack_push(&tabulationStack, 0);
    
    yyparse();

    /*while(codigo = yylex())
    {
        getMessage(codigo);
        fprintf(logger ,"ln: %3d, col: %3d, %-30s - `%s\'\n", yylineno, yycolumnno, buffer, codigo == KEY_LINEBREAK ? "\\n" : yytext);
    }*/

    fprintf(logger ,"%d espaços em branco\n", blankCount);
    fprintf(stderr, "Done\a\n");
    return 0;
}

void yyerror(char *msg)
{
  printf("Erro: <%s>, no simbolo '%s' na linha %d, coluna %d\n", msg, yytext, yylineno, yycolumnno);
}
