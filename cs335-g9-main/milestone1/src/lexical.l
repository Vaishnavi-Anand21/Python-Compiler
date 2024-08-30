%option noyywrap
%option yylineno
%{
#include "parser.tab.h"
#include<bits/stdc++.h>
using namespace std;
stack<int> s;
int flag=0;
int c=0;
%}

SPACE [ \t]
COMMENT #[^\n]*
IGNORE {SPACE}|{COMMENT}
digitpart [1-9][0-9_]*|0([0_])*
STR [\"][^\n\"]*[\"]|[\'][^\n\']*[\']
%s end

%%
    {   
        if(s.empty()){
            s.push(0);
        }
        if(flag==1)
        {
            if(c>s.top()){
                flag=0;
                s.push(c);
                c=0;
                return indent;
            }
            while(c<s.top()){
                s.pop();
                if(s.empty()){
                    fprintf(stderr,"Indedentation error at line number:%d\n",yylineno);
                    exit(1);
                }
                return dedent;
            }
            if(c!=s.top()){
                fprintf(stderr,"Indedentation error at line number:%d\n",yylineno);
                exit(1);
            }
            flag=0;
        }
    }
{COMMENT} 
^({SPACE})+{COMMENT}?$ {
   cerr<<"wtf bro"<<endl;
    }
^{SPACE}+/. {
    c=yyleng-1;
    if(c!=s.top()) flag=1;
    return yylex();    
    }
\n{SPACE}*{COMMENT}?/\n
\n({SPACE})* {
    c=yyleng-1;
    if(c!=s.top()) flag=1;
    return NEWLINE;    
}
{SPACE}+

"return" { 
    yylval.str = strdup(yytext);return RETURN;}
";" {yylval.str = strdup(yytext);return semicolon;}
"=" { 
    yylval.str = strdup(yytext);return EQUAL;}
":" {yylval.str = strdup(yytext);return colon;}
"," {yylval.str = strdup(yytext);return comma;}
"+=" {yylval.str = strdup(yytext);return plus_eq;}
"-=" {yylval.str = strdup(yytext);return minus_eq;}
"/=" {yylval.str = strdup(yytext);return slash_eq;}
"//=" {yylval.str = strdup(yytext);return double_slash_eq;}
"%=" {yylval.str = strdup(yytext);return mod_eq;}
"*=" {yylval.str = strdup(yytext);return star_eq;}
"**=" {yylval.str = strdup(yytext);return double_star_eq;}
"&=" {yylval.str = strdup(yytext);return a_eq;}
"|=" {yylval.str = strdup(yytext);return o_eq;}
"^=" {yylval.str = strdup(yytext);return x_eq;}
"<<=" {yylval.str = strdup(yytext);return lshift_eq;}
">>=" {yylval.str = strdup(yytext);return rshift_eq;}
\"__main__\"   { yylval.str = strdup("__main__"); return STRING; }
"break" {yylval.str = strdup(yytext);return BREAK;}
"continue" {yylval.str = strdup(yytext);return CONTINUE;}
"if" {yylval.str = strdup(yytext);return IF;}
"elif" {yylval.str = strdup(yytext);return elif;}
"else" {yylval.str = strdup(yytext);return ELSE;}
"while" {yylval.str = strdup(yytext);return WHILE;}
"for" {yylval.str = strdup(yytext);return FOR;}
"in" {yylval.str = strdup(yytext);return in;}
"and" {yylval.str = strdup(yytext);return AND;}
"or" {yylval.str = strdup(yytext);return OR;}
"not" {yylval.str = strdup(yytext);return NOT;}
"is" {yylval.str = strdup(yytext);return is;}
"==" {yylval.str = strdup(yytext);return double_eq;}
"!=" {yylval.str = strdup(yytext);return NOT_EQ;}
">" {yylval.str = strdup(yytext);return GREATER;}
"<" {yylval.str = strdup(yytext);return lesser;}
"<=" {yylval.str = strdup(yytext);return lesser_eq;}
">=" {yylval.str = strdup(yytext);return greater_eq;}
"+" {yylval.str = strdup(yytext);return PLUS;}
"-" {yylval.str = strdup(yytext);return MINUS;}
"*" {yylval.str = strdup(yytext);return star;}
"**" {yylval.str = strdup(yytext);return double_star;}
"/" {yylval.str = strdup(yytext);return slash;}
"//" {yylval.str = strdup(yytext);return double_slash;}
"%" {yylval.str = strdup(yytext);return mod;}
"|" {yylval.str = strdup(yytext);return BIT_OR;}
"&" {yylval.str = strdup(yytext);return BIT_AND;}
"~" {yylval.str = strdup(yytext);return BIT_NOT;}
"^" {yylval.str = strdup(yytext);return BIT_XOR;}
"<<" {yylval.str = strdup(yytext);return lshift;}
">>" {yylval.str = strdup(yytext);return rshift;}
"(" {yylval.str = strdup(yytext);return ropen;}
")" {yylval.str = strdup(yytext);return rclose;}
"[" {yylval.str = strdup(yytext);return SOPEN;}
"]" {yylval.str = strdup(yytext);return sclose;}
([1-9]([0-9_])*|0([0_])*)|0([bB])([01_])+|0([oO])([0-7_])+|0([xX])([0-9a-fA-F_])+  {
    yylval.str = strdup(yytext);
    return num;}
{digitpart}\.{digitpart}([eE][+-]?{digitpart})?|{digitpart}\.([eE][+-]?{digitpart})?|{digitpart}([eE][+-]?{digitpart})? {        
    yylval.str = strdup(yytext);
    return num;
}
{STR} {
    if(yytext[0]==39){
    yylval.str = strdup(yytext);
    return STRING;}
    else {
        yytext[0]=yytext[0]+39-34;
        yytext[yyleng-1]=yytext[yyleng-1]+5;
        yylval.str = strdup(yytext);
        return STRING;
    }
    }

"None" {yylval.str = strdup(yytext);return none;}
"True" {yylval.str = strdup(yytext);return TRUe;}
"False" {yylval.str = strdup(yytext);return FALSe;}
"\." {yylval.str = strdup(yytext);return dot;}
"class" {yylval.str = strdup(yytext);return CLASS;}
"def" {yylval.str = strdup(yytext);return def;}
"->" {yylval.str = strdup(yytext);return arrow;}
[a-zA-Z_][a-zA-Z0-9_]* {yylval.str = strdup(yytext);return var;}
<INITIAL><<EOF>> {BEGIN(end); return ENDMARKER;}
. {fprintf(stderr,"Syntax error at line number:%d\n",yylineno); exit(1);}
%%