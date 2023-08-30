/* Trabalho de Compiladores - Cleiber Rodrigues e Cintia Valente */
/* Cartões: 00270139 - 00228540 */

%option noyywrap
%option yylineno
%option nounput
%x MULTI_LINE_COMMENT
%x SINGLE_LINE_COMMENT

%{
#include <iostream>    
#include <string>
#include <algorithm>
#include "parser.tab.h"
#include "tree.hh"

using namespace std;

int getLineNumber();

%}

TOKEN_ID  ([a-z]*|_)
SPECIAL [-,;!*(\)\{\}+/<>=%–]
CHAR    '[^']'
STRING  \"[^"\n]*\"
INT     [0-9]+
FLOAT   [0-9]*[.][0-9]+
TRUE    "true"
FALSE   "false"

%%

<INITIAL>"//"                   BEGIN(SINGLE_LINE_COMMENT);
<SINGLE_LINE_COMMENT>"\n"       BEGIN(INITIAL);
<SINGLE_LINE_COMMENT>.|"\n"     { /* do nothing */ }

<INITIAL>"/*"        BEGIN(MULTI_LINE_COMMENT);
<MULTI_LINE_COMMENT>"*/"        BEGIN(INITIAL);
<MULTI_LINE_COMMENT>.|"\n"     { /* do nothing */ }

[\n]        {  }
[ \t\n\r\s]+      {/* Skips blanks and tabs */ }

"int" 		{ yylval.valor_lexico = nullptr; return TK_PR_INT; }
"float" 	{ yylval.valor_lexico = nullptr; return TK_PR_FLOAT; }
"bool" 		{ yylval.valor_lexico = nullptr; return TK_PR_BOOL; }
"if" 		{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_PR, "if");     return TK_PR_IF; }
"else" 		{ yylval.valor_lexico = nullptr; return TK_PR_ELSE; }
"while" 	{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_PR, "while");  return TK_PR_WHILE; }
"return"	{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_PR, "return"); return TK_PR_RETURN; }

{INT}     { yylval.valor_lexico = new AstNode(yylineno, TkType::TK_LIT_INT, yytext); return TK_LIT_INT; }
{FLOAT}   { yylval.valor_lexico = new AstNode(yylineno, TkType::TK_LIT_FLOAT, yytext); return TK_LIT_FLOAT; }
{TRUE}    { yylval.valor_lexico = new AstNode(yylineno, TkType::TK_LIT_BOOL, "true"); return TK_LIT_TRUE; }
{FALSE}   { yylval.valor_lexico = new AstNode(yylineno, TkType::TK_LIT_BOOL, "false"); return TK_LIT_FALSE; }

{TOKEN_ID} { 
    yylval.valor_lexico = new AstNode(yylineno, TkType::TK_ID, yytext); 
    return TK_IDENTIFICADOR;
    }


{SPECIAL} { 
    yylval.valor_lexico = nullptr;
    // Ignora caracteres que não irão para a arvore sintática
    if (find(invalid_chars.begin(), invalid_chars.end(), yytext[0]) == invalid_chars.end()) {
        string sp_char = std::string(1,yytext[0]);
        yylval.valor_lexico = new AstNode(yylineno, TkType::TK_SP_CHAR, sp_char);
    }
    return yytext[0]; 
    }


"<="		{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_OC, "<="); return TK_OC_LE; }	
">="		{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_OC, ">="); return TK_OC_GE; }	
"=="		{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_OC, "=="); return TK_OC_EQ; }
"!="		{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_OC, "!="); return TK_OC_NE; }	
"&"			{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_OC, "&" ); return TK_OC_AND; }	
"|" 		{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_OC, "|" ); return TK_OC_OR; }	 
"->" 		{ yylval.valor_lexico = new AstNode(yylineno, TkType::TK_OC, "->"); return TK_OC_MAP; }	




.			{ return TK_ERRO; }

%%

int get_line_number() {
	return yylineno;
}
