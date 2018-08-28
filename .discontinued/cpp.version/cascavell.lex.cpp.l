%{
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cwchar>
#include <string>
#include <iostream> // std::cout
#include <fstream>  // std::ifstream
#include <iomanip>  // Formatacao de entrada e saida

/* http://www.kylheku.com/cgit/txr/tree/parser.l */

using namespace std;

/* enum para comportar todos os tokens da linguagem*/
enum KEY\
{
    KEY_OTHERWISE = -1,
    KET_BLANK=1,
    KEY_ERROR,
    KEY_COMMENT,
    KEY_RESERVED_WORD,
    KEY_ID,
    KEY_INTEGER,
    KEY_NOT_ID,
    KEY_DIACRITICO,
};

string keyWords[]=
{
    "void",
    "if",
    "else",
    "int",
    "double",
    "float",
    "char",
    "bool",
    "while",
    "return"
};

/*contadores para usar identacao como marcador*/
int lineNo = 0, blankCount = 0, lWhiteSpaces = 0, dedent = 0;


string getMessage(int k);

bool palavraReservada(string word);

%}

%option noyywrap

vazio [[:blank:]]+
diacritico [\xC0-\xD6\xD8-\xDD\xE0-\xF5\xF8-\xFD\xFF]
alpha ([[:alpha:]]|{diacritico})
alphanum ({alpha}|[[:digit:]])
di ([[:digit:]])+(_|{alphanum})+
inteiro ([[:digit:]])+
id ({alpha}|_)(_|{alphanum})*

    /*ASC     [\x00-\x7f]*/
    /*ASCN    [\x00-\t\v-\x7f]*/
    /*U       [\x80-\xbf]*/
    /*U2      [\xc2-\xdf]*/
    /*U3      [\xe0-\xef]*/
    /*U4      [\xf0-\xf4]*/

    /*UANY    {ASC}|{U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U}*/      /*The UANY means match any character, single-byte ASCII or multi-byte UTF-8*/
    /*UANYN   {ASCN}|{U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U}*/     /*UANYN means like UANY but no not match the newline*/ 
    /*UONLY   {U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U}*/            /*UONLY means match only a UTF-8 extended character, not an ASCII one*/


    /*
    \n  {blankCount = 0;}

    .{ int i;
        if( blankCount > lWhiteSpaces )
            printf("> indent >\n");
        else if( blankCount < lWhiteSpaces )
            for( i = 0; i < lWhiteSpaces - blankCount; i++ )
                printf("< dedent <\n");
        else
            printf("=        =\n");

        lWhiteSpaces = blankCount; blankCount = 0;
    }
    */

%%

"\/\/"(.)*/(\n)         {return KEY_COMMENT;}
"\/*"([^"*\/"])*"*\/"   {return KEY_COMMENT;}
{vazio}                 {blankCount++;}
{di}                    {return KEY_NOT_ID;}
{id}                    {return palavraReservada(yyFlexLexer::YYText())?KEY_RESERVED_WORD:KEY_ID;}
{inteiro}               {return KEY_INTEGER;}
.|\n                    {;}

%%
/*codigo do usuario*/

int main(const int argc, const char *argv[ ])
{
    /*yyin = fopen(argv[1], "r");*/
    
    ifstream inFile;
    ofstream outFile, logFile;
    if(argc >= 2)
    {
        string aux(argv[1]);
        inFile.open(aux, ios::in);
        logFile.open(aux.substr( 0, aux.find_last_of(".") + 1 ).append("cpp.log"),ios::out);
        if(argc >= 3) outFile.open(argv[2], ios::out);
    }
    ostream &logger = (argc >= 2) ? logFile : clog;
    yyFlexLexer lex((argc >= 2) ? inFile : cin, (argc >= 3) ? outFile : cout);

     while(int key = lex.yylex())
     {
         logger << setw(18) << setfill(' ') << left << (getMessage(key)) << ": " << lex.YYText() << endl;
     }
    
    logger << blankCount << " espaços em branco" << endl;
    cerr << "Done" << '\a' << endl;
    return 0;
}

bool palavraReservada(string word)
{
    for (auto i : keyWords)
    {
        if (word.compare(i) == 0) return true;
    }
    return false;
}

string getMessage(int k)
{
    string ret;
    switch(k)
    {
        case KEY_ERROR:           ret = "Erro"; break;
        case KEY_COMMENT:         ret = "Comentario"; break;
        case KEY_RESERVED_WORD:   ret = "Palavra reservada"; break;
        case KEY_ID:              ret = "ID generico"; break;
        case KEY_INTEGER:         ret = "Valor numerico"; break;
        case KEY_NOT_ID:          ret = "ID estranho"; break;
        case KEY_DIACRITICO:      ret = "Um diacritico"; break;
        default:                  ret = "Desconhecido"; break;
    }
    return ret;
}
