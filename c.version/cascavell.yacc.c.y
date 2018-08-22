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

#define YYSTYPE TreeNode*

void yyerror(char *);
extern int yylex();
extern int yylineno, yycolumnno;
extern char* yytext;
extern FILE *yyin;
extern FILE *yyout;
FILE *logger;

extern char buffer[];
extern int blankCount;
extern int identation;
extern int lastIdent;
extern int lastTkSize;

extern Stack tabulationStack;

TreeNode* treeRoot;

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
%token    KEY_RESERVED_WORD_VOID    KEY_RESERVED_WORD_IF    KEY_RESERVED_WORD_ELSE    KEY_RESERVED_WORD_INT    KEY_RESERVED_WORD_DOUBLE    KEY_RESERVED_WORD_FLOAT    KEY_RESERVED_WORD_CHAR    KEY_RESERVED_WORD_BOOL    KEY_RESERVED_WORD_WHILE    KEY_RESERVED_WORD_RETURN    KEY_RESERVED_WORD_TRUE    KEY_RESERVED_WORD_FALSE


%%
entrada:      cmdBlock {treeRoot = $1; }/* vazia */
            ;

declaration:  KEY_RESERVED_WORD_INT     id
                {
                    $$ = newDeclarationNode(__Int);
                    $$ -> subNode[0] = $2;
                }
            | KEY_RESERVED_WORD_DOUBLE  id
                {
                    $$ = newDeclarationNode(__Double);
                    $$ -> subNode[0] = $2;
                }
            | KEY_RESERVED_WORD_CHAR    id
                {
                    $$ = newDeclarationNode(__Char);
                    $$ -> subNode[0] = $2;
                }
            | KEY_RESERVED_WORD_DOUBLE  id
                {
                    $$ = newDeclarationNode(__Bool);
                    $$ -> subNode[0] = $2;
                }
            ;

conditional:  KEY_RESERVED_WORD_IF operation KEY_COLON cmdBlock elser 
                {
                    $$ = newStatementNode(_If);
                    $$ -> subNode[0] = $2;
                    $$ -> subNode[1] = $4;
                    $$ -> subNode[2] = $5;
                }
            ;

elser:        /* Lambda */
                {
                    $$ = NULL;
                }
            | KEY_RESERVED_WORD_ELSE cmdBlock
                {
                    $$ = newStatementNode(_Else);
                    $$ -> subNode[0] = $2;
                }
            ;

repetition:   KEY_RESERVED_WORD_WHILE operation KEY_COLON cmdBlock
                {
                    $$ = newStatementNode(_While);
                    $$ -> subNode[0] = $2;
                    $$ -> subNode[1] = $4;
                }
            ;

returning:    KEY_RESERVED_WORD_RETURN operation
                {
                    $$ = newStatementNode(_Return);
                    $$ -> subNode[0] = $2;
                }
            ;

cmdBlock:     KEY_MORE_IDENTATION cmd KEY_LESS_IDENTATION
                {
                    $$ = newExpressionNode(_Block);
                    $$ -> subNode[0] = $2;
                }
            ;

cmd:          action KEY_LINEBREAK otherCmd { $$ = NULL; }
                {
                    $$ = newExpressionNode(_Command);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;

                }
            | conditional { $$ = NULL; }
            ;

otherCmd:     /* A = Lambda */
                {
                    $$ = NULL;
                }
            | cmd 
                {
                    $$ = $1;
                }
            ;

action:       operation
            | conditional
            | repetition
            | returning
            | declaration
            ;


operation:    assigner { $$ = $1; }
            ;

assigner:     ternary { $$ = NULL; } /* A = B */
            | assigner KEY_EQUAL ternary { $$ = NULL; }
            ;

ternary:      logicOr { $$ = NULL; } /* A = B */
            | logicOr KEY_INTERROGATION ternary KEY_COLON ternary { $$ = NULL; } /* A = B ? A:    A */
            ;

logicOr:      logicAnd { $$ = NULL; } /* A = B */
            | logicOr KEY_OR logicAnd { $$ = NULL; }  /* a || b */
            ;

logicAnd:     bitwiseOr { $$ = NULL; } /* A = B */
            | logicAnd KEY_AND bitwiseOr { $$ = NULL; }  /* a && b */
            ;

bitwiseOr:    bitwiseXor { $$ = NULL; } /* A = B */
            | KEY_PIPE bitwiseOr { $$ = NULL; } /* a | b */
            ;

bitwiseXor:   bitwiseAnd { $$ = NULL; } /* A = B */
            | KEY_CARET bitwiseXor { $$ = NULL; } /* ^a */
            ;

bitwiseAnd:   relatEqual { $$ = NULL; } /* A = B */
            | KEY_AMPERSAND bitwiseAnd { $$ = NULL; } /* a & b */
            ;

relatEqual:   relatOrder { $$ = NULL; } /* A = B */
            | relatEqual KEY_IS_EQUAL relatOrder { $$ = NULL; }  /* a == b */
            | relatEqual KEY_IS_NOT_EQUAL relatOrder { $$ = NULL; }  /* a != b */
            ;
            

relatOrder:   plusMinus { $$ = NULL; } /* A = B */
            | relatOrder KEY_LESSER_EQUAL plusMinus { $$ = NULL; } /* a <= b */
            | relatOrder KEY_GREATER_EQUAL plusMinus { $$ = NULL; } /* a >= b */
            | relatOrder KEY_LESSER plusMinus { $$ = NULL; } /* a < b */
            | relatOrder KEY_GREATER plusMinus { $$ = NULL; } /* a > b */
            ;

plusMinus:    multDiv { $$ = NULL; } /* A = B */
            | plusMinus KEY_PLUS    multDiv { $$ = NULL; } /* A = A + B */
            | plusMinus KEY_MINUS   multDiv { $$ = NULL; } /* A = A - B */
            ;

multDiv:      logicNot { $$ = NULL; } /* A = B */
            | multDiv KEY_ASTERISK  logicNot { $$ = NULL; } /* A = A * B */
            | multDiv KEY_SLASH     logicNot { $$ = NULL; } /* A = A / B */
            | multDiv KEY_PERCENT   logicNot { $$ = NULL; } /* A = A % B */
            ;

logicNot:     negPos { $$ = NULL;} /* A = B */
            | KEY_EXCLAMATION negPos { $$ = NULL; } /* !a */
            | KEY_TILDE negPos { $$ = NULL; } /* ~a */
            ;

negPos:       paren { $$ = NULL; } /* A = B */
            | KEY_PLUS negPos { $$ = NULL; } /* A = +A */
            | KEY_MINUS  negPos { $$ = NULL; } /* A = -A */
            ;

paren:        id { $$ = NULL; } /* A = a */
            | KEY_BRACKET_R_L operation KEY_BRACKET_R_R { $$=NULL; } /* A=(B) */
            ;


id:           KEY_ID
                {
                    $$ = newExpressionNode(_Id);
                    $$ ->about.declName = yytext;
                }
            | KEY_RESERVED_WORD_TRUE { $$ = NULL; }   /* True */
            | KEY_RESERVED_WORD_FALSE { $$ = NULL; }  /* False */
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
    logger = fopen(buffer, "w");

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
