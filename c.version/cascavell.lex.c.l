%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


enum KEY\
{
    KEY_OTHERWISE = -1,
    KEY_BLANK=1,
    KEY_ERROR,
    KEY_COMMENT,
    KEY_ID,
    KEY_INTEGER,
    KEY_REAL,
    KEY_NOT_ID,
    KEY_DIACRITICO,
    KEY_EQUAL,
    KEY_PLUS,
    KEY_MINUS,
    KEY_ASTERISK,
    KEY_SLASH,
    KEY_CARET,
    KEY_COLON,
    KEY_INTERROGATION, 
    KEY_BRACKET_R_L,
    KEY_BRACKET_R_R,
    KEY_BRACKET_B_L,
    KEY_BRACKET_B_R,
    KEY_BRACKET_C_L,
    KEY_BRACKET_C_R,
    KEY_BRACKET_A_L,
    KEY_BRACKET_A_R,
    KEY_PERCENT,
    KEY_PIPE,
    KEY_LINEBREAK,
    KEY_RESERVED_WORD_VOID,
    KEY_RESERVED_WORD_IF,
    KEY_RESERVED_WORD_ELSE,
    KEY_RESERVED_WORD_INT,
    KEY_RESERVED_WORD_DOUBLE,
    KEY_RESERVED_WORD_FLOAT,
    KEY_RESERVED_WORD_CHAR,
    KEY_RESERVED_WORD_BOOL,
    KEY_RESERVED_WORD_WHILE,
    KEY_RESERVED_WORD_RETURN,
};

/*contadores para usar identacao como marcador*/
int blankCount = 0;
int identation = 0;
int yycolumnno = 0;
int lastThingS = 0;

#define BUFFER_SIZE 50
char buffer[BUFFER_SIZE];

const char * getMessage(int codigo);

#define COMPACTER { yycolumnno += lastThingS; lastThingS = strlen(yytext); }

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

"\/\/"(.)*/(\n)         { return KEY_COMMENT; }
"\/*"([^"*\/"])*"*\/"   { return KEY_COMMENT; }
^{vazio}*\n             { ; }
^{vazio}*               { yycolumnno = identation = strlen(yytext); return KEY_BLANK; }
{vazio}                 { blankCount++; yycolumnno++; }
"void"                  { COMPACTER; return KEY_RESERVED_WORD_VOID; }
"if"                    { COMPACTER; return KEY_RESERVED_WORD_IF; }
"else"                  { COMPACTER; return KEY_RESERVED_WORD_ELSE; }
"int"                   { COMPACTER; return KEY_RESERVED_WORD_INT; }
"double"                { COMPACTER; return KEY_RESERVED_WORD_DOUBLE; }
"float"                 { COMPACTER; return KEY_RESERVED_WORD_FLOAT; }
"char"                  { COMPACTER; return KEY_RESERVED_WORD_CHAR; }
"bool"                  { COMPACTER; return KEY_RESERVED_WORD_BOOL; }
"while"                 { COMPACTER; return KEY_RESERVED_WORD_WHILE; }
"return"                { COMPACTER; return KEY_RESERVED_WORD_RETURN; }
{di}                    { COMPACTER; return KEY_NOT_ID; }
{inteiro}               { COMPACTER; return KEY_INTEGER; }
{real}                  { COMPACTER; return KEY_REAL; }
{id}                    { COMPACTER; return KEY_ID; }
"="                     { COMPACTER; return KEY_EQUAL; }
"+"                     { COMPACTER; return KEY_PLUS; }
"-"                     { COMPACTER; return KEY_MINUS; }
"*"                     { COMPACTER; return KEY_ASTERISK; }
"/"                     { COMPACTER; return KEY_SLASH; }
"^"                     { COMPACTER; return KEY_CARET; }
"%"                     { COMPACTER; return KEY_PERCENT; }
"|"                     { COMPACTER; return KEY_PIPE; }
":"                     { COMPACTER; return KEY_COLON; }
"?"                     { COMPACTER; return KEY_INTERROGATION; }
"("                     { COMPACTER; return KEY_BRACKET_R_L; }
")"                     { COMPACTER; return KEY_BRACKET_R_R; }
"["                     { COMPACTER; return KEY_BRACKET_B_L; }
"]"                     { COMPACTER; return KEY_BRACKET_B_R; }
"{"                     { COMPACTER; return KEY_BRACKET_C_L; }
"}"                     { COMPACTER; return KEY_BRACKET_C_R; }
"<"                     { COMPACTER; return KEY_BRACKET_A_L; }
">"                     { COMPACTER; return KEY_BRACKET_A_R; }
\n                      { yycolumnno = 0; identation = 0; return KEY_LINEBREAK; }
.                       {;}



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


    int codigo;
    while(codigo = yylex())
    {

        fprintf(logger ,"linha: %3d, coluna: %3d, %-30s - `%s\'\n", yylineno, yycolumnno, getMessage(codigo), codigo == KEY_LINEBREAK ? "\\n" : yytext);
    }
    fprintf(logger ,"%d espaços em branco\n", blankCount);
    fprintf(stderr, "Done\a\n");
    return 0;
}

