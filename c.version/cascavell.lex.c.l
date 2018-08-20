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

const int acceptCode(int codigo);
// const char * getMessage(int codigo);

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

"\/\/"(.)*/(\n)         { sprintf(buffer, "Comentario"); return KEY_COMMENT; }
"\/*"([^"*\/"])*"*\/"   { sprintf(buffer, "Comentario"); return KEY_COMMENT; }
^{vazio}*\n             { ; }
^{vazio}*               { sprintf(buffer, "Tabulado: %d#", identation);  yycolumnno = identation = strlen(yytext); return KEY_BLANK; }
{vazio}                 { blankCount++; yycolumnno++; }
"void"                  { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_VOID; }
"if"                    { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_IF; }
"else"                  { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_ELSE; }
"int"                   { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_INT; }
"double"                { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_DOUBLE; }
"float"                 { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_FLOAT; }
"char"                  { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_CHAR; }
"bool"                  { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_BOOL; }
"while"                 { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_WHILE; }
"return"                { sprintf(buffer, "Palavra chave:");             COMPACTER; return KEY_RESERVED_WORD_RETURN; }
{di}                    { sprintf(buffer, "ID estranho");                COMPACTER; return KEY_NOT_ID; }
{inteiro}               { sprintf(buffer, "Valor inteiro");              COMPACTER; return KEY_INTEGER; }
{real}                  { sprintf(buffer, "Valor real");                 COMPACTER; return KEY_REAL; }
{id}                    { sprintf(buffer, "ID generico");                COMPACTER; return KEY_ID; }
"="                     { sprintf(buffer, "Simbolo: Igual");             COMPACTER; return KEY_EQUAL; }
"+"                     { sprintf(buffer, "Simbolo: Mais");              COMPACTER; return KEY_PLUS; }
"-"                     { sprintf(buffer, "Simbolo: Menos");             COMPACTER; return KEY_MINUS; }
"*"                     { sprintf(buffer, "Simbolo: Asterisco");         COMPACTER; return KEY_ASTERISK; }
"/"                     { sprintf(buffer, "Simbolo: Barra");             COMPACTER; return KEY_SLASH; }
"^"                     { sprintf(buffer, "Simbolo: Circunflexo");       COMPACTER; return KEY_CARET; }
"%"                     { sprintf(buffer, "Simbolo: Porcentagem");       COMPACTER; return KEY_PERCENT; }
"|"                     { sprintf(buffer, "Simbolo: Pipe");              COMPACTER; return KEY_PIPE; }
":"                     { sprintf(buffer, "Simbolo: Dois pontos");       COMPACTER; return KEY_COLON; }
"?"                     { sprintf(buffer, "Simbolo: Interrogacao");      COMPACTER; return KEY_INTERROGATION; }
"("                     { sprintf(buffer, "Abre Parenteses");            COMPACTER; return KEY_BRACKET_R_L; }
")"                     { sprintf(buffer, "Fecha Parenteses");           COMPACTER; return KEY_BRACKET_R_R; }
"["                     { sprintf(buffer, "Abre Chaves");                COMPACTER; return KEY_BRACKET_B_L; }
"]"                     { sprintf(buffer, "Fecha Chaves");               COMPACTER; return KEY_BRACKET_B_R; }
"{"                     { sprintf(buffer, "Abre Colchetes");             COMPACTER; return KEY_BRACKET_C_L; }
"}"                     { sprintf(buffer, "Fecha Colchetes");            COMPACTER; return KEY_BRACKET_C_R; }
"<"                     { sprintf(buffer, "Abre Angulos");               COMPACTER; return KEY_BRACKET_A_L; }
">"                     { sprintf(buffer, "Fecha Angulos");              COMPACTER; return KEY_BRACKET_A_R; }
\n                      { sprintf(buffer, "Quebra de linha");            yycolumnno = 0; identation = 0; return KEY_LINEBREAK; }
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


    memset(buffer, '\0' ,BUFFER_SIZE);
    int codigo;
    while(codigo = yylex())
    {

        // fprintf(logger ,"ln: %3d, col: %3d, %-25s - `%s\'\n", yylineno, yycolumnno, getMessage(codigo), codigo == KEY_LINEBREAK ? "\\n" : codigo == KEY_COMMENT ? "<ignorado>" : yytext);
        switch(acceptCode(codigo))
        {
            case  1: sprintf(buffer, "Desconhecido:"); break;
            case  0: break;
            case -1: sprintf(buffer, "Erro"); break;
            default: sprintf(buffer, "Falha"); break;
        }
        fprintf(logger ,"ln: %3d, col: %3d, %-25s - `%s\'\n", yylineno, yycolumnno, buffer, codigo == KEY_LINEBREAK ? "\\n" : codigo == KEY_COMMENT ? "<ignorado>" : yytext);
        memset(buffer, '\0' ,BUFFER_SIZE);
    }
    fprintf(logger ,"%d espaços em branco\n", blankCount);
    fprintf(stderr, "Done\a\n");
    return 0;
}

const int acceptCode(int codigo)
{
    switch(codigo)
    {
        case KEY_ERROR: return -1;
        case KEY_COMMENT:              
        case KEY_BLANK:                
        case KEY_RESERVED_WORD_VOID:   
        case KEY_RESERVED_WORD_IF:     
        case KEY_RESERVED_WORD_ELSE:   
        case KEY_RESERVED_WORD_INT:    
        case KEY_RESERVED_WORD_DOUBLE: 
        case KEY_RESERVED_WORD_FLOAT:  
        case KEY_RESERVED_WORD_CHAR:   
        case KEY_RESERVED_WORD_BOOL:   
        case KEY_RESERVED_WORD_WHILE:  
        case KEY_RESERVED_WORD_RETURN: 
        case KEY_NOT_ID:               
        case KEY_INTEGER:              
        case KEY_REAL:                 
        case KEY_ID:                   
        case KEY_EQUAL:                
        case KEY_PLUS:                 
        case KEY_MINUS:                
        case KEY_ASTERISK:             
        case KEY_SLASH:                
        case KEY_CARET:                
        case KEY_PERCENT:              
        case KEY_PIPE:                 
        case KEY_COLON:                
        case KEY_INTERROGATION:        
        case KEY_BRACKET_R_L:          
        case KEY_BRACKET_R_R:          
        case KEY_BRACKET_B_L:          
        case KEY_BRACKET_B_R:          
        case KEY_BRACKET_C_L:          
        case KEY_BRACKET_C_R:          
        case KEY_BRACKET_A_L:          
        case KEY_BRACKET_A_R:          
        case KEY_LINEBREAK: return 0;        
        default: return 1;
    }
    return -2;
}

/*const char * getMessage(int codigo)
{
    memset(buffer, '\0' ,BUFFER_SIZE);
    switch(codigo)
    {
        case KEY_ERROR:                 sprintf(buffer, "Erro");                      break;
        case KEY_COMMENT:               sprintf(buffer, "Comentario");                break;
        case KEY_BLANK:                 sprintf(buffer, "Tabulado: %d#", identation); break;
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
        case KEY_NOT_ID:                sprintf(buffer, "ID estranho");               break;
        case KEY_INTEGER:               sprintf(buffer, "Valor inteiro");             break;
        case KEY_REAL:                  sprintf(buffer, "Valor real");                break;
        case KEY_ID:                    sprintf(buffer, "ID generico");               break;
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
        default:                        sprintf(buffer, "Desconhecido");              break;
    }
    return buffer;
}*/
