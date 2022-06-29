%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
void yyerror (char *s);
int yylex();
char* trimQuotes(char* val);
extern int yylineno;
%}

boolean_literal   true|false
integer_literal   [-+]?[0-9]+
double_literal    [-+]?[0-9]+[\.]?[0-9]+
string_literal    \"[^"]*\"
identifier        [_a-zA-Z][_a-zA-Z0-9]*
comment           \/\/.*

%%
{boolean_literal}   {
                      if(strcmp(yytext, "true") == 0)
                        yylval.literal = "1I";
                      else if(strcmp(yytext, "false") == 0)
                        yylval.literal = "0I";
                       return LITERAL;
                    }
{integer_literal}   {yylval.literal = strcat(strdup(yytext), "I"); return LITERAL;}
{double_literal}    {yylval.literal = strcat(strdup(yytext), "D"); return LITERAL;}
{string_literal}    {yylval.literal = strcat(trimQuotes(strdup(yytext)), "S"); return LITERAL;}
{comment}           ;
"if"                {return IF;}
"else"              {return ELSE;}
"function"          {return FUNCTION;}
"()"                {return FUNC_CALL;}
"while"             {return WHILE;}
"print"             {return PRINT;}
"fprint"            {return FPRINT;}
"fread"             {return FREAD;}
"=="                {return IS_EQUAL;}
"!="                {return NOT_EQUALS;}
"("                 {return PARANTHESIS_OPEN;}
")"                 {return PARANTHESIS_CLOSE;}
"{"                 {return CURLY_OPEN ;}
"}"                 {return CURLY_CLOSE ;}
"<="                {return LESS_THAN_OR_EQUALS ;}
">="                {return GREATER_THAN_OR_EQUALS ;}
[-+=;!></%&|*,]      {return yytext[0];}
{identifier}        {yylval.identifier = strdup(yytext); return IDENTIFIER;}
\n                  { yylineno++; }
[ \t]*              ;
.                   printf("UNEXPECTED FORMAT: %s\n", yytext);
%%

int yywrap(void) {
  return 1;
}

char* trimQuotes(char* val) {
  char* result = (char*)malloc(strlen(val) - 1);
  
  int i;
  for(i = 1; i < strlen(val) - 1; ++i) {
    result[i - 1] = (char)val[i];
  }

  result[strlen(val) - 1] = '\0';

  return result;
}