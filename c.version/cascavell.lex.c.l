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
    KEY_RESERVED_WORD,
};

char keyWords[][10]=
{
    {"void"},
    {"if"},
    {"else"},
    {"int"},
    {"double"},
    {"float"},
    {"char"},
    {"bool"},
    {"while"},
    {"return"},
    {'\0'}
};

/*contadores para usar identacao como marcador*/
int lineNo = 0, blankCount = 0, lWhiteSpaces = 0, dedent = 0;
int identation = 0;

#define BUFFER_SIZE 50
char buffer[BUFFER_SIZE];

const char * getMessage(int codigo);

int palavraReservada(char word[]);
%}

%option noyywrap


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
^{vazio}\n              { ; }
^{vazio}                { identation = strlen(yytext); return KEY_BLANK; }
{vazio}                 { blankCount++; }
{di}                    { return KEY_NOT_ID; }
{inteiro}               { return KEY_INTEGER; }
{real}                  { return KEY_REAL; }
{id}                    { return palavraReservada(yytext) ? KEY_RESERVED_WORD : KEY_ID; }
"="                     { return KEY_EQUAL; }
"+"                     { return KEY_PLUS; }
"-"                     { return KEY_MINUS; }
"*"                     { return KEY_ASTERISK; }
"/"                     { return KEY_SLASH; }
"^"                     { return KEY_CARET; }
"%"                     { return KEY_PERCENT; }
"|"                     { return KEY_PIPE; }
"("                     { return KEY_BRACKET_R_L; }
")"                     { return KEY_BRACKET_R_R; }
"["                     { return KEY_BRACKET_B_L; }
"]"                     { return KEY_BRACKET_B_R; }
"{"                     { return KEY_BRACKET_C_L; }
"}"                     { return KEY_BRACKET_C_R; }
"<"                     { return KEY_BRACKET_A_L; }
">"                     { return KEY_BRACKET_A_R; }
\n                      { identation = 0; return KEY_LINEBREAK; }
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

        fprintf(logger ,"%-30s - `%s\'\n",getMessage(codigo), codigo == KEY_LINEBREAK ? "\\n" : yytext);
    }
    fprintf(logger ,"%d espaços em branco\n", blankCount);
    fprintf(stderr, "Done\a\n");
    return 0;
}

int palavraReservada(char word[])
{
    for(int i=0; keyWords[i][0]!='\0'; i++)
        if (!strcmp(word,keyWords[i]))
            return i + KEY_RESERVED_WORD;
}

const char * getMessage(int codigo)
{
    memset(buffer, '\0' ,BUFFER_SIZE);
    if(codigo >= KEY_RESERVED_WORD)
        sprintf(buffer, "Palavra reservada: %s", keyWords[codigo - KEY_RESERVED_WORD]);
    else switch(codigo)
    {
        case KEY_ERROR:           sprintf(buffer, "Erro");                        break;
        case KEY_BLANK:           sprintf(buffer, "Tabulado: %d#", identation);   break;
        case KEY_COMMENT:         sprintf(buffer, "Comentario");                  break;
        case KEY_ID:              sprintf(buffer, "ID generico");                 break;
        case KEY_INTEGER:         sprintf(buffer, "Valor numerico");              break;
        case KEY_NOT_ID:          sprintf(buffer, "ID estranho");                 break;
        case KEY_DIACRITICO:      sprintf(buffer, "Um diacritico");               break;
        case KEY_EQUAL:           sprintf(buffer, "Simbolo: Igual");              break;
        case KEY_PLUS:            sprintf(buffer, "Simbolo: Mais");               break;
        case KEY_MINUS:           sprintf(buffer, "Simbolo: Menos");              break;
        case KEY_ASTERISK:        sprintf(buffer, "Simbolo: Asterisco");          break;
        case KEY_SLASH:           sprintf(buffer, "Simbolo: Barra");              break;
        case KEY_CARET:           sprintf(buffer, "Simbolo: Circunflexo");        break;
        case KEY_PERCENT:         sprintf(buffer, "Simbolo: Porcentagem");        break;
        case KEY_PIPE:            sprintf(buffer, "Simbolo: Pipe");               break;
        case KEY_BRACKET_R_L:     sprintf(buffer, "Abre Parenteses");             break;
        case KEY_BRACKET_R_R:     sprintf(buffer, "Fecha Parenteses");            break;
        case KEY_BRACKET_B_L:     sprintf(buffer, "Abre Chaves");                 break;
        case KEY_BRACKET_B_R:     sprintf(buffer, "Fecha Chaves");                break;
        case KEY_BRACKET_C_L:     sprintf(buffer, "Abre Colchetes");              break;
        case KEY_BRACKET_C_R:     sprintf(buffer, "Fecha Colchetes");             break;
        case KEY_BRACKET_A_L:     sprintf(buffer, "Abre Parenteses Angulares");   break;
        case KEY_BRACKET_A_R:     sprintf(buffer, "Fecha Parenteses Angulares");  break;
        case KEY_LINEBREAK:       sprintf(buffer, "Quebra de linha");             break;
        default:                  sprintf(buffer, "Desconhecido");      break;
    }
    return buffer;
}
