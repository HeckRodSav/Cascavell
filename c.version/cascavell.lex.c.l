%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stack.h"

enum KEY\
{
    KEY_ERROR,
    KEY_ID,
    KEY_INTEGER,
    KEY_REAL,
    KEY_EQUAL,
    KEY_PLUS,
    KEY_MINUS,
    KEY_ASTERISK,
    KEY_SLASH,
    KEY_CARET,
    KEY_TILDE,
    KEY_COMMA,
    KEY_COLON,
    KEY_INTERROGATION,
    KEY_EXCLAMATION,
    KEY_BRACKET_R_L,
    KEY_BRACKET_R_R,
    KEY_BRACKET_B_L,
    KEY_BRACKET_B_R,
    KEY_BRACKET_C_L,
    KEY_BRACKET_C_R,
    KEY_LESSER,
    KEY_GREATER,
    KEY_PERCENT,
    KEY_PIPE,
    KEY_AMPERSAND,
    KEY_LINEBREAK,
    KEY_RESERVED_WORD_VOID,
    KEY_RESERVED_WORD_IF,
    KEY_RESERVED_WORD_ELSE,
    KEY_RESERVED_WORD_INT,
    KEY_RESERVED_WORD_DOUBLE,
    KEY_RESERVED_WORD_CHAR,
    KEY_RESERVED_WORD_BOOL,
    KEY_RESERVED_WORD_WHILE,
    KEY_RESERVED_WORD_RETURN,
    KEY_MORE_IDENTATION,
    KEY_LESS_IDENTATION,
};

/*contadores para usar identacao como marcador*/
int blankCount = 0;
int identation = 0;
int lastIdent = 0;
int yycolumnno = 0;
int lastTkSize = 0;

#define BUFFER_SIZE 50
char buffer[BUFFER_SIZE];

Stack tabulationStack;

void getMessage(int codigo);

#define COMPACTER { yycolumnno += lastTkSize; lastTkSize = strlen(yytext); }

%}

%option noyywrap
%option yylineno

vazio [[:blank:]]+
diacritico [\xC0-\xD6\xD8-\xDD\xE0-\xF5\xF8-\xFD\xFF]
alpha ([[:alpha:]]|{diacritico})
alphanum ({alpha}|[[:digit:]])
di ([[:digit:]])+(_|{alphanum})+
inteiro ([[:digit:]])+
exponente [eE][+-]?{inteiro}
real {inteiro}("."{inteiro})?{exponente}?
id ({alpha}|_)(_|{alphanum})*

%%

"\/\/"(.)*/(\n)         { ; }
"\/*"([^"*\/"])*"*\/"   { ; }
^{vazio}*\n             { ; }
^{vazio}*               {
                            lastIdent = stack_top(&tabulationStack);
                            yycolumnno = identation = strlen(yytext);
                            if(lastIdent == identation);
                            else if(lastIdent < identation)                           
                            {
                                if(stack_isFull(&tabulationStack)) return KEY_ERROR;
                                stack_push(&tabulationStack, identation);
                                return KEY_MORE_IDENTATION;
                            }
                            else if(lastIdent > identation)                           
                            {
                                if(stack_isEmpty(&tabulationStack)) return KEY_ERROR;
                                stack_pop(&tabulationStack);
                                return KEY_LESS_IDENTATION;
                            }
                        }
{vazio}                 { blankCount++; yycolumnno++; }
"void"                  { COMPACTER; return KEY_RESERVED_WORD_VOID; }
"if"                    { COMPACTER; return KEY_RESERVED_WORD_IF; }
"else"                  { COMPACTER; return KEY_RESERVED_WORD_ELSE; }
"int"                   { COMPACTER; return KEY_RESERVED_WORD_INT; }
"double"                { COMPACTER; return KEY_RESERVED_WORD_DOUBLE; }
"char"                  { COMPACTER; return KEY_RESERVED_WORD_CHAR; }
"bool"                  { COMPACTER; return KEY_RESERVED_WORD_BOOL; }
"while"                 { COMPACTER; return KEY_RESERVED_WORD_WHILE; }
"return"                { COMPACTER; return KEY_RESERVED_WORD_RETURN; }
^"end"                  { 
                            COMPACTER;
                            lastIdent = stack_top(&tabulationStack);
                            if(lastIdent > identation)                           
                            {
                                if(stack_isEmpty(&tabulationStack)) return KEY_ERROR;
                                stack_pop(&tabulationStack);
                                return KEY_LESS_IDENTATION;
                            }
                            return KEY_ERROR;
                        }
"end"                   {
                            COMPACTER;
                            if(identation == lastIdent) return KEY_ERROR;
                        }