const char * getMessage(int codigo)
{
    memset(buffer, '\0' ,BUFFER_SIZE);
    switch(codigo)
    {
        case KEY_ERROR:                 sprintf(buffer, "Erro");                      break;
        case KEY_BLANK:                 sprintf(buffer, "Tabulado: %d#", identation); break;
        case KEY_COMMENT:               sprintf(buffer, "Comentario");                break;
        case KEY_ID:                    sprintf(buffer, "ID generico");               break;
        case KEY_INTEGER:               sprintf(buffer, "Valor numerico");            break;
        case KEY_NOT_ID:                sprintf(buffer, "ID estranho");               break;
        case KEY_DIACRITICO:            sprintf(buffer, "Um diacritico");             break;
        case KEY_EQUAL:                 sprintf(buffer, "Simbolo: Igual");            break;
        case KEY_PLUS:                  sprintf(buffer, "Simbolo: Mais");             break;
        case KEY_MINUS:                 sprintf(buffer, "Simbolo: Menos");            break;
        case KEY_ASTERISK:              sprintf(buffer, "Simbolo: Asterisco");        break;
        case KEY_SLASH:                 sprintf(buffer, "Simbolo: Barra");            break;
        case KEY_CARET:                 sprintf(buffer, "Simbolo: Circunflexo");      break;
        case KEY_PERCENT:               sprintf(buffer, "Simbolo: Porcentagem");      break;
        case KEY_PIPE:                  sprintf(buffer, "Simbolo: Pipe");             break;
        case KEY_COLON:                 sprintf(buffer, "Simbolo: Dois pontos");      break;
        case KEY_INTERROGATION:         sprintf(buffer, "Simbolo: Interrogacao");     break;
        case KEY_BRACKET_R_L:           sprintf(buffer, "Abre Parenteses");           break;
        case KEY_BRACKET_R_R:           sprintf(buffer, "Fecha Parenteses");          break;
        case KEY_BRACKET_B_L:           sprintf(buffer, "Abre Chaves");               break;
        case KEY_BRACKET_B_R:           sprintf(buffer, "Fecha Chaves");              break;
        case KEY_BRACKET_C_L:           sprintf(buffer, "Abre Colchetes");            break;
        case KEY_BRACKET_C_R:           sprintf(buffer, "Fecha Colchetes");           break;
        case KEY_BRACKET_A_L:           sprintf(buffer, "Abre Angulos");              break;
        case KEY_BRACKET_A_R:           sprintf(buffer, "Fecha Angulos");             break;
        case KEY_LINEBREAK:             sprintf(buffer, "Quebra de linha");           break;
        case KEY_RESERVED_WORD_VOID:    sprintf(buffer, "Palavra chave:");            break;                  
        case KEY_RESERVED_WORD_IF:      sprintf(buffer, "Palavra chave:");            break;                    
        case KEY_RESERVED_WORD_ELSE:    sprintf(buffer, "Palavra chave:");            break;                  
        case KEY_RESERVED_WORD_INT:     sprintf(buffer, "Palavra chave:");            break;                   
        case KEY_RESERVED_WORD_DOUBLE:  sprintf(buffer, "Palavra chave:");            break;                
        case KEY_RESERVED_WORD_FLOAT:   sprintf(buffer, "Palavra chave:");            break;                 
        case KEY_RESERVED_WORD_CHAR:    sprintf(buffer, "Palavra chave:");            break;                  
        case KEY_RESERVED_WORD_BOOL:    sprintf(buffer, "Palavra chave:");            break;                  
        case KEY_RESERVED_WORD_WHILE:   sprintf(buffer, "Palavra chave:");            break;                 
        case KEY_RESERVED_WORD_RETURN:  sprintf(buffer, "Palavra chave:");            break;                
        default:                        sprintf(buffer, "Desconhecido");              break;
    }
    return buffer;
}
