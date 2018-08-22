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
entrada:      cmd {treeRoot = $1; }/* vazia */
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
            | KEY_RESERVED_WORD_BOOL  id
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

cmd:          action KEY_LINEBREAK otherCmd
                {
                    $$ = newExpressionNode(_Command);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;

                }
            ;

otherCmd:     /* A = Lambda */
                {
                    $$ = NULL;
                }
            | cmd 
                {
                    $$ = $1;;
                }
            ;

action:       operation     {$$ = $1;}
            | conditional   {$$ = $1;}
            | repetition    {$$ = $1;}
            | returning     {$$ = $1;}
            | declaration   {$$ = $1;}
            ;


operation:    assigner      {$$ = $1;}
            ;

assigner:     ternary {$$ = $1;} /* A = B */
            | assigner KEY_EQUAL ternary
                {
                    $$ = newStatementNode(_Assign);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                ; }
            ;

ternary:      logicOr {$$ = $1;} /* A = B */
            | logicOr KEY_INTERROGATION ternary KEY_COLON ternary
            {
                $$ = newExpressionNode(_Operation);
                $$ -> subNode[0] = $1;
                $$ -> subNode[1] = $3;
                $$ -> subNode[2] = $5;
                $$ -> about.oper = KEY_INTERROGATION;
            } /* A = B ? A:    A */
            ;

logicOr:      logicAnd {$$ = $1;} /* A = B */
            | logicOr KEY_OR logicAnd
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_OR;
                }  /* a || b */
            ;

logicAnd:     bitwiseOr {$$ = $1;} /* A = B */
            | logicAnd KEY_AND bitwiseOr
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_AND;
                }  /* a && b */
            ;

bitwiseOr:    bitwiseXor {$$ = $1;} /* A = B */
            | bitwiseOr KEY_PIPE bitwiseXor
            {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_PIPE;
            } /* a | b */
            ;

bitwiseXor:   bitwiseAnd {$$ = $1;} /* A = B */
            | bitwiseXor KEY_CARET bitwiseAnd
            {    
                $$ = newExpressionNode(_Operation);
                $$ -> subNode[0] = $1;
                $$ -> subNode[1] = $3;
                $$ -> about.oper = KEY_CARET;
            } /* ^a */
            ;

bitwiseAnd:   relatEqual {$$ = $1;} /* A = B */
            | bitwiseAnd KEY_AMPERSAND bitwiseAnd 
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_AMPERSAND;
                } /* a & b */
            ;

relatEqual:   relatOrder {$$ = $1;} /* A = B */
            | relatEqual KEY_IS_EQUAL relatOrder
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_IS_EQUAL;
                }  /* a == b */
            | relatEqual KEY_IS_NOT_EQUAL relatOrder
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_IS_NOT_EQUAL;
                }  /* a != b */
            ;
            

relatOrder:   plusMinus {$$ = $1;} /* A = B */
            | relatOrder KEY_LESSER_EQUAL plusMinus 
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_LESSER_EQUAL;
                } /* a <= b */
            | relatOrder KEY_GREATER_EQUAL plusMinus 
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_GREATER_EQUAL;
                } /* a >= b */
            | relatOrder KEY_LESSER plusMinus 
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_LESSER;
                } /* a < b */
            | relatOrder KEY_GREATER plusMinus 
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_GREATER;
                } /* a > b */
            ;

plusMinus:    multDiv {$$ = $1;} /* A = B */
            | plusMinus KEY_PLUS    multDiv 
            {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_PLUS;
            } /* A = A + B */
            | plusMinus KEY_MINUS   multDiv 
            {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_MINUS;
            } /* A = A - B */
            ;

multDiv:      logicNot {$$ = $1;} /* A = B */
            | multDiv KEY_ASTERISK  logicNot
            {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_ASTERISK;    
            } /* A = A * B */
            | multDiv KEY_SLASH     logicNot
            {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_SLASH;    
            } /* A = A / B */
            | multDiv KEY_PERCENT   logicNot
            {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $1;
                    $$ -> subNode[1] = $3;
                    $$ -> about.oper = KEY_PERCENT;    
            } /* A = A % B */
            ;

logicNot:     negPos {$$ = $1;} /* A = B */
            | KEY_EXCLAMATION negPos 
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $2;
                    $$ -> about.oper = KEY_EXCLAMATION;   
                } /* !a */
            | KEY_TILDE negPos 
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $2;
                    $$ -> about.oper = KEY_TILDE;   
                } /* ~a */
            ;

negPos:       paren {$$ = $1;} /* A = B */
            | KEY_PLUS negPos 
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $2;
                    $$ -> about.oper = KEY_PERCENT;   
                } /* A = +A */
            | KEY_MINUS  negPos 
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $2;
                    $$ -> about.oper = KEY_PERCENT;   
                } /* A = -A */
            ;

paren:        id {$$ = $1;} /* A = a */
            | KEY_BRACKET_R_L operation KEY_BRACKET_R_R
                {
                    $$ = newExpressionNode(_Operation);
                    $$ -> subNode[0] = $2;
                    $$ -> about.oper = KEY_BRACKET_R_L;   
                } /* A=(B) */
            ;


id:           KEY_ID
                {
                    $$ = newExpressionNode(_Id);
                    $$ ->about.declName = yytext;
                }
            | KEY_INTEGER
                {
                    $$ = newExpressionNode(_Literal);
                    $$ -> about.literal = yytext;
                }
            | KEY_REAL
                {
                    $$ = newExpressionNode(_Literal);
                    $$ -> about.literal = yytext;
                }
            | KEY_RESERVED_WORD_TRUE
                {
                    $$ = NULL; 
                }   /* True */
            | KEY_RESERVED_WORD_FALSE
                {
                    $$ = NULL; 
                }  /* False */
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
