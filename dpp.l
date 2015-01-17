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

Map defines;

%}

%%

\/\/.*\n
(\/\*)(.|\n)*(\*\/)
[ ]*\#define[ ][A-Z]+[ ].*$ define();
\#[A-Z]+ expand();

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

    if (defines[key].size() > 0)
    {
        printf("%s", defines[key].c_str());
    }
    else
    {
        printf("ERROR: Invalid directive\n");
    }
}
