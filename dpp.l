/*
 * file:  dpp.l
 * ------------
 * Lex inupt file to generate the scanner for the preprocessor.
 * If you decide to use lex for the preprocesor, put your rules
 * here, otherwise the file can remain empty.
 */

%{

#include <string>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"
#include "Map.h"

using namespace std;

struct yyltype yylloc;

void define();
void expand();
ReportError a;
void updatePos();
void countNewLines();
int lineNumber = 1, columnNumber = 1;

Map defines;

%}

%%

\/\/.*                                          updatePos();
(\/\*)([^\*\/]|\*[^\/]|\/)*(\*\/)               updatePos();
(\/\*)([^\*\/]|\*[^\/]|\/)*                     a.UntermComment();
[ ]*\#define[ ][A-Z]+[ ].*                 updatePos(); define();
\#[A-Z]*                                        updatePos(); expand();
[ ]*\#define[ ][^A-Z]+[ ].*                    a.InvalidDirective(lineNumber); updatePos();        
\n                                              updatePos();
\"([^"\n])*\"                                   printf("%s",yytext); updatePos();
%%

void define()
{
    string key;
    string value;
    char *end = 0;
    char *tmp = strstr(yytext, "#define");

    tmp += 8;
    end = strstr(tmp, " ");
    *end = 0;
    key = string(tmp);
    tmp = end + 1;
    value = string(tmp);

    defines[key] = value;
}

void expand()
{
    string key = string(yytext + 1);

    if (key.size() > 0 && defines[key].size() > 0)
    {
        printf("%s", defines[key].c_str());
    }
    else
    {
        a.InvalidDirective(lineNumber);
    }
}

void updatePos()
{
    yylloc.first_line = lineNumber;
    yylloc.first_column = columnNumber;
    countNewLines();
    yylloc.last_line = lineNumber;
    yylloc.last_column = columnNumber - 1;

}

void countNewLines()
{
    string test = yytext;
    int count = 0;
    while(count < test.size())
    {
        columnNumber++;
        if(test[count] == '\n')
        {
            printf("\n");
            columnNumber = 1;
            lineNumber++;
        }
        count++;
    }
}
