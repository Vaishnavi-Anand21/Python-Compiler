%option noyywrap
%option yylineno
%{
#include<bits/stdc++.h>
using namespace std;
//#include "parser.tab.h"
#include "parser.tab.h"
#include "classes.hpp"
stack<int> s;
int flag=0;
int c=0;
int line_no=0;
%}

SPACE [ \t]
COMMENT #[^\n]*
IGNORE {SPACE}|{COMMENT}
digitpart [1-9][0-9_]*|0([0_])*
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

"return" { yylval.node=new Node(yytext); line_no=yylineno;return RETURN;}
";" {yylval.node=new Node(yytext); line_no=yylineno;return semicolon;}
"=" { 
    yylval.node=new Node(yytext); line_no=yylineno;return EQUAL;}
":" {yylval.node=new Node(yytext); line_no=yylineno;return colon;}
"," {yylval.node=new Node(yytext); line_no=yylineno; return comma;}
"+=" {yylval.node=new Node(yytext); line_no=yylineno;return plus_eq;}
"-=" {yylval.node=new Node(yytext); line_no=yylineno;return minus_eq;}
"/=" {yylval.node=new Node(yytext); line_no=yylineno;return slash_eq;}
"//=" {yylval.node=new Node(yytext); line_no=yylineno;return double_slash_eq;}
"%=" {yylval.node=new Node(yytext); line_no=yylineno;return mod_eq;}
"*=" {yylval.node=new Node(yytext); line_no=yylineno;return star_eq;}
"**=" {yylval.node=new Node(yytext); line_no=yylineno;return double_star_eq;}
"&=" {yylval.node=new Node(yytext); line_no=yylineno;return a_eq;}
"|=" {yylval.node=new Node(yytext); line_no=yylineno;return o_eq;}
"^=" {yylval.node=new Node(yytext); line_no=yylineno;return x_eq;}
"<<=" {yylval.node=new Node(yytext); line_no=yylineno;return lshift_eq;}
">>=" {yylval.node=new Node(yytext); line_no=yylineno;return rshift_eq;}
\"__main__\"   { yylval.node=new Node(yytext, "str", false, true); line_no=yylineno; return STRING; }
"break" {yylval.node=new Node(yytext); line_no=yylineno;return BREAK;}
"continue" {yylval.node=new Node(yytext); line_no=yylineno;return CONTINUE;}
"if" {yylval.node=new Node(yytext); line_no=yylineno;return IF;}
"elif" {yylval.node=new Node(yytext); line_no=yylineno;return elif;}
"else" {yylval.node=new Node(yytext); line_no=yylineno;return ELSE;}
"while" {yylval.node=new Node(yytext); line_no=yylineno;return WHILE;}
"for" {yylval.node=new Node(yytext); line_no=yylineno;return FOR;}
"in" {yylval.node=new Node(yytext); line_no=yylineno;return in;}
"and" {yylval.node=new Node(yytext); line_no=yylineno;return AND;}
"or" {yylval.node=new Node(yytext); line_no=yylineno;return OR;}
"not" {yylval.node=new Node(yytext); line_no=yylineno;return NOT;}
"is" {yylval.node=new Node(yytext); line_no=yylineno;return is;}
"==" {yylval.node=new Node(yytext); line_no=yylineno;return double_eq;}
"!=" {yylval.node=new Node(yytext); line_no=yylineno;return NOT_EQ;}
">" {yylval.node=new Node(yytext); line_no=yylineno;return GREATER;}
"<" {yylval.node=new Node(yytext); line_no=yylineno;return lesser;}
"<=" {yylval.node=new Node(yytext); line_no=yylineno;return lesser_eq;}
">=" {yylval.node=new Node(yytext); line_no=yylineno;return greater_eq;}
"+" {yylval.node=new Node(yytext); line_no=yylineno;return PLUS;}
"-" {yylval.node=new Node(yytext); line_no=yylineno;return MINUS;}
"*" {yylval.node=new Node(yytext); line_no=yylineno;return star;}
"**" {yylval.node=new Node(yytext); line_no=yylineno;return double_star;}
"/" {yylval.node=new Node(yytext); line_no=yylineno;return slash;}
"//" {yylval.node=new Node(yytext); line_no=yylineno;return double_slash;}
"%" {yylval.node=new Node(yytext); line_no=yylineno;return mod;}
"|" {yylval.node=new Node(yytext); line_no=yylineno;return BIT_OR;}
"&" {yylval.node=new Node(yytext); line_no=yylineno;return BIT_AND;}
"~" {yylval.node=new Node(yytext); line_no=yylineno;return BIT_NOT;}
"^" {yylval.node=new Node(yytext); line_no=yylineno;return BIT_XOR;}
"<<" {yylval.node=new Node(yytext); line_no=yylineno;return lshift;}
">>" {yylval.node=new Node(yytext); line_no=yylineno;return rshift;}
"(" {yylval.node=new Node(yytext); line_no=yylineno;return ropen;}
")" {yylval.node=new Node(yytext); line_no=yylineno;return rclose;}
"[" {yylval.node=new Node(yytext); line_no=yylineno;return SOPEN;}
"]" {yylval.node=new Node(yytext); line_no=yylineno;return sclose;}
([1-9]([0-9_])*|0([0_])*)|0([bB])([01_])+|0([oO])([0-7_])+|0([xX])([0-9a-fA-F_])+  {
    yylval.node=new Node(yytext, "int", false, true);
     line_no=yylineno;
    return num;}
{digitpart}\.{digitpart}([eE][+-]?{digitpart})?|{digitpart}\.([eE][+-]?{digitpart})?|{digitpart}([eE][+-]?{digitpart})? {        
    yylval.node=new Node(yytext, "float", false, true);
     line_no=yylineno;
    return num;
}
[\"][^\n\"]*[\"]|[\'][^\n\']*[\'] {
      //cout<<"inside expression"<<endl;
      //cout<<yytext<<endl;
    
    yylval.node=new Node(yytext, "str", false, true);
    line_no=yylineno;
   if(yytext[0]==39){
    //cout<<"inside"<<endl;
    
    return STRING;}
    else {
        yytext[0]=yytext[0]+39-34;
        yytext[yyleng-1]=yytext[yyleng-1]+5;
       
        return STRING;
    }
}

"None" {yylval.node=new Node(yytext); line_no=yylineno;return none;}
"True" {
    //cout<<"true"<<endl;
    yylval.node=new Node(yytext, "bool", false);
     line_no=yylineno;
    return TRUe;}
"False" {yylval.node=new Node(yytext, "bool", false); line_no=yylineno;return FALSe;}
"\." {yylval.node=new Node(yytext); line_no=yylineno;return dot;}
"class" {yylval.node=new Node(yytext); line_no=yylineno;return CLASS;}
"def" {yylval.node=new Node(yytext); line_no=yylineno;return def;}
"->" {yylval.node=new Node(yytext); line_no=yylineno;return arrow;}
[a-zA-Z_][a-zA-Z0-9_]* {
     //cout<<"atleast inside var in lex "<<endl;
      yylval.node=new Node(yytext, "", false);
       line_no=yylineno; 
     return var;}
<INITIAL><<EOF>> {BEGIN(end); line_no=yylineno; return ENDMARKER;}
. {fprintf(stderr,"Syntax error 1 at line number:%d\n",yylineno); exit(1);}
%%









