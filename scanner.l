/* File:  scanner.l
 * ----------------
 * Lex inupt file to generate the scanner for the compiler.
 */

%{

/* The text within this first region delimited by %{ and %} is assumed to
 * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
 * of the definitions of the yylex() function. Add other header file inclusions
 * or C++ variable declarations/prototypes that are needed by your code here.
 */

#include <string.h>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"

void updatePos();
void countNewLines();
ReportError a;

/* Global variable: yylval
 * -----------------------
 * This global variable is how we get attribute information about the token
 * just scanned to the client. The scanner sets the global variable
 * appropriately and since it's global the client can just read it.  In the
 * future, this variable will be declared for us in the y.tab.c file
 * produced by Yacc, but for now, we declare it manually.
 */
YYSTYPE yylval;  // manually declared for pp1, later Yacc provides
int lineNumber = 1, columnNumber = 1;

/* Global variable: yylloc
 * -----------------------
 * This global variable is how we get position information about the token
 * just scanned to the client. (Operates similarly to yylval above)
 */
struct yyltype yylloc; // manually dclared for pp1, later Yacc provides

/* Macro: YY_USER_ACTION 
 * ---------------------
 * This flex built-in macro can be defined to provide an action which is
 * always executed prior to any matched rule's action. Basically, it is
 * a way of having a piece of code common to all actions factored out to
 * this routine.  We already defined it for you and left the empty
 * function DoBeforeEachAction ready for your use as needed. It will
 * be called once for each pattern scanned from the file, before
 * executing its action.
 */
static void DoBeforeEachAction(); 
#define YY_USER_ACTION DoBeforeEachAction();

%}

 /* The section before the first %% is the Definitions section of the lex
  * input file. Here is where you set options for the scanner, define lex
  * states, and can set up definitions to give names to regular expressions
  * as a simple substitution mechanism that allows for more readable
  * entries in the Rules section later. 
  */

digit	[0-9]
letter	[a-zA-Z]
hexletter [abcdefABCDEF]
badpunct	[$@^&~'?]
goodpunct	[=!><\{\}\(\)\[\]\+-\.\/\*%;,\.]
stringchar[]
%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 
\"[^"]*(\n)							updatePos(); a.UntermString(&yylloc, yytext);
\/\/.*\n					 		updatePos();
(\/\*)(.|\n)*(\*\/)					updatePos();
(0x|0X)({digit}|{hexletter})+	  	updatePos(); yylval.integerConstant = strtol(yytext, NULL, 16); return T_IntConstant;
({digit})* 							updatePos(); yylval.integerConstant = atoi(yytext); return T_IntConstant;
({digit})+(\.)({digit})*((E(\+|-)?{digit}+)|(e(\+|-)?{digit}+))?  			updatePos(); yylval.doubleConstant = atof(yytext); return T_DoubleConstant;
\"([^"\n])*\" 						updatePos(); yylval.stringConstant = yytext; return T_StringConstant;
\<\=								updatePos(); return T_LessEqual;
\>\=								updatePos(); return T_GreaterEqual;
\=\=								updatePos(); return T_Equal;
\!\=								updatePos(); return T_NotEqual;
\&\& 								updatePos(); return T_And;
\|\| 								updatePos(); return T_Or;
void								updatePos(); return T_Void;
int									updatePos(); return T_Int;
double								updatePos(); return T_Double;
bool								updatePos(); return T_Bool;
string								updatePos(); return T_String;
class								updatePos(); return T_Class;
interface							updatePos(); return T_Interface;
null								updatePos(); return T_Null;
this 								updatePos(); return T_This;
extends								updatePos(); return T_Extends;
implements							updatePos(); return T_Implements;
for 								updatePos(); return T_For;
while 								updatePos(); return T_While;
if 									updatePos(); return T_If;
else 								updatePos(); return T_Else;
return								updatePos(); return T_Return;
break								updatePos(); return T_Break;
New  								updatePos(); return T_New;
NewArray 							updatePos(); return T_NewArray;
true								updatePos(); yylval.boolConstant = true; return T_BoolConstant;
false								updatePos(); yylval.boolConstant = false; return T_BoolConstant;
({letter})+({letter}|{digit}|_)*	updatePos(); strncpy(yylval.identifier, yytext, sizeof(yylval.identifier)-1); if(strlen(yytext) > 31){ a.LongIdentifier(&yylloc, yytext);} return T_Identifier;
\n 									updatePos(); 
" "									updatePos();
{goodpunct}							updatePos(); return *yytext;
.									updatePos(); a.UnrecogChar(&yylloc, *yytext);	
%%
/* The closing %% above marks the end of the Rules section and the beginning
 * of the User Subroutines section. All text from here to the end of the
 * file is copied verbatim to the end of the generated lex.yy.c file.
 * This section is where you put definitions of helper functions.
 */


/* Function: InitScanner
 * ---------------------
 * This function will be called before any calls to yylex().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yy_flex_debug that controls whether flex prints debugging information
 * about each token and what rule was matched. If set to false, no information
 * is printed. Setting it to true will give you a running trail that might
 * be helpful when debugging your scanner. Please be sure the variable is
 * set to false when submitting your final version.
 */
void InitScanner()
{
    PrintDebug("lex", "Initializing scanner");
    yy_flex_debug = false;
}


/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
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
			columnNumber = 1;
			lineNumber++;
		}
		count++;
	}
}