"=="                    { COMPACTER; return KEY_IS_EQUAL; }
"!="                    { COMPACTER; return KEY_IS_NOT_EQUAL; }
"<="                    { COMPACTER; return KEY_LESSER_EQUAL; }
">="                    { COMPACTER; return KEY_GREATER_EQUAL; }
"="                     { COMPACTER; return KEY_EQUAL; }
"<"                     { COMPACTER; return KEY_LESSER; }
">"                     { COMPACTER; return KEY_GREATER; }
"+"                     { COMPACTER; return KEY_PLUS; }
"-"                     { COMPACTER; return KEY_MINUS; }
"*"                     { COMPACTER; return KEY_ASTERISK; }
"/"                     { COMPACTER; return KEY_SLASH; }
"^"                     { COMPACTER; return KEY_CARET; }
"~"                     { COMPACTER; return KEY_TILDE; }
"%"                     { COMPACTER; return KEY_PERCENT; }
"|"                     { COMPACTER; return KEY_PIPE; }
"&"                     { COMPACTER; return KEY_AMPERSAND; }
","                     { COMPACTER; return KEY_COMMA; }
":"                     { COMPACTER; return KEY_COLON; }
"?"                     { COMPACTER; return KEY_INTERROGATION; }
"!"                     { COMPACTER; return KEY_EXCLAMATION; } 
"("                     { COMPACTER; return KEY_BRACKET_R_L; }
")"                     { COMPACTER; return KEY_BRACKET_R_R; }
"["                     { COMPACTER; return KEY_BRACKET_B_L; }
"]"                     { COMPACTER; return KEY_BRACKET_B_R; }
"{"                     { COMPACTER; return KEY_BRACKET_C_L; }
"}"                     { COMPACTER; return KEY_BRACKET_C_R; }
{di}                    { COMPACTER; return KEY_ERROR; }
{inteiro}               { COMPACTER; return KEY_INTEGER; }
{real}                  { COMPACTER; return KEY_REAL; }
{id}                    { COMPACTER; return KEY_ID; }
\n                      { yycolumnno = 0; identation = 0; return KEY_LINEBREAK; }
.                       { ; }



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
    while(codigo = yylex())
    {
        getMessage(codigo);
        fprintf(logger ,"ln: %3d, col: %3d, %-30s - `%s\'\n", yylineno, yycolumnno, buffer, codigo == KEY_LINEBREAK ? "\\n" : yytext);
    }
    fprintf(logger ,"%d espaços em branco\n", blankCount);
    fprintf(stderr, "Done\a\n");
    return 0;
}

void getMessage(int codigo)
{
    memset(buffer, '\0' ,BUFFER_SIZE);
    switch(codigo)
    {
        case KEY_ERROR:                 sprintf(buffer, "Erro");                             break;
        case KEY_RESERVED_WORD_VOID:    sprintf(buffer, "Palavra chave:");                   break;
        case KEY_RESERVED_WORD_IF:      sprintf(buffer, "Palavra chave:");                   break;
        case KEY_RESERVED_WORD_ELSE:    sprintf(buffer, "Palavra chave:");                   break;
        case KEY_RESERVED_WORD_INT:     sprintf(buffer, "Palavra chave:");                   break;
        case KEY_RESERVED_WORD_DOUBLE:  sprintf(buffer, "Palavra chave:");                   break;
        case KEY_RESERVED_WORD_CHAR:    sprintf(buffer, "Palavra chave:");                   break;
        case KEY_RESERVED_WORD_BOOL:    sprintf(buffer, "Palavra chave:");                   break;
        case KEY_RESERVED_WORD_WHILE:   sprintf(buffer, "Palavra chave:");                   break;
        case KEY_RESERVED_WORD_RETURN:  sprintf(buffer, "Palavra chave:");                   break;
        case KEY_INTEGER:               sprintf(buffer, "Valor inteiro");                    break;
        case KEY_REAL:                  sprintf(buffer, "Valor real");                       break;
        case KEY_ID:                    sprintf(buffer, "ID generico");                      break;
        case KEY_EQUAL:                 sprintf(buffer, "Simbolo: Igual");                   break;
        case KEY_PLUS:                  sprintf(buffer, "Simbolo: Mais");                    break;
        case KEY_MINUS:                 sprintf(buffer, "Simbolo: Menos");                   break;
        case KEY_ASTERISK:              sprintf(buffer, "Simbolo: Asterisco");               break;
        case KEY_SLASH:                 sprintf(buffer, "Simbolo: Barra");                   break;
        case KEY_CARET:                 sprintf(buffer, "Simbolo: Circunflexo");             break;
        case KEY_TILDE:                 sprintf(buffer, "Simbolo: Til");                     break;
        case KEY_PERCENT:               sprintf(buffer, "Simbolo: Porcentagem");             break;
        case KEY_PIPE:                  sprintf(buffer, "Simbolo: Pipe");                    break;
        case KEY_AMPERSAND:             sprintf(buffer, "Simbolo: Ampersand");               break;
        case KEY_COLON:                 sprintf(buffer, "Simbolo: Dois pontos");             break;
        case KEY_COMMA:                 sprintf(buffer, "Simbolo: Virgula");                 break;
        case KEY_INTERROGATION:         sprintf(buffer, "Simbolo: Interrogacao");            break;
        case KEY_EXCLAMATION:           sprintf(buffer, "Simbolo: Exclamacao");              break;
        case KEY_BRACKET_R_L:           sprintf(buffer, "Abre Parenteses");                  break;
        case KEY_BRACKET_R_R:           sprintf(buffer, "Fecha Parenteses");                 break;
        case KEY_BRACKET_B_L:           sprintf(buffer, "Abre Chaves");                      break;
        case KEY_BRACKET_B_R:           sprintf(buffer, "Fecha Chaves");                     break;
        case KEY_BRACKET_C_L:           sprintf(buffer, "Abre Colchetes");                   break;
        case KEY_BRACKET_C_R:           sprintf(buffer, "Fecha Colchetes");                  break;
        case KEY_LESSER:           sprintf(buffer, "Abre Angulos");                     break;
        case KEY_GREATER:           sprintf(buffer, "Fecha Angulos");                    break;
        case KEY_LINEBREAK:             sprintf(buffer, "Quebra de linha");                  break;
        case KEY_MORE_IDENTATION:       sprintf(buffer, "Inicio de bloco: #%d -> #%d", lastIdent, identation); break;
        case KEY_LESS_IDENTATION:       sprintf(buffer, "Fim de bloco: #%d -> #%d", lastIdent, identation);     break;
        default:                        sprintf(buffer, "Desconhecido");                     break;
    }
}
