%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


enum KEY\
{
    KEY_OTHERWISE = -1,
    KET_BLANK=1,
    KEY_ERROR,
    KEY_COMMENT,
    KEY_ID,
    KEY_INTEGER,
    KEY_REAL,
    KEY_NOT_ID,
    KEY_DIACRITICO,
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

"\/\/"(.)*/(\n)         { return KEY_COMMENT;}
"\/*"([^"*\/"])*"*\/"   { return KEY_COMMENT;}
{vazio}                 { blankCount++;}
{di}                    { return KEY_NOT_ID;}
{inteiro}               { return KEY_INTEGER;}
{real}                  { return KEY_REAL;}
{id}                    { return palavraReservada(yytext) ? KEY_RESERVED_WORD : KEY_ID;}
.|\n                    {;}



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
        fprintf(logger ,"%-25s - %s\n",getMessage(codigo), yytext);
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
        case KEY_ERROR:           sprintf(buffer, "Erro");              break;
        case KEY_COMMENT:         sprintf(buffer, "Comentario");        break;
        case KEY_ID:              sprintf(buffer, "ID generico");       break;
        case KEY_INTEGER:         sprintf(buffer, "Valor numerico");    break;
        case KEY_NOT_ID:          sprintf(buffer, "ID estranho");       break;
        case KEY_DIACRITICO:      sprintf(buffer, "Um diacritico");     break;
        default:                  sprintf(buffer, "Desconhecido");      break;
    }
    return buffer;
}
