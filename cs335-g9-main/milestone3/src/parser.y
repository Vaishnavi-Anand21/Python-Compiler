%{

#define YYDEBUG 1
#include<bits/stdc++.h>
#include <stdio.h>
#include<string>
#include"classes.hpp"
#include<regex>
using namespace std;

extern int line_no;
extern int yylineno;
extern char* yytext;
extern int yyparse();
extern int yylex();
#include <fstream>
#define YYERROR_VERBOSE 1
extern FILE* yyin;
void yyerror(const char *s);
int yylex(void);
int sizee;
int gstr_len=0;
int safe_func=0;
string obj_name="";
int obj_func=0;
int filling_obj_func=0;
int pow_count=1;
int checking=0;
string list_type="";
int list_siz=0;
int cls=0;
string ret_type="";
int off=0;
int see=0;
int brek=0;
int got_ret=0;
int init_dec=0;
int cont=0;
int expect_return=0;
int find_the1=0;
string name, typ;
int num_of=1;
string for_var,val_range,val_range1="0";
int nooarg=0;
bool is_range=0;
int rc=0;
string class_name;
stack<pair<string,int>>argstack;
vector<quadraple*>code;
vector<quadraple*> pt;
void fillin(string op, string arg1, string arg2, string result){
        quadraple* temp=new quadraple();
        temp->op = op;
        temp->arg1 = arg1;
        temp->arg2 = arg2;
        temp->result = result;

        code.push_back(temp);
    }
//creating temporary variables
int counter=0;
int other_counter=0;
int temp_count=0;
quadraple* Filling_Begin;
quadraple* Filling_function; //this is to fill the function(of a class) called in an object
string newtemp(){
      string temp_var = "t"+to_string(counter++);
      temp_count++;
      return temp_var;
    }
string newLabel(){
      string temp_var = "L"+to_string(other_counter++);
      //cout<<temp_var<<endl;
      return temp_var;
    }

vector<quadraple*> merge_list(vector<quadraple*> l1,vector<quadraple*> l2){
    vector<quadraple*>temp;
    if(l1.size()>0)
    for(auto t :l1){
        temp.push_back(t);
    }
    if(l2.size()>0)
    for(auto t :l2){
        temp.push_back(t);
    }
    return temp;
}
void backpatch(vector<quadraple*>l,string s){
    
    if(l.size()>0){
       // cout<<"inside backpatch!!!!!!"<<endl;
    for(auto t:l){
        t->result=s;
       // cout<<"this is my goto filled!!! "<<t->result<<endl;
    }}
}
bool flow_st=0;
bool inside_flow_comp=0;
bool got_not1=0;
bool obj_decl=0;
bool is_len=0;
bool class_decl=0;
bool filled_flow=0;
string obj_base_addr="obj_base_addr";
bool class_decl_init=0; 
bool middle_oflist_access=0;
string list_name;
bool is_print=0;
//bool obj_access=0;
//string obj_access_addr;
map<string, int> kews = {
    {"int", 4},
    {"float", 4},
    {"char", 1},
    {"bool", 1},
    {"str", 1},
    {"void", 0},
  {"__name__",0},
    {"print",0},
    {"range",0},
    {"len",0},
};

map<string, int>allowedtypes = {
    {"int", 16},
    {"float", 16},
    {"char", 16},
    {"bool", 16},
    {"str", 16},
    {"void", 0}
};

string return_func(Symbol_table* current){

    if(current==NULL) return "Error";
   // cout<<"gggggg     "<<current->type<<"       GGGG"<<endl;
    if(current->type=="function") return current->ret_type;
    return return_func(current->parent);
}

int calcsize(string t1, string type){
    if(type!="str"){
        // cout<<"heyyyyyyyyyyyyyyyyyyyy<<"
        return allowedtypes[type];
    }
    return 16;
}

int func_assign(string type1, string type2){
    if(type1==type2) return 1;
    if (type1 == "bool" && type2 == "int") return 1;
    if (type1 == "int" && type2 == "bool") return 1;
    if (type1 == "float" && type2 == "bool") return 1;
    if (type1 == "bool" && type2 == "float") return 1;
    if (type1 == "int" && type2 == "float") return 1;
    if (type1 == "float" && type2 == "int") return 1;
    
   
    return 0;
}

Symbol_table* find_class_in(string name, Symbol_table*curr){
    
    if(curr==NULL) return NULL;
  // //cout<<curr->inherited->name<<"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh"<<endl;
    if(curr->name==name) return curr;
    return find_class_in(name, curr->inherited);
}

Symbol_table* find_func_class(string name,Symbol_table* current){
    if(current==NULL) return NULL;
    if(current->tab_func_class.find(name)!=current->tab_func_class.end()){
        if(current->tab_func_class[name]->type=="function")
        return current->children[name];
    }
    return find_func_class(name, current->inherited);
}

Symbol* find_var_class(string name,Symbol_table* current){
    if(current==NULL) return NULL;
    ////cout<<current->inherited->name<<endl;
    if(current->tab_var.find(name)!=current->tab_var.end()){
        
        return current->tab_var[name];
    }
    return find_var_class(name, current->inherited);
}

void add_symbol(Symbol_table* current, string name, string type, unsigned long l,bool initials,unsigned long offset,unsigned size,int num_of, bool isList = false) {
    if(kews.find(name)!=kews.end()) yyerror("This name cannot be declared");
    if (type == "function" || type == "class") {
        if (name == "print" || name == "range" || name == "len") {
            fprintf(stderr, "Error: Redeclaration of function %s at line %lu\n", name.c_str(), l);
        }
        Symbol* s = new Symbol();
        s->name = name;
        s->type = type;
        s->lineno = l;
        s->offset = offset;
        s->isinitial=initials;
        if (current->tab_func_class[name] != NULL) {
            delete current->tab_func_class[name];
        }
        current->tab_func_class[name] = s;
    } else {
        if (current->tab_var.find(name) != current->tab_var.end()) {
            cout << "Error: Redeclaration of variable " << name << " at line " << l << endl;
            exit(1);
        }
        Symbol* s = new Symbol();
        s->name = name;
        s->type = type;
        s->lineno = l;
        s->str_len=gstr_len;
        s->isList = isList;
        s->num_e=num_of;
        s->size=size;
        s->offset=offset;
        s->isinitial=initials;
        current->tab_var[name] = s;
    }
}
/*
int find_size(string type) {
    for (auto i : allowedtypes) {
        if (i.first == type) {
            return i.second;
        }
    }
    return -1;
}*/

Symbol* find_func(string name, Symbol_table* current) {
    while (current != NULL) {
        if (current->tab_func_class.find(name) != current->tab_func_class.end() && current->tab_func_class[name]->type == "function") {
            return current->tab_func_class[name];
        }
        current = current->parent;
    }
    return NULL;
}
Symbol_table* find_func_tab(string name,Symbol_table* current){
while (current != NULL) {
        if (current->children.find(name) != current->children.end() && current->children[name]->type == "function") {
            return current->children[name];
        }
        auto k= find_func_tab(name, current->inherited);
        if(k!=NULL) return k;
        current = current->parent;
    }
    return NULL;
}
Symbol* find_var(string name, Symbol_table* current) {
    while (current != NULL) {
        if (current->tab_var.find(name) != current->tab_var.end()) {
            return current->tab_var[name];
        }
        auto k= find_var(name, current->inherited);
        if(k!=NULL) return k;
        current = current->parent;
    }
    return NULL;
}

Symbol_table* find_class(string name, Symbol_table* current) {
    while (current != NULL) {
        if (current->tab_func_class.find(name) != current->tab_func_class.end() && current->tab_func_class[name]->type == "class") {
            return current;
        }
        current = current->parent;
    }
    return NULL;
}

int for_augasign(string type1, string type2) {
    if (type1 == "int" && type2 == "int") return 1;
    if (type1 == "bool" && type2 == "bool") return 1;
    if (type1 == "bool" && type2 == "int") return 1;
    if (type1 == "int" && type2 == "bool") return 1;
    if (type1 == "float" && type2 == "bool") return 1;
    if (type1 == "bool" && type2 == "bool") return 1;
    if (type1 == "bool" && type2 == "float") return 1;
    if (type1 == "bool" && type2 == "bool") return 1;
    if (type1 == "float" && type2 == "float") return 1;
    if (type1 == "bool" && type2 == "bool") return 1;
    if (type1 == "int" && type2 == "float") return 1;
    if (type1 == "float" && type2 == "int") return 1;
    if (type1 == "bool" && type2 == "int") return 1;
    if (type1 == "int" && type2 == "bool") return 1;
    if (type1 == "float" && type2 == "bool") return 1;
    if (type1 == "bool" && type2 == "float") return 1;
    if (type1 == "string" && type2 == "string") return 1;
    return 0;
}

int for_decl(string type1, string type2) {
    if (type1 == "int" && type2 == "int") return 1;
    if (type1 == type2) return 1;
    if (type1 == "bool" && type2 == "bool") return 1;
    if (type1 == "bool" && type2 == "int") return 1;
    if (type1 == "int" && type2 == "bool") return 1;
    if (type1 == "float" && type2 == "bool") return 1;
    if (type1 == "bool" && type2 == "bool") return 1;
    if (type1 == "bool" && type2 == "float") return 1;
    if (type1 == "bool" && type2 == "bool") return 1;
    if (type1 == "float" && type2 == "float") return 1;
    if (type1 == "bool" && type2 == "bool") return 1;
    if (type1 == "int" && type2 == "float") return 1;
    if (type1 == "float" && type2 == "int") return 1;
    if (type1 == "bool" && type2 == "int") return 1;
    if (type1 == "int" && type2 == "bool") return 1;
    if (type1 == "float" && type2 == "bool") return 1;
    if (type1 == "bool" && type2 == "float") return 1;
    if (type1 == "string" && type2 == "string") return 1;
    return 0;
}

string find_typediv(string t1, string t2) {
    if (t1 == "int" && t2 == "int") return "int";
    if (t1 == "int" && t2 == "float") return "float";
    if (t1 == "float" && t2 == "int") return "float";
    if (t1 == "float" && t2 == "float") return "float";
    if (t1 == "bool" && t2 == "int") return "bool";
    if (t1 == "int" && t2 == "bool") return "bool";
    if (t1 == "bool" && t2 == "bool") return "bool";
    if (t1 == "bool" && t2 == "float") return "float";
    if (t1 == "float" && t2 == "bool") return "float";
    if (t1 == "int" && t2 == "float") return "float";
    if (t1 == "float" && t2 == "int") return "float";
   
    return "error";
}



Symbol_table* global_table=new Symbol_table();

Symbol_table* current=global_table;

map<string, int> m;

void fill_node(Node* n, Symbol* s){
    n->type=s->type;
    //cout<<n->type<<"!!!!!!"<<endl;
    n->isList=s->isList;
    n->str_len=s->str_len;
    n->no_of_arguments=s->no_of_arguments;
    n->ret_type=s->ret_type;
    n->isinitial=s->isinitial;
}
void print_help_page() {
    cout << "Usage: ./prob.o [options]     \n\n";
    cout << "Commands:\n-h, --help \t\t\t\t\t Show help page\n";
    cout << "-i, --input <input_file_name> \t\t\t Give input file\n";
    cout << "-o, --output <output_file_name>\t\t\t Redirect dot file to output file\n";
    cout << "-v, --verbose \t\t\t\t\t Outputs the entire derivation in command line\n";
    return;
}
FILE *program;  
string input_file = "testcase.py";
string output_file = "ast.dot"; 
int statements=0;
string head="";
string edge ="Name";
struct node* root ;
Symbol_table* func_name=NULL;
int no_of_args=0;
std::vector<string> ::iterator func_arg_traverse;

%}


%union{
    class Node* node;
    char* str;
}

%start start_file
%token  <node> var
%token  <node> semicolon
%token  <node> NEWLINE
%token  <node> EQUAL 
%token  <node> colon
%token  <node> comma
%token  <node> plus_eq
%token  <node> minus_eq
%token  <node> star_eq
%token  <node> slash_eq
%token  <node> double_slash_eq
%token  <node> mod_eq
%token  <node> double_star_eq
%token  <node> a_eq
%token  <node> o_eq
%token  <node> x_eq
%token  <node> lshift_eq
%token  <node> rshift_eq
%token  <node> indent
%token  <node> dedent
%token  <node> BREAK
%token  <node> CONTINUE
%token  <node> RETURN
%token  <node> IF
%token  <node> elif
%token  <node> ELSE
%token  <node> WHILE
%token  <node> FOR
%token  <node> in
%token  <node> AND
%token  <node> OR
%token  <node> NOT
%token  <node> is
%token  <node> double_eq
%token  <node> NOT_EQ
%token  <node> GREATER
%token  <node> lesser
%token  <node> greater_eq
%token  <node> lesser_eq
%token  <node> PLUS
%token  <node> MINUS
%token  <node> star 
%token  <node> slash
%token  <node> double_slash
%token  <node> double_star
%token  <node> mod
%token  <node> BIT_OR
%token  <node> BIT_AND
%token  <node> BIT_XOR
%token  <node> BIT_NOT
%token  <node> lshift
%token  <node> rshift
%token  <node> ropen
%token  <node> rclose
%token  <node> SOPEN
%token  <node> sclose
%token  <node> num
%token  <node> STRING
%token  <node> none
%token  <node> TRUe
%token  <node> FALSe
%token  <node> dot
%token  <node> CLASS
%token ENDMARKER
%token  <node> arrow
%token  <node> def
%type<node> argument
%type<node> classdef
%type <node> file_input
%type <node> stmt_plus
%type <node> funcdef
%type <node> parameters
%type <node> typedargslist
%type <node> tfpdef
%type <node> stmt
%type <node> simple_stmt
%type <node> small_stmt
%type <node> expr_stmt
%type <node> augasign
%type <node> flow_stmt
%type <node> break_stmt
%type <node> continue_stmt
%type <node> return_stmt
%type <node> compound_stmt
%type <node> if_stmt
%type <node> elif_star
%type <node> while_stmt
%type <node> for_stmt
%type <node> suite
%type <node> test
%type <node> or_test
%type <node> and_test
%type <node> not_test
%type <node> comparison
%type <node> comp_op
%type <node> expr
%type <node> xor_expr
%type <node> and_expr
%type <node> shift_expr
%type <node> arith_expr
%type <node> term
%type <node> factor
%type <node> power
%type <node> atom_expr
%type <node> atom
%type <node> Ineed
%type <node> arglist

%type <node> testlist

%type <node> test_new

%type <node> arg_new

%type <node> typedargslist_new
%type <node> extralabel_if
%type <node> extralabel
%type <node> extralabel1
%type <node> extralabel2
%type <node> loop_extra
%%
//list_siz

start_file :NEWLINE start_file | file_input;
file_input : stmt_plus ENDMARKER 
            | ENDMARKER{$$=NULL;} ;
stmt_plus : stmt_plus stmt
|stmt ;
 
funcdef: def var 
 add parameters colon suite{
    //cout<<off<<"gggggggggggggggggggggggggggggggggggggggggggg"<<endl;
   if($2->name=="__init__" && current->parent->inherited!=NULL){
 auto k=current->parent->inherited->tab_var;
    for(auto i:current->parent->inherited->ordered_var){

       // add_symbol(current,i.first, i.second->type,  i.second->lineno, i.second->isinitial, off, i.second->size, i.second->num_e, i.second->isList  );
        add_symbol(current->parent, i, k[i]->type, k[i]->lineno, k[i]->isinitial, off, k[i]->size, k[i]->num_e, k[i]->isList);
        off+=(k[i]->size);
        current->parent->ordered_var.push_back(i);
    }
   }
      class_decl_init=0; 
    
    // current->parent->tab_func_class[$2->name]->ret_type=current->ret_type;
    
    // current->parent->tab_func_class[$2->name]->no_of_arguments=current->no_of_arguments;
    current=current->parent;
    //cout<<"current->name="<<current->name<<"in func"<<endl;
    // if(current->type!="function" && current->type!="class")
    // checking=0;
    fillin("End_Function","","",""); 
    Filling_Begin->arg1=to_string(temp_count); //arg1 of begin func is the number of temp used
    temp_count=0;
}
|def var add parameters arrow var { 
     
 /// how to work with init and all and constructors
 
if(global_table->children.find($6->name)==global_table->children.end() || global_table->children[$6->name]->type!="class") yyerror("return type for function not present");
current->ret_type=$6->name;
current->parent->tab_func_class[$2->name]->ret_type=current->ret_type;
current->parent->tab_func_class[$2->name]->no_of_arguments=current->no_of_arguments;
//cout<<current->name<<" name of function scope"<<endl;
expect_return=1;
//cout<<current->ret_type<<"in func"<<endl;
 } 
 colon suite{
     
     class_decl_init=0;
     
    if(got_ret==0) yyerror("Expected return value "); 
    got_ret=0;
    
    current=current->parent;
    //cout<<"current->name="<<current->name<<"in func 1"<<endl;

//    if(current->type!="function" && current->type!="class")
//     checking=0;
   fillin("End_Function","","","");
}
|def var add parameters arrow none 
colon suite{
    
    class_decl_init=0;
   // //cout<<"i was fine only"<<endl;
    ////cout<<current->tab_var.begin()->first<<"ccccccccccccccccccccccccccccccccc"<<endl;
    // current->parent->tab_func_class[$2->name]->ret_type=current->ret_type;
    // current->parent->tab_func_class[$2->name]->no_of_arguments=current->no_of_arguments;
    
    current=current->parent;
    

//    if(current->type!="function" && current->type!="class")
//     checking=0;
    fillin("End_Function","","","");
}
 ;
add:  {
    temp_count=0;
    //cout<<current->name<<" name of scope"<<endl;
    //checking=1;
    if($<node>0->name=="__init__") {
//cout<<"This works fine"<<endl;
        class_decl_init=1;
       if(current->type!="class") yyerror("init can only be in a class");
       
    }
    add_symbol(current, $<node>0->name, "function", line_no, true, off, 0, 1);
        current= new Symbol_table(current, line_no,$<node>0->name);
        current->name=$<node>0->name;
       current->type="function";
    //    cout<<current->

        current->ret_type="None";
        current->parent->tab_func_class[$<node>0->name]->ret_type=current->ret_type;
    current->parent->tab_func_class[$<node>0->name]->no_of_arguments=current->no_of_arguments;
        
        if($<node>0->name=="__init__") {
       current->ret_type=current->parent->name;
    }
    string temp= "_"+$<node>0->name+":"; //function label is : _function:
    if(current->parent->type=="class"){
    if($<node>0->name=="__init__") fillin(class_name+".__init__"+":","*constructor","*"+class_name,"");
        else fillin("_"+current->parent->name+"."+temp,"Function","","");

    }

    else  fillin(temp,"Function","","");
   // fillin(temp,"Function","","");
      /*if($<node>0->name!="__init__")
      fillin(temp,"Function","","");
      else
       fillin(class_name+".__init__"+":","*constructor","*"+class_name,"");
      */
    fillin("Begin_Function:","","","");
    Filling_Begin=code.back();
    
}

parameters:ropen rclose {

    $$=NULL;
}
| ropen typedargslist rclose{$$=$2;};

typedargslist: typedargslist_new 
               |typedargslist_new comma ;

typedargslist_new: typedargslist_new comma tfpdef{
    // //cout<<current->tab_var.begin()->second<<"ccccccccccccccccccccccccccccccccc"<<endl;
    $$=$1;
   
}
|tfpdef
;              

tfpdef:test{
    if(current->parent->type!="class") yyerror("Argument declaration not possible");
    if($1->isCheck) yyerror("Error in declaration");
    if($1->name!="self") yyerror("Error in name");
    if(current->no_of_arguments!=0) yyerror("First argument is self");
    add_symbol(current, $1->name, current->name, line_no,true, off, 0, 1);
    current->arguments.push_back($1->name);
  // //cout<<current->tab_var.begin()->first<<endl;
   
    current->no_of_arguments++;
    auto temp=newtemp();
    int size=calcsize("dumb", current->parent->name);
    fillin("=","popparam",to_string(size),temp); //this has the object's base address(it's on top of stack).
    obj_base_addr=temp;
    $$->tempvar=temp;
  
}
 |var colon test {
    $$=NULL;
    
    $1->isLeaf=true;
    $1->l_value=true;
    if(!$3->isCheck) {
       //if(global_table->children.find($3->name)==global_table->children.end()) //cout<<"error"<<endl;
        if(global_table->children.find($3->name)==global_table->children.end() || global_table->children[$3->name]->type!="class") yyerror("type not present");   
        $3->isCheck=true;
        $3->type=global_table->children[$3->name]->type;
        $3->l_value=false;
        $3->isLeaf=false;
      //  //cout<<"check done"<<endl;
    }
    if($3->type!="class") yyerror("Unexpected type in declaration");
       
   // int size=global_table->tab_func_class[$3->name]->size;
    add_symbol(current, $1->name, $3->name, line_no,true,off, calcsize("dumb", $3->name),1, $3->isList);
    current->arguments.push_back($1->name);
    current->no_of_arguments++;
    // if(global_table->children.find($3->name)==global_table->children.end()) yyerror("type not present");
    // add_symbol(current, $1->name, $3->name, line_no);
    int sizee=calcsize("dumb", $3->name);
    fillin("=","popparam",to_string(sizee),$1->name);
    //string size_test; //fill this with the size of the "test"
   // fillin("Stackpointer","-"+size_test,"","");
}
;

stmt : simple_stmt { $$=NULL;}
| compound_stmt { $$=NULL;};

simple_stmt: small_stmt NEWLINE { $$=NULL;}
| small_stmt semicolon simple_stmt { $$=NULL;}
| small_stmt semicolon NEWLINE { $$=NULL;};

small_stmt: expr_stmt 
|flow_stmt { $$=NULL;};

expr_stmt: test colon test {

   // if(current==NULL) //cout<<"NO"<<endl;
   // //cout<<"!!!!!!!!!!!!!!!!!!!!!"<<current->type<<endl;
   // if($1==NULL) //cout<<"$1=NULL"<<endl;
    if(!$1->isLeaf) yyerror("Error in declaration");

    if(!$3->isCheck) {
        if(global_table->children.find($3->name)==global_table->children.end() || global_table->children[$3->name]->type!="class") yyerror("type not present");   
        $3->isCheck=true;
        $3->type=global_table->children[$3->name]->type;
        $3->l_value=false;
        $3->isLeaf=false;
        //cout<<"check done"<<endl;
    }
    if($3->type!="class") yyerror("Unexpected type in declaration");
    //cout<<"I did come here"<<endl;
    //cout<<current->type<<"   gggggggggggg    "<<current->name<<endl;
    
    sizee=calcsize($1->name, $3->name);
   if(current->type=="function" && current->name=="__init__" && init_dec){
    
    add_symbol(current->parent, $1->name, $3->name, line_no,false,off, sizee, num_of, $3->isList);
        add_symbol(current, $1->name, $3->name, line_no,false,off, sizee, num_of, $3->isList);
        current->parent->ordered_var.push_back($1->name);



         off+=sizee;
         //cout<<"hhhhhhhhhhhh_________"<<off<<"_________________"<<endl;
        // current->parent[$1->name]->isList=true;
    }
   
    // else if(!$3->isLeaf) yyerror("type not present");
    // else if(global_table->children.find($3->name)==global_table->children.end()) yyerror("type not present");
    else add_symbol(current, $1->name, $3->name, line_no,false,off, sizee, num_of,  $3->isList);
   init_dec=0;
   num_of=1;
   sizee=0;
$$=NULL;
}
|test colon test EQUAL {
    //cout<<"hi"<<$3->type<<endl;
    //obj_decl=1;
    if($3->isList && $3->isCheck ) {list_name=$1->tempvar; list_type=$3->name;}
} test {
    //cout<<"list_name="<<list_name<<"!!!!!!!!"<<endl;
  // obj_decl=0;
// cout<<sizee<<endl;
// sizee=0;
//cout<<"I got here"<<endl;
    if(!$1->isLeaf || $1->isConst) yyerror("Error in declaration");
     if(!$3->isCheck) {
        if(global_table->children.find($3->name)==global_table->children.end()|| global_table->children[$3->name]->type!="class") yyerror("type not present");
        $3->isCheck=true;
        $3->type=global_table->children[$3->name]->type;
        $3->l_value=false;
        $3->isLeaf=false;
    }
    if($3->type!="class") yyerror("Unexpected type in declaration");
    
    //cout<<"I am done"<<endl;
    //int size=0;
    if(!$6->isCheck && !$6->isConst){
        auto v2=find_var($6->name,current);
        if(v2==NULL) yyerror("No such variable found");
        fill_node($6, v2);
        sizee=v2->size;
        $6->isCheck=true;
        
        sizee=v2->size;
    }
    if($6->isConst) sizee=calcsize($6->name, $6->type);
    //cout<<"________________________<<<<<"<<sizee<<endl;
     gstr_len=$6->str_len;
    if($6->type=="function"){
        if(!func_assign($3->name, $6->ret_type))   yyerror("type mismatch ");
        sizee=calcsize("dumb", $6->ret_type);
        // if($3->name==$6->ret_type) ;
        // else if(!for_augasign($3->name, $6->ret_type)) yyerror("type mismatch  333");
        ///fucntions cannot return lists.
       // if(!($3->isList == $6->isList)) yyerror("type mismatch");
       string temp=newtemp();
       fillin("=",$6->tempvar,$3->name,temp);
       $6->tempvar=temp;
    
    }
       
    else {
      
           // if($6->isConst) size=calcsize($6->name, $6->type);
          //  if(sizee==0) sizee=calcsize("", $6->type);
        //  if($6->isList) sizee=list_siz;
         if(sizee==0)  sizee=calcsize("dumb", $6->type);
         
         if($6->isList) {//cout<<"whyyyyyyyyyyy"<<list_siz<<endl;
         sizee=list_siz;list_siz=0;
          }
        if(!$6->isinitial && $6->isConst==0) yyerror("variable not initialised");
        if(!func_assign($3->name, $6->type))   yyerror("type mismatch");
      //  if(!for_augasign($3->name, $6->type)) yyerror("type mismatch 1111");
    if(!($3->isList == $6->isList)) yyerror("type list");
    }
    
    /*if(current->type=="function" && current->name=="__init__" && init_dec){
        // cout<<$1->name<<"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"<<endl;
  add_symbol(current->parent, $1->name, $3->name, line_no, true,off,sizee, num_of, $3->isList);
     add_symbol(current, $1->name, $3->name, line_no,true,off,sizee, num_of,  $3->isList);
    
      off+=sizee;

     
     
    }
    
    else add_symbol(current, $1->name, $3->name, line_no,true,off,sizee, num_of,  $3->isList);
    init_dec=0;*/
    if(!$3->isList && !class_decl && !obj_decl && !$6->list_access)
    {
        fillin("=",$6->tempvar,"",$1->name );
    } 
    else if(class_decl_init && !$6->list_access)
    {
        string temp= newtemp();
        string offset=to_string(off); //search in the symbol table for $1->tempvar(has the name of the variable) and take it's offset.
        //cout<<"obj_base_addr is= "<<obj_base_addr<<" !!!!!!"<<endl;
        fillin("-",obj_base_addr,offset,temp); //this has the address of the oject variable.
        fillin("=",$6->tempvar,"","*"+temp);
        
       // fillin("pushh",obj_base_addr,to_string((current->parent->inherited_size)),current->parent->name);
    }
   
    else if($6->list_access){
       // cout<<$6->name<<"My lifeeeeeeeeeeeeeeeeee"<<$6->list_access<<endl;
        fillin("=","*"+$6->tempvar,"",$1->tempvar );
    }
    if(current->type=="function" && current->name=="__init__" && init_dec){
        // cout<<$1->name<<"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"<<endl;
  add_symbol(current->parent, $1->name, $3->name, line_no, true,off,sizee, num_of, $3->isList);
     add_symbol(current, $1->name, $3->name, line_no,true,off,sizee, num_of,  $3->isList);
      current->parent->ordered_var.push_back($1->name);
      off+=sizee;

     
     
    }
    
    else add_symbol(current, $1->name, $3->name, line_no,true,off,sizee, num_of,  $3->isList);
    init_dec=0;
    
    // cout<<$6->name<<"My lifeeeeeeeeeeeeeeeeee"<<$6->list_access<<endl;
sizee=0;
num_of=1;
$$->str_len=$6->str_len;
    
}
| test augasign test {
    if(!$1->l_value) yyerror("Cannot be assigned");
    if($1->isConst) yyerror("cannot assign to constant");
    
    if(!$1->isCheck)  {
        auto v1=find_var($1->name,current);
        if(v1==NULL) yyerror("variable not found ");
        fill_node($1, v1);
        // if($1->isList) $1->isLeaf=false;
        $1->isCheck=true;
        }
        if(!$1->isinitial) yyerror("Variable has not been initialsed");
    if(!$3->isCheck  && !$3->isConst) {
        auto v2=find_var($3->name,current);
        if(v2==NULL) yyerror("variable not found 36");
        fill_node($3, v2);
        //if($3->isList) $3->isLeaf=false;
        $3->isCheck=true;
    }

    if($3->type=="function"){
        if(!for_augasign($1->type, $3->ret_type)) yyerror("type mismatch 3");
         string temp=newtemp();
       fillin("=",$3->tempvar,"",temp);
       $3->tempvar=temp;
    }
    // a:int =2.5 a=2
      else {
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
        if(!for_augasign($1->type, $3->type)) yyerror("type mismatch 2");
        if($1->isList || $3->isList) yyerror("type mismatch list");
      }
     if(!$1->list_access && !$3->list_access)
    {
        if($2->name== "-=")
        fillin("-",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "+=")
        fillin("+",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "*=")
        fillin("*",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "/=")
        fillin("/",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "//=")
        fillin("//",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "%=")
        fillin("%",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "**=")
        fillin("**",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "&=")
        fillin("&",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "|=")
        fillin("|",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "^=")
        fillin("^",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== "<<=")
        fillin("<<",$1->tempvar,$3->tempvar , $1->tempvar); 
        if($2->name== ">>=")
        fillin(">>",$1->tempvar,$3->tempvar , $1->tempvar); 
    }
    else if($1->list_access && !$3->list_access)
    {
        if($2->name== "-=")
        fillin("-","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "+=")
        fillin("+","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "*=")
        fillin("*","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "/=")
        fillin("/","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "//=")
        fillin("//","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "%=")
        fillin("%","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "**=")
        fillin("**","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "&=")
        fillin("&","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "|=")
        fillin("|","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "^=")
        fillin("^","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "<<=")
        fillin("<<","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
        if($2->name== ">>=")
        fillin(">>","*"+$1->tempvar,$3->tempvar , "*"+$1->tempvar); 
    }
    else if(!$1->list_access && $3->list_access)
    {
        if($2->name== "-=")
        fillin("-",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "+=")
        fillin("+",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "*=")
        fillin("*",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "/=")
        fillin("/",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "//=")
        fillin("//",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "%=")
        fillin("%",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "**=")
        fillin("**",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "&=")
        fillin("&",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "|=")
        fillin("|",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "^=")
        fillin("^",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== "<<=")
        fillin("<<",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
        if($2->name== ">>=")
        if($2->name== ">>=")
        fillin(">>",$1->tempvar, "*"+$3->tempvar , $1->tempvar); 
    }
    else
    {
         if($2->name== "-=")
        fillin("-","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "+=")
        fillin("+","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "*=")
        fillin("*","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "/=")
        fillin("/","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "//=")
        fillin("//","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "%=")
        fillin("%","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "**=")
        fillin("**","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "&=")
        fillin("&","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "|=")
        fillin("|","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "^=")
        fillin("^","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== "<<=")
        fillin("<<","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
        if($2->name== ">>=")
        fillin(">>","*"+$1->tempvar, "*"+$3->tempvar , "*"+$1->tempvar); 
   
    //// type matches and mismatch 
    /// isleaf ... then check find_var and write the type and then do the type checking
    // same in test equal test
}}
| test {
    // if($1->type=="function") {
    //     if(!find_func($1->name, current) && global_table->children.find($1->name)==global_table->children.end()) yyerror("function not found");

    // }
    // else {
    //     if(find_var($1->name, current)==NULL) yyerror("variable not found 35");
    // }
    // if($1==NULL) //cout<<"kill ypurself"<<endl;
    if(!$1->isCheck && !$1->isConst)  {
        auto v1=find_var($1->name,current);
        if(v1==NULL) yyerror("variable not found ");
        fill_node($1, v1);
        $1->isCheck=true;
        }
        
        
       if($1->list_access){
        string temp=newtemp();
        fillin("=", "*"+temp,"", $1->tempvar);
        $$->tempvar=temp;
        $$->list_access=0;
       }
    
    //// or can be a class constructor
}
| test EQUAL{
    if(!$1->isCheck && $1->l_value){
        auto v1=find_var($1->name, current);
        if(v1!=NULL){
            list_type= v1->type;
        }
    }
} test{
   
    if(!$1->l_value) yyerror("cannot be assigned");
     if(!$4->isCheck  && !$4->isConst) {
        auto v2=find_var($4->name,current);
        if(v2==NULL) yyerror("variable not found 32");
        fill_node($4, v2);
        $4->isCheck=true;
    }
    gstr_len=$4->str_len;
    if(!$1->isCheck)  {
        auto v1=find_var($1->name,current);
      //  //cout<<"1"<<endl;
        if(v1==NULL) yyerror("variable not found 33");
        v1->isinitial=true;
        v1->str_len=gstr_len;
        //cout<<"2"<<endl;
        fill_node($1, v1);
        $1->isCheck=true;
        }
   
    if($4->type=="function"){
        if(!func_assign($1->type, $4->ret_type)) yyerror("type mismatch 1");
         string temp=newtemp();
       fillin("=",$4->tempvar,"",temp);
       $4->tempvar=temp;
    }
    // a:int =2.5 a=2
      else {
        //cout<<$1->type<<"         "<<$4->type<<endl;
//if($4->isinitial) //cout<<"I am right abt it"<<endl;
        if(!$4->isinitial && !$4->isConst) yyerror("Variable uninitialsed ");
        if(!func_assign($1->type, $4->type)) yyerror("type mismatch 0");
      if(!($1->isList==$4->isList)) yyerror("type list error");
      
      }
    if(!$1->list_access && !$4->list_access)
    fillin("=",$4->tempvar,"",$1->tempvar);
    if($1->list_access && !$4->list_access)
  
    fillin("=", $4->tempvar,"", "*"+$1->tempvar);
     if(!$1->list_access && $4->list_access)
    fillin("=", "*"+$4->tempvar,"", $1->tempvar);
     if($1->list_access && $4->list_access)
    fillin("=", "*"+$4->tempvar,"", "*"+$1->tempvar);
    $$->str_len=$4->str_len;
    // if(current->tab.find($1)==current->tab.end()) yyerror("vUndeclared variable being used");
};

/*

annasign : colon test {
   
}
| colon test EQUAL test{
    
};
*/

augasign: plus_eq {$$->name=$1->name;}
| minus_eq {$$->name=$1->name;}
| star_eq  {$$->name=$1->name;}
| slash_eq  {$$->name=$1->name;}
| double_slash_eq {$$->name=$1->name;}
| mod_eq {$$->name=$1->name;}
| double_star_eq  {$$->name=$1->name;}
| a_eq {$$->name=$1->name;}
| o_eq {$$->name=$1->name;}
| x_eq {$$->name=$1->name;}
| lshift_eq {$$->name=$1->name;}
| rshift_eq {$$->name=$1->name;};

flow_stmt: break_stmt{$$=$1;}
|continue_stmt {$$=$1;}
|return_stmt 
    
break_stmt: BREAK {fillin("goto","","","");
pt.push_back(code.back());
brek=1;

};
continue_stmt: CONTINUE{
  fillin("goto","","","");
pt.push_back(code.back());
    cont=1;};

return_stmt: RETURN {
     if(current->ret_type!="None") yyerror("Expected return value");
     fillin("return","None","","");
}
| RETURN test{

    //cout<<"I am good"<<endl;
    if(expect_return==0) yyerror("Unexpected return value");
   
   got_ret=1;
    if(!$2->isCheck && !$2->isConst) {
        auto v1= find_var( $2->name, current);
        if(v1==NULL) yyerror("variable not found");
        fill_node($2, v1);
        $2->isCheck=true;
    }
    //cout<<$2->type<<" in ret_stmt"<<endl;
    //cout<<current->ret_type<<"func ret_type in ret_stmt"<<endl;
    //cout<<"hhhhhhhhh"<<$2->type<<endl;
    
    if($2->type=="function"){
            if(!func_assign(current->ret_type, $2->ret_type)) yyerror("return type does not match"); /////function make new//////////////////////////////

    }
    else{
        if(!$2->isConst && !$2->isinitial) yyerror("variable not initialsed");
    if(!func_assign(current->ret_type, $2->type)) yyerror("return type does not match");
    } /////function make new//////////////////////////////
    fillin("return",$2->tempvar,"","");
};

compound_stmt: if_stmt|while_stmt|for_stmt|funcdef|classdef {
};

if_stmt: IF seen_if test add4 colon extralabel suite {
    // cout<<"iff"<<endl;
    string temp= newLabel(); fillin("label",temp+":","",""); 
    // cout<<"false listtt"<<endl;
    // for(auto i:$3->falselist){
    //     cout<<i->result<<endl;
    // }
    backpatch($3->falselist, temp);
    //if($3->falselist.empty()) cout<<"it's empty!!!!!"<<endl;
    backpatch($3->truelist, $6->tempvar); 
    } 
| IF seen_if test add4 colon extralabel suite extralabel_if ELSE colon suite {
    string temp= newLabel(); 
    fillin("label",temp+":","",""); //label of after suite
    backpatch($3->falselist, $8->tempvar); 
    backpatch($3->truelist, $6->tempvar); 
    backpatch($8->truelist, temp);}
| IF seen_if test add4 colon extralabel suite extralabel_if elif_star {
   
    string temp= newLabel(); 
    //  cout<<"out of if 1"<<endl;
        fillin("label",temp+":","",""); //label of after suite
        //  cout<<"out of if 2"<<endl;
        //  cout<<($3->falselist).size()<<endl;
        //  for(auto i:$3->falselist){
        //     cout<<i->result<<i->op<<i->arg1<<i->arg2<<endl;
        //  }
        backpatch($3->falselist, $8->tempvar); 
        //  cout<<"out of if 3"<<endl;
        backpatch($3->truelist, $6->tempvar); 
        backpatch($8->truelist, temp); //if any of the else ifs is true, jump to after that if-else block
        backpatch($9->truelist, temp);
        
        // cout<<"out of if"<<endl;
        //there is no problem with false list of elif_star, just fall
};
elif_star: elif seen_if test add4 colon extralabel suite  {
                $$=new Node(); //this has the last elif
                //if this elif is false, jump to the next label
                backpatch($3->truelist, $6->tempvar); 
                $$->truelist= $3->falselist; 
            }
|elif seen_if test add4 colon extralabel suite extralabel_if ELSE colon suite {
    // cout<<"I ccccccccccccccccccccccccccccccccccccccccccccccccc"<<endl;
        //will be the last else, backpatch the true list of elif_star with the new label of after suite 
        $$= new Node();
        backpatch($3->falselist, $8->tempvar);
        backpatch($3->truelist, $6->tempvar);
        $$->truelist= $8->truelist; 
        // cout<<"out of elif"<<endl;
        // cout<<"NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"<<endl;
        //when else is taken, just fall.
    }
| elif seen_if test add4 colon extralabel suite extralabel_if elif_star{
    $$=$8;
    backpatch($3->truelist, $6->tempvar);
     backpatch($3->falselist, $8->tempvar); //if the current elif is false, go to the next.
     //$2 's truelist is just fall.
    $$->truelist=merge_list($9->truelist, $8->truelist); 
    //the $5 's truelist has the- if any of the else ifs is true, jump to after that if-else block
}; 

extralabel_if: {string temp= newLabel(); 
                    fillin("","","goto",""); //this goes right after the suite.
                    quadraple* last_element;

                    // cout<<"isss the codeee emptyyy"<<endl;
                    if (!code.empty()) {
                        // cout<<"herein iff"<<endl;
                        last_element = code.back();
                    }
                    fillin("label",temp+":","",""); 
                    $$= new Node();//agar func nahi hai tho likhna hai
                    ($$)->tempvar=temp;//changed moksha
                    $$->truelist.push_back(last_element);
                };

seen_if: { flow_st=1;   };
add4: {
    // checking =0;
    if($<node>0->isCheck==0 && $<node>0->isConst!=1){
        auto v1=find_var( $<node>0->name, current);
        if(v1==NULL) yyerror("Variable used but not declared 456");
        else fill_node($<node>0, v1);
        $<node>0->isCheck=false;
    }
    if(!$<node>0->isinitial && !$<node>0->isConst) yyerror("Variable uninitialsed");
}



while_stmt: WHILE extralabel seen_while test add4 colon extralabel suite {
    string temp=newLabel();
    fillin("","","goto",$2->tempvar);
    fillin("label",temp+":","","");
    backpatch($4->falselist, temp);
    backpatch($4->truelist, $7->tempvar);
    if(brek){
        backpatch(pt,temp);
        pt.clear();
        brek=0;
    }
    else if(cont){
        backpatch(pt,$2->tempvar);
         pt.clear();
        cont=0;
    }

    
}   ////similarly we can use begin label ig
| WHILE extralabel seen_while test add4 colon extralabel suite loop_extra extralabel ELSE colon suite {
    //string temp=newLabel();
    //fillin("label",temp+":","","");
    backpatch($4->falselist, $10->tempvar);
    backpatch($4->truelist, $8->tempvar);
    if(brek){
        backpatch(pt,$13->tempvar);
        pt.clear();
        brek=0;
    }
    else if(cont){
        backpatch(pt,$2->tempvar);
         pt.clear();
        cont=0;
    }

};

seen_while: {flow_st=1;};

loop_extra: {fillin("","","goto",""); $$= new Node(); $$->truelist.push_back((code.back()));};
for_stmt: FOR var Ineed in test extralabel2 colon suite {
   // is_range=0;
    string temp1=newtemp();
    fillin("+",for_var,"1",temp1);
    fillin("=",temp1,"",for_var);
    string temp=newLabel();
    fillin("","","goto",$6->tempvar); //this comes right after suite
    backpatch($6->falselist, temp);
    fillin("label",temp+":","",""); 
    if(brek){
        backpatch(pt,temp);
        pt.clear();
        brek=0;
    }
    else if(cont){
        backpatch(pt,$6->tempvar);
         pt.clear();
        cont=0;
    }

}
| FOR var Ineed in test extralabel2 colon suite loop_extra extralabel ELSE colon suite{
    //is_range=0;
    string temp=newLabel();
    backpatch($9->truelist, $6->tempvar);
    backpatch($6->falselist, $10->tempvar);

    //cout<<"I am emptyyyyyyyyyyyyyyyyyy"<<endl;
      if(brek){
        backpatch(pt,temp);
        pt.clear();
        brek=0;
        fillin("label",temp+":","","");
    }
    else if(cont){
        backpatch(pt,$6->tempvar);
        pt.clear();
        cont=0;
    }

};
Ineed:{for_var=$<node>0->name;}
extralabel2:{$$=new Node(); 
                 fillin("=",val_range1,"",for_var);   
                string temp= newLabel(); 
                fillin("label",temp+":","",""); 
             //   string temp1=newtemp();
              // fillin("<",for_var,val_range1,temp1); 
                string temp4=newtemp();   
                fillin("<",for_var,val_range,temp4);
                fillin("if_F",temp4,"goto","");
                quadraple* ptr_to_last_element;
                        if (!code.empty()) {
                            ptr_to_last_element = code.back();
                        }
                $$->falselist.push_back(ptr_to_last_element);
                $$->tempvar=temp;  flow_st=0;  
                }
suite:simple_stmt {$$=$1;}
|NEWLINE indent {
//     checking=1;
//   if(checking==0)
//         {//add_symbol(current, name, "", line_no, false);
//         current= new Symbol_table(current, line_no,"");
//         current->type="";
//        current->name="";

//         }
       

       
        }  stmt_plus dedent{
            
             // cout<<"i was rightly called though"<<checking<<endl;

//        if(checking==0) {current=current->parent;}
//        if(current->type=="function") checking=1;
//   // cout<<"i was rightly called though"<<endl;

       
//     $$=$4;
    $$=NULL;}
        // }

test: or_test {$$=$1;
 
if(flow_st && !$1->filled_flow && !middle_oflist_access)
 {   //cout<<"I ateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee 4"<<endl;
     if($1->list_access)
     {
        fillin("if_T",$$->tempvar,"goto","");//this case needs a jump
                        quadraple* ptr_to_last_element;
                        if (!code.empty()) {
                            ptr_to_last_element = code.back();
                        }
                        $$->truelist.push_back(ptr_to_last_element);
                        fillin("if_F",$$->tempvar,"goto","");
                        ptr_to_last_element=code.back();
                         $$->falselist.push_back(ptr_to_last_element);
     }
     else{
        fillin("if_T",$$->tempvar,"goto","");//this case needs a jump
                        quadraple* ptr_to_last_element;
                        if (!code.empty()) {
                            ptr_to_last_element = code.back();
                        }
                        $$->truelist.push_back(ptr_to_last_element);
                        fillin("if_F",$$->tempvar,"goto","");
                        ptr_to_last_element=code.back();
                         $$->falselist.push_back(ptr_to_last_element);
     }
    $$->filled_flow=1;
 } 
};
//asssuming if an or or and is seen, it's flow is written for sure!!
or_test:and_test {$$=$1;}
| or_test OR extralabel1 and_test{
    $$=$1;
    if(!$1->isCheck && !$1->isConst){
    auto v1=find_var($1->name, current);
    if(v1==NULL) yyerror("No such variable found");
    fill_node($1, v1);
    $1->isCheck=true;
     
}

if(!$4->isCheck && !$4->isConst){
    auto v2=find_var($4->name, current);
    if(v2==NULL) yyerror("No such variable found");
    fill_node($4, v2);
    $4->isCheck=true;
}
if($1->type=="class" || $4->type=="class") yyerror("Comaprison cannot be performed");
if($1->type=="function"){
    if($4->type=="function"){
       // if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
       // if(!for_augasign($1->ret_type, $4->ret_type)) yyerror("Incompatible types");
       ;
    }
    else {
        if(!$4->isinitial && !$4->isConst) yyerror("Variable uninitialsed");
       // if(!for_augasign($1->ret_type, $4->type)) yyerror("Incompatible types");
    }
}
else{
    if($4->type=="function"){
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
       // if(!for_augasign($1->type, $4->ret_type)) yyerror("Incompatible types");
    }
    else {
        if(!$4->isinitial && !$4->isConst) yyerror("Variable uninitialsed");
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
       // if(!for_augasign($1->type, $4->type)) yyerror("Incompatible types");
    }
}
$$=$1;
$$->type="bool";
$$->l_value=false;
$$->isLeaf=false;
$$->isCheck=true;
  //cout<<"I ateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee 5"<<endl;
if(!$4->filled_flow)
 {
     fillin("if_T",$4->tempvar,"goto","");//this case needs a jump
                        quadraple* ptr_to_last_element;
                        if (!code.empty()) {
                            ptr_to_last_element = code.back();
                        }
                        $4->truelist.push_back(ptr_to_last_element);
                        fillin("if_F",$4->tempvar,"goto","");
                        ptr_to_last_element=code.back();
                         $4->falselist.push_back(ptr_to_last_element);
                         $4->filled_flow=1;

 }
backpatch($1->falselist, $3->tempvar);
$$->truelist=merge_list($1->truelist, $4->truelist);
$$->falselist=$4->falselist;
$$->filled_flow=1;
};

and_test:not_test {$$=$1;
if(flow_st && !$1->filled_flow && !middle_oflist_access)
 { // cout<<"I ateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee 6"<<endl;
 if($1->list_access)
 {
    fillin("if_T","*"+$$->tempvar,"goto","");//this case needs a jump
                        quadraple* ptr_to_last_element;
                        if (!code.empty()) {
                            ptr_to_last_element = code.back();
                        }
                        $$->truelist.push_back(ptr_to_last_element);
                        fillin("if_F","*"+$$->tempvar,"goto","");
                        ptr_to_last_element=code.back();
                         $$->falselist.push_back(ptr_to_last_element);
 }
 else{
    fillin("if_T",$$->tempvar,"goto","");//this case needs a jump
                        quadraple* ptr_to_last_element;
                        if (!code.empty()) {
                            ptr_to_last_element = code.back();
                        }
                        $$->truelist.push_back(ptr_to_last_element);
                        fillin("if_F",$$->tempvar,"goto","");
                        ptr_to_last_element=code.back();
                         $$->falselist.push_back(ptr_to_last_element);
 }
    $$->filled_flow=1;
 } 

}
|and_test AND extralabel1 not_test{

    if(!$1->isCheck && !$1->isConst){
    auto v1=find_var($1->name, current);
    if(v1==NULL) yyerror("No such variable found");
    fill_node($1, v1);
    $1->isCheck=true;
}

if(!$4->isCheck && !$4->isConst){
    auto v2=find_var($4->name, current);
    if(v2==NULL) yyerror("No such variable found");
    fill_node($4, v2);
    $4->isCheck=true;
}
if($1->type=="class" || $4->type=="class") yyerror("Comaprison cannot be performed");
if($1->type=="function"){
    if($4->type=="function"){
        ;
       // if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
       // if(!for_augasign($1->ret_type, $3->ret_type)) yyerror("Incompatible types");
    }
    else {
        if(!$4->isinitial && !$4->isConst) yyerror("Variable uninitialsed");
       // if(!for_augasign($1->ret_type, $3->type)) yyerror("Incompatible types");
    }
}
else{
    if($4->type=="function"){
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
       // if(!for_augasign($1->type, $3->ret_type)) yyerror("Incompatible types");
    }
    else {
        if(!$4->isinitial && !$4->isConst) yyerror("Variable uninitialsed");
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
      //  if(!for_augasign($1->type, $3->type)) yyerror("Incompatible types");
    }
}
$$=$1;
$$->type="bool";
$$->l_value=false;
$$->isLeaf=false;
$$->isCheck=true;

 if(!$4->filled_flow)
 {  // cout<<"I ateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee 10"<<endl;
     fillin("if_T",$4->tempvar,"goto","");//this case needs a jump
                        quadraple* ptr_to_last_element;
                        if (!code.empty()) {
                            ptr_to_last_element = code.back();
                        }
                        $4->truelist.push_back(ptr_to_last_element);
                        fillin("if_F",$4->tempvar,"goto","");
                        ptr_to_last_element=code.back();
                         $4->falselist.push_back(ptr_to_last_element);
                         $4->filled_flow=1;

 }
backpatch($1->truelist, $3->tempvar);
$$->falselist=merge_list($1->falselist, $4->falselist);
                    //$$->falselist=merge_list($1->falselist, $3->falselist);
$$->truelist=$4->truelist;
 $$->filled_flow=1;

};
extralabel1:{//generates extralabel but just doesn't make flow_st 0
                    $$=new Node();  string temp= newLabel(); fillin("label",temp+":","",""); $$->tempvar=temp;  
                };
        

extralabel: { $$=new Node(); string temp= newLabel(); fillin("label",temp+":","",""); $$->tempvar=temp;  flow_st=0;  };
not_test: NOT got_not not_test {
    if(!$3->isCheck && !$3->isConst){
    auto v1=find_var($3->name, current);
    if(v1==NULL) yyerror("No such variable found");
    fill_node($3, v1);
    $3->isCheck=true;
    }
    if($3->type=="class") yyerror("No such operation possible");
            if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");

    $$=$3;
    $$->type="bool";
    $$->name="";
    $$->l_value=false;
    $$->isLeaf=false;
    $$->isCheck=true;
    $$->filled_flow=1;
    //  cout<<"I ateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee 2"<<endl;
    fillin("if_T",$3->tempvar,"goto","");//this case needs a jump
                        quadraple* ptr_to_last_element;
                        if (!code.empty()) {
                            ptr_to_last_element = code.back();
                        }
                     //fillin("if_F",$3->tempvar,"fall","");//this case needs a fall
                      $$->falselist.push_back(ptr_to_last_element);
                      fillin("if_F",$3->tempvar,"goto","");
                      if (!code.empty()) {
                            ptr_to_last_element = code.back();
                        }
                        $$->truelist.push_back(ptr_to_last_element);
                        got_not1=0;


}
 | comparison {
               
            
               if(flow_st && inside_flow_comp && !got_not1)
               {     $1->filled_flow=1;    
           //  cout<<"I ateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee 1"<<endl;
                     fillin("if_F",$1->tempvar,"goto","");//this case needs a jump
                     quadraple* ptr_to_last_element;
                    if (!code.empty()) {

                          // cout<<"I am here andhar!!!"<<endl;
                        ptr_to_last_element = code.back();

                    }
                    $1->falselist.push_back(ptr_to_last_element);
                    fillin("if_T",$1->tempvar,"goto","");
                    if (!code.empty()) {

                          // cout<<"I am here andhar!!!"<<endl;
                        ptr_to_last_element = code.back();
                    }
                    $1->truelist.push_back(ptr_to_last_element);
                    // if($1->falselist.empty()) cout<<"it's empty!!!!!!!"<<endl;
                     //fillin("if_T",$1->tempvar,"fall","");//this case needs a fall
               }
               $$=$1;
 };
got_not:{got_not1=1;};
comparison: expr{$$=$1; inside_flow_comp=0;}
|expr comp_op comparison{
    //if($2->name=="==") cout<<$1->name<<" "<<$3->name<<endl;
    if($1->name=="__name__" && $2->name=="==" && $3->name=="\"__main__\"") {return 0;}
    inside_flow_comp=1;
    if(!$1->isCheck && !$1->isConst){
    auto v1=find_var($1->name, current);
    if(v1==NULL) yyerror("No such variable found");
    fill_node($1, v1);
    $1->isCheck=true;
}

if(!$3->isCheck && !$3->isConst){
    auto v2=find_var($3->name, current);
    if(v2==NULL) yyerror("No such variable found");
    fill_node($3, v2);
    $3->isCheck=true;
}
//cout<<$1->type<<"yyyyyyyyyyyyyyyyyyyyyyyyyy"<<endl;
//cout<<$3->name<<endl;
if($1->type=="class" || $3->type=="class") yyerror("Comaprison cannot be performed");
if($1->type=="function"){
    if($3->type=="function"){
       // if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
        if(!func_assign($1->ret_type, $3->ret_type)) yyerror("Incompatible types");
    }
    else {
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
        if(!func_assign($1->ret_type, $3->type)) yyerror("Incompatible types");
    }
}
else{
    if($3->type=="function"){
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
        if(!func_assign($1->type, $3->ret_type)) yyerror("Incompatible types");
    }
    else {
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
        if(!func_assign($1->type, $3->type)) yyerror("Incompatible types");
    }
}
$$=$1;
$$->type="bool";
$$->l_value=false;
$$->isLeaf=false;
$$->isCheck=true;

string temp= newtemp();
//cout<<"list access of $1= "<<$1->list_access<<endl;
//cout<<"list access of $3= "<<$3->list_access<<endl;
    if(!$1->list_access && !$3->list_access)
    {
        if($2->name=="==")
        fillin("==", $1->tempvar, $3->tempvar, temp);
        if($2->name=="!=")
        fillin("!=", $1->tempvar, $3->tempvar, temp);
        if($2->name=="<")
        fillin("<", $1->tempvar, $3->tempvar, temp);
        if($2->name==">")
        fillin(">", $1->tempvar, $3->tempvar, temp);
        if($2->name==">=")
        fillin(">=", $1->tempvar, $3->tempvar, temp);
        if($2->name=="<=")
        fillin("<=", $1->tempvar, $3->tempvar, temp);
    }
    if($1->list_access && !$3->list_access)
    {
        if($2->name=="==")
        fillin("==", "*"+$1->tempvar, $3->tempvar, temp);
        if($2->name=="!=")
        fillin("!=", "*"+$1->tempvar, $3->tempvar, temp);
        if($2->name=="<")
        fillin("<", "*"+$1->tempvar, $3->tempvar, temp);
        if($2->name==">")
        fillin(">", "*"+$1->tempvar, $3->tempvar, temp);
        if($2->name==">=")
        fillin(">=", "*"+$1->tempvar, $3->tempvar, temp);
        if($2->name=="<=")
        fillin("<=", "*"+$1->tempvar, $3->tempvar, temp);
    }
    if(!$1->list_access && $3->list_access)
    {
        if($2->name=="==")
        fillin("==", $1->tempvar, "*"+$3->tempvar, temp);
        if($2->name=="!=")
        fillin("!=", $1->tempvar, "*"+$3->tempvar, temp);
        if($2->name=="<")
        fillin("<", $1->tempvar, "*"+$3->tempvar, temp);
        if($2->name==">")
        fillin(">", $1->tempvar, "*"+$3->tempvar, temp);
        if($2->name==">=")
        fillin(">=", $1->tempvar, "*"+$3->tempvar, temp);
        if($2->name=="<=")
        fillin("<=", $1->tempvar, "*"+$3->tempvar, temp);
    }
    if($1->list_access && $3->list_access)
    {
        //cout<<"inside list access!!!!!!!!!!!!!!1"<<endl;
        if($2->name=="==")
        fillin("==", "*"+$1->tempvar, "*"+$3->tempvar, temp);
        if($2->name=="!=")
        fillin("!=", "*"+$1->tempvar, "*"+$3->tempvar, temp);
        if($2->name=="<")
        fillin("<", "*"+$1->tempvar, "*"+$3->tempvar, temp);
        if($2->name==">")
        fillin(">", "*"+$1->tempvar, "*"+$3->tempvar, temp);
        if($2->name==">=")
        fillin(">=", "*"+$1->tempvar, "*"+$3->tempvar, temp);
        if($2->name=="<=")
        fillin("<=", "*"+$1->tempvar, "*"+$3->tempvar, temp);
    }
    $$->tempvar=temp;
};


comp_op: double_eq 
| NOT_EQ 
| GREATER  
| lesser  
| greater_eq  
| lesser_eq 
| is;
/////////////////////////////////  add bool ///////////////////////////////////////////////
expr:xor_expr 
| expr BIT_OR xor_expr{
    //cout<<"inside expression"<<endl;
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int" && t1!="bool" ) yyerror("Only number and bool allowed");
    if(t2!="int" && t1!="bool"  ) yyerror("Only number and bool allowed");
    $$=$1;
    $$->type="int";
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;
    $$->l_value=false;
     string n=newtemp();
                       //($$)->tempvar=n;
                       if(!$1->list_access && !$3->list_access)
                       fillin("|",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("|","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("|",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access&& $3->list_access)
                       fillin("|","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$->isLeaf=false;
                        ($$)->tempvar=n;
                         $$->list_access=0;
};

xor_expr: and_expr{$$=$1;}
| xor_expr BIT_XOR and_expr{
    //cout<<"inside expression"<<endl;
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int" && t1!="bool" ) yyerror("Only number allowed");
    if(t2!="int" && t1!="bool" ) yyerror("Only number allowed");
    $$=$1;
    $$->type="int";
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;
    $$->l_value=false;
     string n=newtemp();
                       //($$)->tempvar=n;
                       if(!$1->list_access && !$3->list_access)
                       fillin("^",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("^","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("^",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("^","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$->isLeaf=false;
                        ($$)->tempvar=n;
                         $$->list_access=0;
};

and_expr:shift_expr {$$=$1;}
| and_expr BIT_AND shift_expr{
    
    //cout<<"inside expression"<<endl;
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int" && t1!="bool" ) yyerror("Only number allowed");
    if(t2!="int" && t1!="bool" ) yyerror("Only number allowed");
    $$=$1;
    $$->type="int";
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;
    $$->l_value=false;
    string n=newtemp();
                       //($$)->tempvar=n;
                       if(!$1->list_access && !$3->list_access)
                       fillin("&",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("&","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("&",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("&","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$->isLeaf=false;
                        ($$)->tempvar=n;
                         $$->list_access=0;
};

shift_expr:arith_expr{ $$=$1;}
|shift_expr lshift arith_expr{
    //cout<<"inside expression"<<endl;
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed 1");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed 2");
    }
    if(t1!="int" && t1!="bool" ) yyerror("Only number allowed");
    if(t2!="int" && t1!="bool" ) yyerror("Only number allowed");
    $$=$1;
    $$->type="int";
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;
    $$->l_value=false;
     string n=newtemp();
                       //($$)->tempvar=n;
                       if(!$1->list_access && !$3->list_access)
                       fillin("<<",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("<<","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("<<",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("<<","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$->isLeaf=false;
                        ($$)->tempvar=n;
                         $$->list_access=0;
}
|shift_expr rshift arith_expr{
    //cout<<"inside expression"<<endl;
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int"  && t1!="bool") yyerror("Only number allowed");
    if(t2!="int"  && t1!="bool") yyerror("Only number allowed");
    $$=$1;
    $$->type="int";
    $$->name="";
    $$->l_value=false;
    $$->isLeaf=false;
    $$->isCheck=true;
    string n=newtemp();
                       if(!$1->list_access && !$3->list_access)
                       fillin(">>",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin(">>","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin(">>",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin(">>","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                       $$->isLeaf=false;
                        ($$)->tempvar=n;
                         $$->list_access=0;
};

arith_expr:term
|arith_expr PLUS term {


    //cout<<"inside expression"<<endl;
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
        

    }
    else {
        
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed ");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
       
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    //cout<<t1<<"1 this is the issue"<<endl;
    //cout<<$3->type<<"3 this is the issue"<<endl;
    if(t1!="int" && t1!="float" && t1!="bool" ) yyerror("Only number allowe 1");
    if(t2!="int" && t2!="float" && t2!="bool" ) yyerror("Only number allowed 2");
    $$=$1;
    $$->type=find_typediv(t1, t2);/////////////////////////////////check it///////////////////////
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;
    $$->l_value= false;
    
    string n=newtemp();
                       if(!$1->list_access && !$3->list_access)
                       {//cout<<"both are not lists!!!"<<endl;
                       fillin("+",($1)->tempvar,($3)->tempvar,n);}
                       if($1->list_access && !$3->list_access)
                       fillin("+","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("+",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("+","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$=$1;
                       $$->isLeaf=false;
                       ($$)->tempvar=n;
                       $$->list_access=0;
}
|arith_expr MINUS term{
   if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int" && t1!="float" && t1!="bool" ) yyerror("Only number allowed");
    if(t2!="int" && t2!="float"&& t2!="bool" ) yyerror("Only number allowed");
    $$=$1;
     $$->type=find_typediv(t1, t2);
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;
     string n=newtemp();
                       if(!$1->list_access && !$3->list_access)
                       fillin("-",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("-","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("-",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("-","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$=$1;
                       $$->isLeaf=false;
                       ($$)->tempvar=n;
                        $$->list_access=0;
};

term:factor {$$=$1;}
|term star factor {
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int" && t1!="float" && t1!="bool" ) yyerror("Only number allowed");
    if(t2!="int" && t2!="float" && t2!="bool" ) yyerror("Only number allowed");
    $$=$1;
    $$->type=find_typediv(t1, t2);
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;
    $$->l_value =false;
    string n=newtemp();
                       //($$)->tempvar=n;
                       if(!$1->list_access && !$3->list_access)
                       fillin("*",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("*","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("*",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("*","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$=$1;
                       $$->isLeaf=false;
                       ($$)->tempvar=n;
                        $$->list_access=0;
}

|term slash factor {
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int" && t1!="float" && t1!="bool" ) yyerror("Only number allowed");
    if(t2!="int" && t2!="float" && t1!="float") yyerror("Only number allowed");
    $$=$1;
  $$->type=find_typediv(t1, t2);
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;
    $$->l_value=false;

    string n=newtemp();
                      //($$)->tempvar=n;
                       if(!$1->list_access && !$3->list_access)
                       fillin("/",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("/","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("/",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("/","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$=$1;
                       $$->isLeaf=false;
                       ($$)->tempvar=n;
                        $$->list_access=0;
}
|term double_slash factor{
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int" && t1!="float" && t1!="bool" ) yyerror("Only number allowed");
    if(t2!="int" && t2!="float" && t2!="bool" ) yyerror("Only number allowed");
    $$=$1;
  $$->type=find_typediv(t1, t2);
    $$->name="";
    $$->isLeaf=false;
    $$->l_value=false;
    $$->isCheck=true;
    string n=newtemp();
                       //($$)->tempvar=n;
                       if(!$1->list_access && !$3->list_access)
                       fillin("//",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("//","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("//",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("//","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$=$1;
                       $$->isLeaf=false;
                       ($$)->tempvar=n;
                        $$->list_access=0;
}
|term mod factor{
    if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found 31");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found 30");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int" && t1!="float" && t1!="bool" ) yyerror("Only number allowed");
    if(t2!="int" && t2!="float" && t2!="bool" ) yyerror("Only number allowed");
    $$=$1;
    $$->type=$1->type;
    $$->l_value=false;
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;
    string n=newtemp();
                       //($$)->tempvar=n;
                       if(!$1->list_access && !$3->list_access)
                       fillin("%",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("%","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("%",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("%","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                        $$=$1;
                       $$->isLeaf=false;
                       ($$)->tempvar=n;
                        $$->list_access=0;
};

factor:PLUS factor  {
    if(!$2->isCheck && !$2->isConst) {
        auto v1= find_var($2->name, current);
        if(v1==NULL) yyerror("variable not found 4");
        fill_node($2, v1);
        $2->isCheck=true;
    }
    
    if($2->type=="function"){
        if($2->ret_type!="int" || $2->ret_type!="bool" || $2->ret_type!="float" ) yyerror("Only number allowed");
        //// off for list////// list 
    }
    else {
        if(!$2->isinitial && !$2->isConst) yyerror("Uninitilaised variable");
        if(($2->type!="int" && $2->type!="float" && $2->type!="bool")|| $2->isList) yyerror("Only number allowed");}
    $2->isLeaf=false;
    $2->isCheck=true;
    $$=$2;
    $$->l_value=false;
    string n=newtemp();
                       if(!$2->list_access)
                       fillin("+",($2)->tempvar,"",n); //unary op
                       else
                       fillin("+","*"+($2)->tempvar,"",n); //unary op
       ($$)->tempvar=n;
       $$->isLeaf=false;
     $$->list_access=0;
}
|MINUS factor {
    if(!$2->isCheck && !$2->isConst) {
        auto v1= find_var($2->name, current);
        if(v1==NULL) yyerror("variable not found 4");
        fill_node($2, v1);
        $2->isCheck=true;
    }
    
    if($2->type=="function"){
        if($2->ret_type!="int" || $2->ret_type!="bool" || $2->ret_type!="float" ) yyerror("Only number allowed");
        //// off for list////// list 
    }
    else {
        if(!$2->isinitial && !$2->isConst) yyerror("Uninitilaised variable");
        if(($2->type!="int" && $2->type!="float" && $2->type!="bool")|| $2->isList) yyerror("Only number allowed");}
    $2->isLeaf=false;
    $2->isCheck=true;
    $$=$2;
    $$->l_value=false;
                       auto n=newtemp();
                       //($$)->tempvar=n;
                       if(!$2->list_access)
                       fillin("-",($2)->tempvar,"",n); //unary op
                       else
                       fillin("-","*"+($2)->tempvar,"",n); //unary op
                       $$=$2;
                        ($$)->tempvar=n;
                        $$->isLeaf=false;
                         $$->list_access=0;

}
|BIT_NOT factor  {
    if(!$2->isCheck && !$2->isConst) {
        auto v1= find_var($2->name, current);
        if(v1==NULL) yyerror("variable not found 4");
        fill_node($2, v1);
        $2->isCheck=true;
    }
    
    if($2->type=="function"){
        if($2->ret_type!="int" || $2->ret_type!="bool" || $2->ret_type!="float" ) yyerror("Only number allowed st");
        //// off for list////// list 
    }
    else {
        if(!$2->isinitial && !$2->isConst) yyerror("Uninitilaised variable");
       // cout<<$2->type<<endl;
        //cout<<$2->isList<<endl;
        if(($2->type!="int" && $2->type!="bool" && $2->type!="float")|| $2->isList) yyerror("Only number allowed ");}
    $2->isLeaf=false;
    $2->isCheck=true;
    $$=$2;
    $$->l_value=false;
    string n=newtemp();
                      //($$)->tempvar=n;
                       if(!$2->list_access)
                       fillin("~",($2)->tempvar,"",n); //unary op
                       else
                       fillin("~","*"+($2)->tempvar,"",n); //unary op
                       $$=$2;
                    ($$)->tempvar=n;
                    $$->isLeaf=false;
                     $$->list_access=0;

}
|power {$$=$1;};


power:atom_expr { if(see==1) yyerror("Error"); //doubt
 //cout<<"Yes the error"<<endl;$$=$1;
 }
 |atom_expr double_star factor {
   if(!$1->isCheck && !$1->isConst) {
        auto v1= find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    if(!$3->isCheck && !$3->isConst) {
        auto v2= find_var($3->name, current);
        if(v2==NULL) yyerror("variable not found");
        fill_node($3, v2);
        $3->isCheck=true;
    }
    if($1->isList  || $3->isList) yyerror("Only number allowed");
    if($1->type=="class" || $3->type=="class") yyerror("classes are not allowed");
    string t1=$1->type, t2=$3->type;
    if($1->type=="function"){
        t1=$1->ret_type;
    }
    else {
        if(!$1->isinitial && !$1->isConst) yyerror("Variable uninitialsed");
    }
    if($3->type=="function"){
        t2=$3->ret_type;
    }
    else{
        if(!$3->isinitial && !$3->isConst) yyerror("Variable uninitialsed");
    }
    if(t1!="int" && t1!="float" ) yyerror("Only number allowed");
    if(t2!="int" ) yyerror("Only number allowed");
    $$=$1;
    $$->type=$1->type;
    $$->l_value=false;
    $$->name="";
    $$->isLeaf=false;
    $$->isCheck=true;

    string n=newtemp();
                //($$)->tempvar=n;
                //fillin("**",$1->tempvar,($3)->tempvar,n);
                        if(!$1->list_access && !$3->list_access)
                       fillin("**",($1)->tempvar,($3)->tempvar,n);
                       if($1->list_access && !$3->list_access)
                       fillin("**","*"+($1)->tempvar,($3)->tempvar,n);
                       if(!$1->list_access && $3->list_access)
                       fillin("**",($1)->tempvar,"*"+($3)->tempvar,n);
                       if($1->list_access && $3->list_access)
                       fillin("**","*"+($1)->tempvar,"*"+($3)->tempvar,n);
                ($$)->tempvar=n;
                 $$->list_access=0;
};
/// 
add1: { //cout<<"atom me hai"<<endl;
      if($<node>0->name=="range") {is_range=1;rc=0;val_range1="0";}
    string temp;
    if($<node>0->name=="print" ||$<node>0->name=="range" || $<node>0->name=="len" ) safe_func=1;
    if($<node>0->isConst) yyerror("constant cannot be called as a function");
   // if($<node>0->name=="__init__") yyerror("This function cannot be called");
   
        if(!$<node>0->isCheck || $<node>0->type!="function"){
            auto v1=find_func($<node>0->name, current);
           //cout<<"I am inside"<<endl;
            if(v1==NULL) {
               // cout<<"what the heck"<<endl;
                if(global_table->children.find($<node>0->name)==global_table->children.end()) yyerror("function not found");
                else {

                    if($<node>0->isCheck) yyerror("No such constructor");
                    if(global_table->children[$<node>0->name]->type!="class" ) yyerror("No such function found");
                obj_decl=1;
                $<node>0->ret_type=$<node>0->name;
                $<node>0->isCheck=true;
                $<node>0->isLeaf=false;
                $<node>0->type="function";
                temp=$<node>0->name;
                class_name=temp;
                //cout<<"!!!!!!!!!!!!!!!!!!!!!!class_name="<<class_name<<endl;
                $<node>0->name="__init__";
                $<node>0->l_value=false;
                func_name=global_table->children[temp]->children["__init__"];
                see=1;
               // if(global_table->children[$1->name]["__init__"]->no_of_arguments!=0) yyerror("No of arguments mismatch");
                
                }
            }
            else {
                
            
                //cout<<"I am correct"<<endl;
              //  //cout<<v1->name<<endl;
            fill_node($<node>0, v1);
           $<node>0->isCheck=true;
           $<node>0->isLeaf=false;
            func_name= find_func_tab($<node>0->name, current);
            
            //cout<<$<node>0->no_of_arguments<<endl;
            }
            
        }
        if(obj_decl) 
    {
        string temp=newtemp();
        obj_base_addr=temp;
        if(allowedtypes.find(class_name)==allowedtypes.end()) cout<<"hehe you are wrong"<< class_name<<endl;
        int siz_class=allowedtypes[class_name];
        string size_class="class_size"; //get the size of class from symbol table of class $1->name in atom_expr function call
        fillin("push","allocmem",to_string(siz_class),temp);
    }
    //auto v1=find_func(func_name, current);
    //if(v1==NULL){
     //   yyerror("function not found");
    //}
     //cout<<"I am outside"<<endl;
    }
atom_expr: atom{
   // //cout<<"i hate bananas "<<$1->name<<endl;
    $$=$1;
} 
| atom_expr add1 ropen{see=0; } rclose {
    ////but the function doesnt have to be in a global_table scope ...so whenever a atom_expr comes 
    // with a trailer resolve it just then
 //confirm the function name
       is_range=0; 
       if(obj_decl )
    {
        
        fillin("pushparam",obj_base_addr,"","");
        //fillin("Stackpointer","+"+to_string(temp.second),"","");
    }
    if(obj_func){
      
        fillin("pushparam",obj_name,"","");
    }
    obj_func=0;

    obj_decl=0;
   /* if(obj_func==1) {
        cout<<obj_name<<"yyyyyyyyy"<<endl;
        fillin("pushparam",obj_name,"","");}*/
    obj_func=0;
    see=0;
     //cout<<"why not me1111111111111111111111111111111111111111111"<<endl;
         // if(func_name->no_of_arguments!=0) yyerror("No of Arguments mismatch");
         if(func_name->name!="print" && func_name->name!="range" && func_name->name!="len")
            {   
                if(!func_name->arguments.empty()){
                if(*func_name->arguments.begin()=="self"){
                    if(func_name->no_of_arguments==1) ;
                   else  yyerror("No of Arguments mismatch 1");
                }
                else{
                    //if(func_name->no_of_arguments==0) ;
                  // else 
                   yyerror("No of Arguments mismatch 2");
                }
            }     
            else {
                if(func_name->no_of_arguments!=0) yyerror("No of Arguments mismatch");
            }
}
          $$=$1;
          safe_func=0;
          $$->l_value=false;
          if( $1->name=="__init__")
           {
            //cout<<"In init!!!!!!!!!!!***************"<<endl;
            fillin("call",class_name,"*init","_"+class_name+".__init__");
           }
          else if($1->name!="range")
          {
          //  cout<<"why am I here???????????????"<<endl;
            if(filling_obj_func==0)
            fillin("call","","","_"+$1->name);
            else
            fillin("call","","","_"+class_name+"."+"_"+$1->name);
            filling_obj_func=0;
           // Filling_function=code.back();
          }
          
           
           



    ////func_call///////////////////////////////
 //cout<<"I am done"<<endl;
    }
| atom_expr add1 ropen {see=0;}arglist rclose{
    string our=$1->ret_type;
     is_range=0; 
     
    //cout<<our<<endl;
    if(cls==1)  fillin("pushh",obj_base_addr,to_string((current->parent->inherited_size)),current->parent->name);
    cls=0;
    obj_decl=0;
   
    safe_func=0;
     //cout<<"why not me2222222222222222222222222222222222222"<<endl;
    
            see=0;
    
     
      
          $$=$1;
          $$->l_value=false;
          if( $1->name=="__init__")
           {
            //cout<<"In init!!!!!!!!!!!***************"<<endl;
            fillin("call",class_name,"*init","_"+class_name+".__init__");
            fillin("Stackpointer","","","-xxx");
           }
           
           
            if($1->name=="print"){
                is_print=1;
                if(!$5->isCheck && !$5->isConst){
                    auto v1=find_var($5->name, current);
                    fillin("call",$1->name,v1->type,$5->name);
                    
                }

                else if($5->isConst) fillin("call",$1->name,$5->type,$5->tempvar);
                else fillin("call",$1->name,$5->type,$5->tempvar);
            }
            else is_print=0;
            //object
            if($1->name=="len"){
                is_len=1;
                string temp=newtemp();
                if(!$5->isCheck && !$5->isConst){
                    auto v1=find_var($5->name, current);
                    fill_node($5,v1);
                    
                   // fillin("call",$1->name,v1->type,$5->name);
                
               
                }
                //cout<<"string ka size"<<$5->type<<endl;
                if($5->type=="str"&& !$5->isList) {
                    fillin("=",to_string($5->str_len-2),"",temp);
                    
                }
                else {auto v1=find_var($5->name, current);fillin("=",to_string((v1->size)/16),"",temp);}
                  
                $1->tempvar=temp;
            }
            if($1->name!="print" && $1->name!="__init__"&&$1->name!="len" && $1->name!="range" ) {
                //cout<<"pleaseee"<<endl;
                if(filling_obj_func==0)
                fillin("call","","","_"+$1->name);
                else
                fillin("call","","","_"+class_name+"."+"_"+$1->name);
                filling_obj_func=0;
                if(our!="None"){
                string temp=newtemp();
            fillin("=", $1->name, "", temp);
            $1->tempvar=temp;}
    //       $$->isLeaf=false;
    //       $$->l_value=false;
            }
             else if(!is_range)     fillin("Stackpointer","","","-xxx");
           

}
|atom_expr SOPEN{middle_oflist_access=1;} test sclose {
    ///// test written 
    // a:List[int]
    //   a[2]=1

    // a[b]=1
    middle_oflist_access=0;
    if($1->isConst) yyerror("constant cannot be accesed as a list");
    if($1->name=="list"){
        if($1->isCheck) yyerror("Unexpected representation");
        if($4->isCheck) yyerror("Unexpected type");
        if(global_table->children.find($4->name)==global_table->children.end())  yyerror("Undefined type");
        if(global_table->children[$4->name]->type!="class") yyerror("Undefined type");
        $1->name=$4->name;
        $1->isLeaf=false;
        $1->isCheck=true;
        $1->isList=true;
        $1->l_value=false;
        $1->type="class";
    }
    else{
        
        if(!$1->isCheck && !$1->isConst ){
            auto v1=find_var($1->name, current);
            if(v1==NULL) yyerror("variable not found");
            fill_node($1, v1);
            $1->isCheck=true;
            $1->isLeaf=false;
        }
        
        if(!$1->isList) yyerror("Unexpected access");
        $1->list_access=true;
        $1->isList=false;
        $1->isLeaf=false;
        if(!$4->isCheck && !$4->isConst){
            auto v2=find_var($4->name, current);
            if(v2==NULL) yyerror("variable not found");
            fill_node($4, v2);
            $4->isCheck=true;
        }
        if($4->type=="function"){
        if($4->ret_type!="int" && $4->ret_type!="bool" ) yyerror("index should be int");
        } /// or bool or bool bool 
        else if($4->isConst && ($4->type!="int" &&  $4->type!="bool")) yyerror("index should be int");
       
        else {
            if(!$4->isinitial && !$4->isConst ) yyerror("Unexpected access of initialized variable");
            if($4->type!="int" && $4->type!="bool") yyerror("index should be int");
        }
    
            $1->l_value=true;
    }

    
    long long base=0;//b->base_addr;  base address sym table se lena hai
    string temp= newtemp();
  //  fillin("+",to_string(base), tempvar, temp); //temp stores the arr[0]+offset 
    temp=($$)->tempvar; //whyy???
    $$=$1;
    $$=$1;
 //long long base=0;//b->base_addr;  base address sym table se lena hai
    if($1->list_access)
    {
        string temp= newtemp();
        string base_addr="list_base_"+$1->tempvar; //get this base address from the symbol table
        string temp1= newtemp();

       //int v=stoi($4->tempvar)*16;
       string temp2=newtemp();
       fillin("*","16",$4->tempvar,temp2);
        fillin("-",$1->tempvar,temp2,temp1);

        //string temp2=newtemp();
        //fillin("=","*"+temp1,"",temp2);
        $$->tempvar=temp1;
    }

}   

|atom_expr dot var
//// init declare or use in a class function
/// normal access var or function
/// /// check this
{
    if($1->isConst) yyerror("constant cannot be derefrenced");
    /// what to do if declaration
    if($1->name=="self"){
        if($1->isCheck) yyerror("Unexpected representation");
        if(find_var("self", current)==NULL) yyerror("Self cannot be called");
        $1->isCheck=true;
        if(current->parent==NULL || current->parent->type!="class") yyerror("self can only be used in a class");
        if(current->type=="function" && current->name!="__init__") {
            if(find_var_class($3->name, current->parent)==NULL){
                if(find_func_class($3->name, current->parent)==NULL){
                    yyerror("No such  member of class exists");

                }
                else{
                    auto v2=find_func_class($3->name, current);
                    see=1;
                    func_name=v2;
                    $1->type="function";
                    $1->no_of_arguments=v2->no_of_arguments;
                    $1->name=v2->name;
                    $1->ret_type=v2->ret_type;
                    $1->isLeaf=false;
                    $1->isCheck=true;
                    $1->l_value=false;
                }

            }
            
            auto v1=find_var_class($3->name, current->parent);
            fill_node($1, v1);
              string temp= newtemp();
        string offset=to_string(v1->offset); //search in the symbol table for $1->tempvar(has the name of the variable) and take it's offset.
        //cout<<"obj_base_addr is= "<<obj_base_addr<<" !!!!!!"<<endl;
        fillin("-",obj_base_addr,offset,temp); //this has the address of the oject variable.
                
        $1->tempvar=temp; //temp has the access base+offset of object stored
     
        
        $1->list_access=1;
            
           // cout<<$1->isinitial<<"             "<<"jvm"<<endl;
            $1->isLeaf=false;
           // $1->ret_type=current->parent->tab_var[$3->name]->ret_type;
            $1->isCheck=true;
            $1->l_value=true;
            $$=$1;
            
           
        }
        else if(current->type=="function" && current->name=="__init__"){
            init_dec=1;
            $1->name=$3->name;
            $1->isLeaf=true;
            $1->l_value=true;
            $1->isCheck=true;
            $$=$1;
        }
        else yyerror("Self cannot be called");
        
    }
    else if($3->name=="__init__"){
        /////heeeeeeeeeeeeeeeeeeeeeeee
     //fillin("pushh",obj_base_addr,to_string((current->parent->inherited_size)),current->parent->name);
     cls=1;
//cout<<"i am tiredddddddddddddddddddddddddddddddddddddddddddd"<<endl;
            if($1->isCheck) yyerror("Init icannot be called");

            see=1;
           // $1->name=$3->name;
            $1->isLeaf=false;
           
            $1->isCheck=true;
           
        if(current->name!="__init__") yyerror("__init__ cannot be called");
        auto v1=find_class_in($1->name, current->parent);
        class_name=v1->name;

        if(v1==NULL) yyerror("__init__ cannot be called");
            $1->name="__init__";
            $1->isCheck=true;
            $1->isLeaf=false;
            $1->ret_type="None";
             $1->l_value=false;
            $1->no_of_arguments=v1->no_of_arguments;
             $1->type="function";
        func_name=v1->children["__init__"];
        //cout<<v1->name<<"gogogogooogogogo"<<endl;

        $$=$1;
    }
    
    else {

        if(!$1->isCheck){
            auto v1=find_var($1->name, current);
            if(v1==NULL) yyerror("No such variable");
           // //cout<<"it is wrong"<<endl;
            fill_node($1, v1);
            $1->isCheck=true;
            
        }

        if($1->type=="function"){
        if(find_var_class($3->name, global_table->children[$1->ret_type])==NULL) {
            auto v2=find_func_class($3->name, global_table->children[$1->ret_type]);
            if(v2==NULL) yyerror("No such memeber of class is present");
            see=1;
            func_name=v2;
                                $1->type="function";
            
            $1->no_of_arguments=v2->no_of_arguments;
            $1->name=v2->name;
            $1->ret_type=v2->ret_type;
            $1->isLeaf=false;
            $1->isCheck=true;
            
        }
        else{
        auto v1=find_var_class($3->name, global_table->children[$1->ret_type]);
        fill_node($1, v1);
        $1->type=v1->type;
        $1->isLeaf=false;
        $1->name=v1->name;
        
        $1->l_value=true;
        $1->isCheck=true;
        //$1->type=global_table->children[$1->ret_type]->tab_var[$3->name]->type;
        $1->ret_type=v1->ret_type;
        $1->isList=v1->isList;
        // current=global_table->children[$1->ret_type]->tab_var[$3];
        $$=$1;
        
        }
        
    }
    else{
        
    if(find_var_class($3->name, global_table->children[$1->type])==NULL) {
            auto v2=find_func_class($3->name, global_table->children[$1->type]);
            if(v2==NULL) yyerror("No such memeber of class is present");
            see=1;
                                

            func_name=v2;
             class_name=$1->type;
                                $1->type="function";
                               
            obj_func=1;
            filling_obj_func=1;
            ////////////////
            
            //Filling_function->result=class_name+"."+Filling_function->result;



           
            obj_name=$1->name;
            $1->no_of_arguments=v2->no_of_arguments;
            $1->name=v2->name;
            $1->ret_type=v2->ret_type;
            $1->isLeaf=false;
            $1->isCheck=true;
            
        }
        else{ //this is to find the object
        //obj_access=1;
        auto v1=find_var_class($3->name, global_table->children[$1->type]);
        //v1's offset is the offset.
        //v1 name is the name of the obj
        string temp=newtemp();
        string obj_base_addr1= $1->name;
        fillin("-",obj_base_addr1,to_string(v1->offset),temp);
        //string temp1=newtemp();
        //fillin("=","*"+temp,"",temp1);
        $1->tempvar=temp; //temp has the access base+offset of object stored
        $1->list_access=1;
        //obj_access_addr=temp;
        fill_node($1, v1);
        $1->type=v1->type;
        $1->isLeaf=false;
        $1->name=v1->name;
        //////////////////////////

            ///////////////////////////////////
        $1->l_value=true;
        $1->isCheck=true;
        //$1->type=global_table->children[$1->ret_type]->tab_var[$3->name]->type;
        $1->ret_type=v1->ret_type;
        $1->isList=v1->isList;
        // current=global_table->children[$1->ret_type]->tab_var[$3];
        $$=$1;


        
        }
        }
    
}
//using an object.
////changed here///////////////////////////////////////
        /*if($1->name=="self")
        {
            // class_decl_init=1;
            $$->tempvar=$3->tempvar;
        }*/
        //write the else if .init
    
      $$=$1;
};


atom: ropen test rclose{$$=$2;}
|SOPEN testlist sclose {
    
    

  $$=$2;
  string base_addr="list_base_"+list_name; //get from sym table
  string temp=newtemp();
 // fillin("=",base_addr,"",temp);
  string temp7=newtemp();
 
  fillin("push","allocmem",to_string(list_siz),temp7);
  fillin("=",temp7,"",list_name);
  int list_size=1; //change this with the size of the type of list
  
  stack<pair<string,int>>hehe;
  while(!argstack.empty()){
    auto k=argstack.top();
    hehe.push(k);
    argstack.pop();
  }
    int counter=0; //b --base address
    
    while(!hehe.empty()){
        string v=newtemp();
        auto k=hehe.top();
        fillin("-", list_name, to_string(counter),v);
        fillin("=",k.first,"","*"+v);
        counter+=k.second;
        hehe.pop();
    }
   
}

|SOPEN sclose {
    /// empty list
    num_of=0;
    $$=new Node();
    //type of list will be defined later
    $$->isList=true;
    $$->isLeaf=false;
}

|var {
    //cout<<"var is "<<$1->name<<endl;
    ///// this should not be a function nor a variable to be declared
    
    $1->l_value=true; 
    $1->isLeaf=true;
    $$->tempvar=$1->name;
    // if($$->tempvar=="obj")
    // obj_decl=1;
    $$=$1;   
}
|num {$1->isConst=true;$$->tempvar=$1->name;$$=$1; $1->list_access=0;}

|none {$1->isConst=true;$$=$1;}
|TRUe {$$->tempvar=$1->name;
string temp=newtemp();
fillin("=","1","",temp);

$$=$1;
$$->isCheck=true;
$$->isConst=false;
$$->isinitial=1;
$$->l_value=1;
$$->type="int";
$$->tempvar=temp;
}
|FALSe {
$$->tempvar=$1->name;
string temp=newtemp();
fillin("=","0","",temp);

$$=$1;
$$->isCheck=true;
$$->isConst=false;
$$->isinitial=1;
$$->l_value=1;
$$->type="int";
$$->tempvar=temp;
}


|STRING{
    //cout<<"I have a string"<<endl;
    //cout<<"my string is"<<$1->name<<endl;
    $1->isConst=true;
    $1->isLeaf=false;
    $1->str_len=$1->name.size();
    $1->l_value=false;
    $$=$1;
    $$->tempvar=$$->name;
};
/*
string_plus:string_plus STRING{
    //// should i concatenate
}
*/

testlist: test_new {$$=$1; sizee=list_siz;}
| test_new comma  {
    sizee=list_siz;
    //// make a stack // sata structure -.store all inputs to the list 
    /// in test colon test equal test ->isCheck if the inputs are compatible with the type
    $$=$1; 
};
test_new:test_new comma test {
    num_of++;
     if(!$3->isCheck && !$3->isConst){
        auto v1=find_var($3->name, current);
        if(v1==NULL) yyerror("Variable not found");
        fill_node($3, v1);
        $3->isCheck=1;
    }
    if($3->isList) yyerror("Error in list declaration");
    if($3->type=="function"){
        
        if(!func_assign($3->ret_type, list_type)) yyerror("Types not compatible for list");
    }
    else{
        if(!$3->isConst && !$3->isinitial) yyerror("Vraible not initialised");
         if(!func_assign($3->type, list_type)) yyerror("Types not compatible for list");
    }
    list_siz+=calcsize($3->name, list_type);
    //cout<<sizee<<"!!!!!!!!!!!!!!!!!!!!!!!!!!11111"<<endl;
    $3->type=list_type;
    $3->isList=true;
    $3->isCheck=true;
    $3->isLeaf=false;
    $3->l_value=false;
    $$=$3;    
    argstack.push({$3->tempvar,16});
}
|test {
    
    if(!$1->isCheck && !$1->isConst){
        auto v1=find_var($1->name, current);
        fill_node($1, v1);
        if(v1==NULL) yyerror("Variable not found");
        $1->isCheck=1;
    }
    if($1->isList) yyerror("Error in list declaration");
    if($1->type=="function"){
        if(!func_assign($1->ret_type, list_type)) yyerror("Types not compatible for list");
    }
    else{
         if(!$1->isConst && !$1->isinitial) yyerror("Vraible not initialised");
         if(!func_assign($1->type, list_type)) yyerror("Types not compatible for list");
    }
     list_siz+=calcsize($1->name, list_type);
     // cout<<sizee<<"!!!!!!!!!!!!!!!!!!!!!!!!!!11111"<<endl;
    $1->type=list_type;
    $1->isList=true;
    $1->isCheck=true;
    $1->isLeaf=false;
    $1->l_value=false;
    argstack.push({$1->tempvar,16});
    $$=$1;

};

classdef: CLASS var add3  colon suite {

   
    allowedtypes[$2->name]=off;
   current->inherited_size=off;
         off=0;
    current=current->parent;
    
    // if(current->type!="function" && current->type!="class")
    // checking=0;
    //cout<<"current->name="<<current->name<<"in class"<<endl;

}
|CLASS var add3 ropen rclose colon suite{
 allowedtypes[current->name]=off;

     off=0;
  current=current->parent;
 
    //cout<<"current->name="<<current->name<<"in class 1"<<endl;

//   if(current->type!="function" && current->type!="class")
//     checking=0;
class_decl=0;
}   


|CLASS var add3  ropen var {
    if(global_table->children.find($5->name)==global_table->children.end() || global_table->children[$5->name]->type!="class") yyerror("class not found"); //Idk i changed this global_table->children[$5->name]!="class" error aa raha hai
     //cout<<"tttrtrttrrttrttrrttrtrrtrtrtrggggggggggggggggggggggggg"<<endl;
        current->inherited =global_table->children[$5->name];
        //off+=allowedtypes[$5->name];
        current->inherited_size=allowedtypes[$5->name];
        //cout<<current->inherited->name<<endl;
        
    } rclose colon suite{
    ///////changed arglist to argument
   /* auto k=global_table->children[$5->name]->tab_var;
    for(auto i:global_table->children[$5->name]->ordered_var){

       // add_symbol(current,i.first, i.second->type,  i.second->lineno, i.second->isinitial, off, i.second->size, i.second->num_e, i.second->isList  );
        add_symbol(current, i, k[i]->type, k[i]->lineno, k[i]->isinitial, off, k[i]->size, k[i]->num_e, k[i]->isList);
        off+=(k[i]->size);
        current->ordered_var.push_back(i);
    }*/
     allowedtypes[current->name]=off;
     
    
    

    current=current->parent;
    //cout<<"current->name="<<current->name<<"in class 2"<<endl;
    // if(current->type!="function" && current->type!="class")
    // checking=0;
    class_decl=0;

};

add3: {
    off=0;
    // checking=1;
    class_decl=1;
    add_symbol(current, $<node>0->name, "class", line_no, false, off,0, 1 );
        current= new Symbol_table(current, line_no,$<node>0->name);
        current->name=$<node>0->name;
       current->type="class";
       fillin("_"+$<node>0->name+":","","","");
       class_name=$<node>0->name;
        //current->ret_type=ret_type;

}

///////////////////////////////////////// 
arglist: arg_new {  
    if(func_name->name!="print" && func_name->name!="range" && func_name->name!="len")
     {if(no_of_args!=func_name->no_of_arguments) yyerror("no of arguments mismatch");
    no_of_args=0;
    //cout<<"In arglist 1"<<endl;
    $$=$1;} 
    while(!argstack.empty())
    {
        auto temp= argstack.top();
        fillin("pushparam",temp.first,"","");
      //  fillin("Stackpointer","+"+to_string(temp.second),"","");
        argstack.pop();
    }
    if(obj_decl )
    {
        
        fillin("pushparam",obj_base_addr,"","");
        //fillin("Stackpointer","+"+to_string(temp.second),"","");
    }
    if(obj_func){
        
        fillin("pushparam",obj_name,"","");
    }
    obj_func=0;

  //  cout<<"I am hreeeeeeeeeeeee"<<endl;
    
   // fillin("Stackpointer","","","+yyy");
    $$=$1;
   $$=$1;}
| arg_new comma  {
    if(func_name->name!="print" && func_name->name!="range" && func_name->name!="len")
    {if(no_of_args!=func_name->no_of_arguments) yyerror("no of arguments mismatch");
    no_of_args=0;
    }//cout<<"In arglist 1"<<endl;
    $$=$1;
    if(!is_range){ 
    while(!argstack.empty())
    {
        auto temp= argstack.top();
        fillin("pushparam",temp.first,"","");
      //  fillin("Stackpointer","+"+to_string(temp.second),"","");
        argstack.pop();
    }
    if(obj_decl )
    {
        
        fillin("pushparam",obj_base_addr,"","");
        //fillin("Stackpointer","+"+to_string(temp.second),"","");
    }}
   // fillin("Stackpointer","","","+yyy");
    $$=$1;
};


arg_new:arg_new comma argument {
    
   if(func_name->name!="print" && func_name->name!="range" && func_name->name!="len")
   {
    
     if(func_arg_traverse==func_name->arguments.end()) yyerror("No of argumnets mismatch");
    
    ////cout<<t2<<endl;
     if(*func_arg_traverse=="self") {
       if($3->name!="self")
        {func_arg_traverse++; no_of_args++;}
        }
    if($3->name!="self"){
    if(func_arg_traverse==func_name->arguments.end()) yyerror("No of argumnets mismatch");

    if(!$3->isCheck && !$3->isConst) {
        auto v1=find_var($3->name, current);
        if(v1==NULL) yyerror("variable not found");
        fill_node($3, v1);
        $3->isCheck=true;
    }
    string t2=$3->type;
    if($1->type=="function") {
        t2=$3->ret_type;
    }
    else {
        if(!$3->isConst && !$3->isinitial) yyerror("Uninitialized variable used");
    }
    //cout<<t2<<endl;
    if(!func_assign(func_name->tab_var[*func_arg_traverse]->type, t2)) yyerror("type mismatch");
    if(func_name->tab_var[*func_arg_traverse]->isList!=$3->isList) yyerror("List type does not match");
   
}
 func_arg_traverse++;
    no_of_args++;
    }
}
|argument {
 
     if(func_name->name!="print" && func_name->name!="range" && func_name->name!="len")
   {
    //cout<<func_name->name<<endl;
     func_arg_traverse=func_name->arguments.begin();
     if(func_arg_traverse==func_name->arguments.end()) yyerror("No of argumnets mismatch");
        
    ////cout<<t2<<endl;
     if(*func_arg_traverse=="self") {
       if($1->name!="self")
        {func_arg_traverse++; no_of_args++;}
        }
    if($1->name!="self"){
    if(func_arg_traverse==func_name->arguments.end()) yyerror("No of argumnets mismatch");

    if(!$1->isCheck && !$1->isConst) {
        auto v1=find_var($1->name, current);
        if(v1==NULL) yyerror("variable not found");
        fill_node($1, v1);
        $1->isCheck=true;
    }
    string t2=$1->type;
    if($1->type=="function") {
        t2=$1->ret_type;
    }//cout<<t2<<endl;
    else {
        if(!$1->isConst && !$1->isinitial) yyerror("Uninitialized variable used");
    }
    if(!func_assign(func_name->tab_var[*func_arg_traverse]->type, t2)) yyerror("type mismatch 113 1");
    if(func_name->tab_var[*func_arg_traverse]->isList!=$1->isList) yyerror("List type does not match 3");
   
}
 func_arg_traverse++;
    no_of_args++;
    }
};

argument:test {
    if(is_range) rc++;
    if(rc==1) val_range=$1->tempvar;
    else if(rc==2) {val_range1=val_range;val_range=$1->tempvar;}
    if(!is_range && func_name->name!="print"&&func_name->name!="len"){
     if(!$1->list_access)
    {
        if($1->tempvar!="self")
        argstack.push({$1->tempvar, 4});
    }
    else //since the temp var gives the address, push * of it
     argstack.push({"*"+$1->tempvar, 4}); 
     $$=$1;}
     else if(func_name->name=="print" || func_name->name=="len"){
            if($1->list_access){
        string temp=newtemp();
        fillin("=", "*"+$1->tempvar,"", temp);
        $$=$1;
        $$->tempvar=temp;
        $$->list_access=0;
       }
    
     }
    
    //cout<<"i was here in test"<<endl;
}
|test EQUAL{ 

     if(!$1->isCheck && $1->l_value){
        auto v1=find_var($1->name, current);
        if(v1!=NULL){
            list_type= v1->type;
        }
    }
    }
test { 
     
    if(!$1->l_value) yyerror("cannot be assigned");
    if(!$1->isCheck)  {
        auto v1=find_var($1->name,current);
      //  //cout<<"1"<<endl;
        if(v1==NULL) yyerror("variable not found");
        //cout<<"2"<<endl;
        fill_node($1, v1);
        $1->isCheck=true;
        }
    if(!$4->isCheck  && !$4->isConst) {
        auto v2=find_var($4->name,current);
        if(v2==NULL) yyerror("variable not found");
        fill_node($4, v2);
        $4->isCheck=true;
    }
    if($4->type=="function"){
        if(!func_assign($1->type, $4->ret_type)) yyerror("type mismatch");
         string temp=newtemp();
       fillin("=",$4->tempvar,"",temp);
       $4->tempvar=temp;
    }
    // a:int =2.5 a=2
      else {
        if(!$4->isinitial && !$4->isConst) yyerror("Variable uninitialsed");
        if(!func_assign($1->type, $4->type)) yyerror("type mismatch");
      if(!($1->isList==$4->isList)) yyerror("type list");
      }
    $$=$1;
    if(func_name->name!="print"&&func_name->name!="len"){
     if(!$4->list_access )
    {
        if($4->tempvar!="self")
        argstack.push({$4->tempvar, 4});
    }
    else //since the temp var gives the address, push * of it
     argstack.push({"*"+$4->tempvar, 4}); }
};





%%
  void create_csv(Symbol_table* table){
   
    for(auto i:table->children){
      //   cout<<i.first<<"                 hhhhhhhhhhhhhhhhhhhhh"<<endl;
        if(i.first=="float"||i.first=="int" || i.first=="str" || i.first=="bool" || i.first=="len" || i.first=="range" || i.first=="print") continue;
        
        create_csv(i.second);
    }
   if(table==global_table || table->type=="class") return;

    stringstream filenamestream;
    if(table->name=="__init__") {
        // return;
        // cout<<"i came here"<<endl;
         filenamestream<<table->parent->name<<table->name<<".csv";
        }
    else filenamestream<<table->name<<".csv";
    string filename = filenamestream.str();
    ofstream outputfile(filename);
    // cout<<it.first<<endl;
    //Header
    outputfile<<"Name, type, lineno, isList, size, offset"<<endl;

    
    for(auto i:table->tab_var){
        outputfile<<i.first<<","<<i.second->type<<","<<i.second->lineno<<","<<i.second->isList<<","<<i.second->size<<","<<i.second->offset<<endl;
        
    }
    for(auto i:table->tab_func_class){
        outputfile<<i.first<<","<<i.second->type<<","<<i.second->lineno<<","<<i.second->isList<<","<<i.second->size<<","<<i.second->offset<<endl;

    }
    
    
    outputfile.close();



}
map<string, long> addr_desc;
map<string, string> reg_desc={
        {"r8", ""},
        {"r9", ""},
        {"r10", ""},
        {"r11", ""},
        {"r12", ""},
        {"r13", ""},
        {"r14", ""},
        {"r15", ""}
    };

string get_reg(string temp){
 for(auto &j: reg_desc)
 {
    if(j.second=="")
    {
        j.second=temp;
    
        return j.first;
    }
 }
   cout<<"register not found!"<<endl;
   exit(1);  
}
void free_reg(void)
{
    for(auto &i: reg_desc)
    {
        i.second="";
    }
}

string curr_func="";
bool isString(const string str){
    regex pattern ("[\"][^\n\"]*[\"]|[\'][^\n\']*[\']");
    if(regex_match(str, pattern)) return 1;
    return 0;
}
int stack_off=0;
int str_cnt=0;
string str_name=".str";
map<string, string> str_data;
int k=0;
int f_k=0;
void gen_asm(){
    
 

   
    printf(".LC0:\n");
    printf("\t.string \"%%d\\n\"\n");
    printf(".LC1:\n");
    printf("\t.string \"%%s\\n\"\n");
    cout<<".data"<<endl;
    printf("__name__:\n");
    cout<<"\t\t.string \"__main__\""<<endl;

/*LC0:
        .ascii "Hello, world!\12\0"*/
  //  cout<<"\t string_format: .asciz \"%s\\n\""<<endl;
    cout<<".str:"<<endl;
    cout<<"\t\t.string \"__main__\""<<endl;
    for(auto i:str_data){
        cout<<i.second<<":"<<endl;
        cout<<"\t\t .string "<<i.first<<endl;
    }

    printf("\t.globl main\n");
    printf("\t.text\n");
    
     int offset_arg=0;
     int ctr=0;
     string curr_ctr;
     int need=0;
     int later_need=0;
     string g_comp=""
;      long net_offset=-16; //this is for the temporaries in the function
    for(auto i: code)
    {   
        if(i->arg1=="Function"){ //for function declaration
           
            cout<<"    "<<(i->op).substr(1)<<endl;
            
           
        }
        if(i->op=="pushh"){
          
            cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp), "<<"%rbx"<<endl;
           // cout<<i->result<<endl;
            cout<<"\tsubq $"<<i->arg2<<", %rbx"<<endl;
            
             f_k=1;
           
            cout<<"\tmovq %rbx, 0(%rsp)"<<endl;
            cout<<"\tsubq $16"<<", %rsp"<<endl;
                
            stack_off+=16;

        }
        if(i->arg1=="*constructor") {
          
            cout<<i->op<<endl;
            ctr=1;
            curr_ctr=i->arg2.substr(1);
            need=allowedtypes[curr_ctr];

        }
        if(i->arg1=="allocmem"){
            if(i->op=="push"){
                cout<<"\tmov %rbp, %rcx"<<endl;
                int stp=-net_offset;
               
                cout<<"\tsubq $"<<stp<<", %rcx"<<endl;
                net_offset-=(std::stoi(i->arg2));
                if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<""<<"%rcx"<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                net_offset-=16;
               
            }
            
             cout<<"\tmovq "<<"%rcx"<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
        }

                
                
               
            }
            

        }

    if(i->op=="=="){
        string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
            
           if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

          if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
        
            //cout<<"\tcmovz "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            cout<<"\tcmp "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            cout<<"\tsete "<<"%"<<R2<<"b"<<endl; //R2 has the value 0 or 1


            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
            // cout<<"\tcmpq "<<"$1, %"<<R2<<endl;

    }

     if(i->op=="!="){
        string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
           if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

          if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
        
            //cout<<"\tcmovz "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            cout<<"\tcmp "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            cout<<"\tsetne "<<"%"<<R2<<"b"<<endl; //R2 has the value 0 or 1


            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
            // cout<<"\tcmpq "<<"$1, %"<<R2<<endl;

    }


        if(i->op=="<"){
        string R1= get_reg(i->arg1);       
            string R2= get_reg(i->arg2);
                      g_comp="<";

            
           if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

          if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
           // cout<<"\tcmovl "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
           cout<<"\tcmp "<<"%"<<R2<<" ,"<<"%"<<R1<<endl;
           cout<<"\tmovq "<<"$0"<<" ,"<<"%"<<R2<<endl;
           string R3= get_reg("temporary_usage");       
            cout<<"\tmovq "<<"$1"<<" ,"<<"%"<<R3<<endl;
            cout<<"\tcmovl "<<"%"<<R3<<" ,"<<"%"<<R2<<endl;

            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
             
             //cout<<"\tcmpq "<<"$1, %"<<R2<<endl;
            


    }

    if(i->op==">"){
        string R1= get_reg(i->arg1);       
            string R2= get_reg(i->arg2);
                      g_comp="<";

            
           if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

          if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
           // cout<<"\tcmovl "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
           cout<<"\tcmp "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
           cout<<"\tmovq "<<"$0"<<" ,"<<"%"<<R2<<endl;
           string R3= get_reg("temporary_usage");       
            cout<<"\tmovq "<<"$1"<<" ,"<<"%"<<R3<<endl;
            cout<<"\tcmovl "<<"%"<<R3<<" ,"<<"%"<<R2<<endl;

            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
             
             //cout<<"\tcmpq "<<"$1, %"<<R2<<endl;
            
    }
if(i->op==">="){
        string R1= get_reg(i->arg1);       
            string R2= get_reg(i->arg2);
                      g_comp="<";

             
           if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

          if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
           // cout<<"\tcmovl "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
           cout<<"\tcmp "<<"%"<<R2<<" ,"<<"%"<<R1<<endl;
           cout<<"\tmovq "<<"$1"<<" ,"<<"%"<<R2<<endl;
           string R3= get_reg("temporary_usage");       
            cout<<"\tmovq "<<"$0"<<" ,"<<"%"<<R3<<endl;
            cout<<"\tcmovl "<<"%"<<R3<<" ,"<<"%"<<R2<<endl;

            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
             
             //cout<<"\tcmpq "<<"$1, %"<<R2<<endl;
            
}
if(i->op=="<="){
        string R1= get_reg(i->arg1);       
            string R2= get_reg(i->arg2);
                      g_comp="<";

              
           if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

          if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
        
           // cout<<"\tcmovl "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
           cout<<"\tcmp "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
           cout<<"\tmovq "<<"$1"<<" ,"<<"%"<<R2<<endl;
           string R3= get_reg("temporary_usage");       
            cout<<"\tmovq "<<"$0"<<" ,"<<"%"<<R3<<endl;
            cout<<"\tcmovl "<<"%"<<R3<<" ,"<<"%"<<R2<<endl;

            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
             
             //cout<<"\tcmpq "<<"$1, %"<<R2<<endl;
            
    }


    if(i->op=="if_F") { 

         if(addr_desc.find(i->arg1)==addr_desc.end())  //this is for the if(1): situation
         {
            string R1= get_reg(i->arg1); 
            if(i->arg1=="True")
            {
                cout<<"\tmovq "<<"$1"<<", %"<<R1<<endl;

            }
            else if(i->arg1=="False")
            {
                cout<<"\tmovq "<<"$0"<<", %"<<R1<<endl;
            }
            else
            cout<<"\tmovq "<<"$"<<i->arg1<<", %"<<R1<<endl;

            string R3= get_reg("temporary_usage"); //this is to implement the if (i): situation
            string R2= get_reg("temporary_usage");
                cout<<"\tmovq "<<"$1"<<", %"<<R3<<endl;
            string R4= get_reg("temporary_usage");
            cout<<"\tmovq "<<"$0"<<", %"<<R4<<endl;
            cout<<"\tcmp %"<<R4<<", %"<<R1<<endl;  
            cout<<"\tcmovz %"<<R1<<", %"<<R3<<endl;
            cout<<"\tmovq "<<"%"<<R3<<", %"<<R1<<endl;

            cout<<"\tmovq "<<"$0"<<", %"<<R2<<endl;
            cout<<"\tcmp "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
             cout<<"\tje "<<i->result<<endl;   

         }
         else
         {
        string R1= get_reg(i->arg1);  
        string R3= get_reg("temporary_usage"); //this is to implement the if (i): situation

        
        string R2= get_reg("temporary_usage");
        cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

         cout<<"\tmovq "<<"$1"<<", %"<<R3<<endl;
         string R4= get_reg("temporary_usage");
         cout<<"\tmovq "<<"$0"<<", %"<<R4<<endl;
         cout<<"\tcmp %"<<R4<<", %"<<R1<<endl;  
        cout<<"\tcmovz %"<<R1<<", %"<<R3<<endl;
         cout<<"\tmovq "<<"%"<<R3<<", %"<<R1<<endl;


        cout<<"\tmovq "<<"$0"<<", %"<<R2<<endl;
        cout<<"\tcmp "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
        cout<<"\tje "<<i->result<<endl;   
         }
    }
    if(i->op=="if_T") { 

         if(addr_desc.find(i->arg1)==addr_desc.end())  //this is for the if(1): situation
         {
                string R1= get_reg(i->arg1);  
            if(i->arg1=="True")
                    {
                        cout<<"\tmovq "<<"$1"<<", %"<<R1<<endl;
                    }
            else if(i->arg1=="False")
                {
                    cout<<"\tmovq "<<"$0"<<", %"<<R1<<endl;
                }
            else
                cout<<"\tmovq "<<"$"<<i->arg1<<", %"<<R1<<endl;
            string R3= get_reg("temporary_usage"); //this is to implement the if (i): situation

            string R2= get_reg("temporary_usage");
           // cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;


            cout<<"\tmovq "<<"$1"<<", %"<<R3<<endl;
            string R4= get_reg("temporary_usage");
            cout<<"\tmovq "<<"$0"<<", %"<<R4<<endl;
            cout<<"\tcmp %"<<R4<<", %"<<R1<<endl;  
            cout<<"\tcmovz %"<<R1<<", %"<<R3<<endl;
            cout<<"\tmovq "<<"%"<<R3<<", %"<<R1<<endl;

            cout<<"\tmovq "<<"$1"<<", %"<<R2<<endl;
            cout<<"\tcmp "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            cout<<"\tje "<<i->result<<endl; 
         }  
         else
         {

                string R1= get_reg(i->arg1);  
                string R3= get_reg("temporary_usage"); //this is to implement the if (i): situation

                string R2= get_reg("temporary_usage");
                cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;


                cout<<"\tmovq "<<"$1"<<", %"<<R3<<endl;
                string R4= get_reg("temporary_usage");
                cout<<"\tmovq "<<"$0"<<", %"<<R4<<endl;
                cout<<"\tcmp %"<<R4<<", %"<<R1<<endl;  
                cout<<"\tcmovz %"<<R1<<", %"<<R3<<endl;
                cout<<"\tmovq "<<"%"<<R3<<", %"<<R1<<endl;

                cout<<"\tmovq "<<"$1"<<", %"<<R2<<endl;
                cout<<"\tcmp "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
                cout<<"\tje "<<i->result<<endl; 
         }
    }

     if(i->arg2=="goto"&&i->op!="if_F"&&i->op!="if_T") {cout<<"\tjmp "<<i->result<<endl; }
     if(i->op=="goto") {cout<<"\tjmp "<<i->result<<endl;}
    if(i->op=="label"){
        cout<<i->arg1<<endl;
    }

       if(i->op=="call") {
        if(f_k==0){
            cout<<"\tsubq $"<<-net_offset-k-16<<", %rsp"<<endl;
                k=-net_offset-16;
        }
        f_k=0;
 // fillin("call",$1->name,$5->type,$5->tempvar);
            if((i->arg1)=="print")
            {   //cout<<"indide print"<<endl;
             
               
            if(i->arg2=="int"){
                
             
                if(addr_desc.find(i->result)==addr_desc.end()) //i.e arg1 is a constant!!
                {
                 
                    cout<<"\tmovq"<<" $"<<i->result<<", %rdi"<<endl;
                }
             else   
             cout<<"\tmovq "<<addr_desc[i->result]<<"(%rbp), %rdi"<<endl;
                printf("\tmovq %%rdi, %%rsi\n");
                cout<<"\tleaq .LC0(%rip), %rdi"<<endl;
                cout<<"\tcall printf@PLT"<<endl;
                curr_func=i->arg1;
                }
            else if(i->arg2=="str"){
                     if(addr_desc.find(i->result)==addr_desc.end()) //i.e arg1 is a constant!!
                {

                    cout<<"\tmovq"<<" $"<<i->result<<" , %rdi"<<endl;
                }
             else   
             cout<<"\tmovq "<<addr_desc[i->result]<<"(%rbp), %rdi"<<endl;
                printf("\tmovq %%rdi, %%rsi\n");
                cout<<"\tleaq .LC1(%rip), %rdi"<<endl;
                cout<<"\tcall printf@PLT"<<endl;
                curr_func=i->arg1;
                }

            }
            else
            {
                cout<<"\tcall "<<(i->result).substr(1)<<endl;
                //cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp), %rdi\n"<<endl;
                //printf("\tmovq addr_desc(i->arg1)(%%rbp), %%rdi\n"); //storing the argument of print in %rdi
               // printf("\tmovq %%rdi, %%rsi\n");
                //cout<<"leaq .LC0(%rip), %rdi"<<endl;
                //cout<<"\tcall printf@PLT"<<endl;
                //offset_arg=8;
                
                //net_offset=+8;
                //cout<<"\taddq $8, %rsp"<<endl;
                curr_func=i->result.substr(1);
                if(i->arg2=="*init") 
{            
     curr_func=i->arg1;
}            }
            
            }
        if(i->op == "Begin_Function:")
        { // cout<<net_offset<<"    please                 "<<endl;
        k=0;
            addr_desc.clear();
            printf("\tpushq %%rbp\n");
            printf("\tmovq %%rsp, %%rbp\n");
            printf("\tsubq $16, %rsp\n");  
             // made the chnage here to remove segmentation fault
            unsigned long func_len; //assuming this is the total function size, gotten from sym table
            //printf("\tsubq $%d, %%rsp",func_len);
            offset_arg=32;
            net_offset=-16;
            //cout<<"\tsubq $8, %rsp"<<endl;
        }
        if(i->arg1 == "popparam")
        {   

             cout<<"\tmovq "<<offset_arg<<"(%rbp), %rdi"<<endl;
             cout<<"\tmovq %rdi ,"<<net_offset<<"(%rbp)"<<endl;
             addr_desc[i->result]=net_offset;
           
             offset_arg+=16;
             net_offset-=16;
             //cout<<"\tsubq $8, %rsp"<<endl;
        }
        if(i->op=="return")
        {
            if(i->arg1=="") ;
            else
            {
        
          if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %rax"<<endl;
            }
           else  cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp), %rax"<<endl;
            }
        }
        if(i->op == "End_Function")
        {if(ctr==1)             cout<<"\tmovq 32"<<"(%rbp), %rax"<<endl;
        later_need=0;
            ctr=0;
            need=0;
             printf("\tleave\n");
              printf("\tret\n");

        }
        if(i->op=="^")
        {
            
        
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
            if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

            if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
        
            cout<<"\txorq "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }
         if(i->op=="|")
        {
            
        
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
            if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

            if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
        
            cout<<"\torq "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }
        if(i->op=="&")
        {
            
        
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
            if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

            if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
        
            cout<<"\tandq "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }
        if(i->op=="+")
        {
            
        
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
            if(i->arg1[0]=='*')
             {//cout<<"hi"<<endl;
                cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
            else
           { if(i->arg1==curr_func){
               //cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

            if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq (%rax),"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
        
            cout<<"\taddq "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }

         if(i->op=="**")
        {
            
        
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
            if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

            if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
            string temp=newtemp();
            string temp1=newtemp();
            cout<<"\tmovq $1, %rcx"<<endl;
            cout<<"."+temp1+":"<<endl;
            cout<<"\tcmpq $0, %"<<R2<<endl;
            
            cout<<"\tje "<<"."<<temp<<endl;
            cout<<"\timulq %"<<R1<<", %rcx"<<endl;
            cout<<"\tdecq %"<<R2<<endl;
            cout<<"\tjmp "<< "."+temp1<<endl;
            cout<<"\t"<<"."<<temp+":"<<endl;

   /* cmpq $0, %rbx       // compare the exponent with 0
    je .done            // if exponent is 0, jump to done
    imulq %rax, %rcx    // multiply result by base
    decq %rbx           // decrement the exponent
    jmp .loop           // repeat the loop
.done:*/
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<"rcx"<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }

         if(i->op=="~")
        {
            
        
           if(i->arg2==""){
             string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
            if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}
            cout<<"\tmovq %"<<R1<<", %"<<R2<<endl;
            cout<<"\tnotq "<<"%"<<R2<<endl;
             if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;


           }


        }


         if(i->op=="-")
        {
            
        
           if(i->arg2==""){
             string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
            if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}
            cout<<"\tmovq $0, %"<<R2<<endl;
            cout<<"\tsubq "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
             if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;


           }
           else{
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
            if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}


            if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
               cout<<"\tmovq %rax,"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
        
            cout<<"\tsubq "<<"%"<<R2<<" ,"<<"%"<<R1<<endl;
             if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R1<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;}

        }
        if(i->op=="*")
        {
            
        
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
              if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}


            if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
        
            cout<<"\timul "<<"%"<<R1<<" ,"<<"%"<<R2<<endl;
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }
        
        if(i->op=="/")
        {
            
        
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
              if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<"rax"<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<"rax"<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<"rax"<<endl;

            }}}

          
            cout<<"\tcqo"<<endl;

             if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<"rcx"<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<"rcx"<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<"rcx"<<endl;

            }}}
        
            cout<<"\tidiv "<<"%rcx"<<endl;
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%rax"<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
             //cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }
         if(i->op=="%")
        {
            
        
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
              if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<"rax"<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<"rax"<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<"rax"<<endl;

            }}}

          
            cout<<"\tcqo"<<endl;

             if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<"rcx"<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<"rcx"<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<"rcx"<<endl;

            }}}
        
            cout<<"\tidiv "<<"%rcx"<<endl;
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%rdx"<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
             //cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }
        if(i->op=="//")
        {
            
        
            string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
              if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<"rax"<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<"rax"<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<"rax"<<endl;

            }}}

          
            cout<<"\tcqo"<<endl;

             if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<"rcx"<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<"rcx"<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<"rcx"<<endl;

            }}}
        
            cout<<"\tidiv "<<"%rcx"<<endl;
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%rax"<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
             //cout<<"\tmovq "<<"%"<<R2<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }
        if(i->op=="<<")
        {
            
        
             string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
              if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

            if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                cout<<"\tmovq %rax,"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
            cout<<"\tmovb "<<"%"<<R2+"b"<<", %cl"<<endl;
            cout<<"\tshl "<<"%cl"<<" ,"<<"%"<<R1<<endl;
             if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
          
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R1<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }
         if(i->op==">>")
        {
            
        
             string R1= get_reg(i->arg1);
            
            string R2= get_reg(i->arg2);
          
              if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R1<<endl;
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

            if(i->arg2[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg2.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R2<<endl;}
                else
           { if(i->arg2==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                 cout<<"\tmovq %rax,"<<" %"<<R2<<endl;
            }
            else{
            if(addr_desc.find(i->arg2)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg2);
                 cout<<"\tmovq"<<" $"<<i->arg2<<", %"<<R2<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg2]<<"(%rbp)"<<", %"<<R2<<endl;

            }}}
            cout<<"\tmovb "<<"%"<<R2+"b"<<", %cl"<<endl;
            cout<<"\tshr "<<"%cl"<<" ,"<<"%"<<R1<<endl;
             if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }}
          
             //printf("\tmovq %s, %d(%%rbp) \n", R2, addr_desc[i->result]);
             cout<<"\tmovq "<<"%"<<R1<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;

        }
        
        if(i->op=="=" && i->arg1 != "popparam" )
        {
            //this if for the list initialization
           if(i->arg1.substr()=="list_base")
           {
                addr_desc[i->arg1.substr()]=net_offset;
                net_offset-=16;

           }
            
           
            string R1= get_reg(i->arg1);
            //cout<<i->arg1<<"iiiiiiiiiiiiiiii     "<<curr_func<<endl;
            if(i->arg1[0]=='*')
             {cout<<"\tmovq "<<addr_desc[i->arg1.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq (%rbx),"<<" %"<<R1<<endl;}
                else
           { if(i->arg1==curr_func){
              // cout<<"hiiiiiiiiiiii"<<endl;
                R1="rax";
            }
            else{
            if(addr_desc.find(i->arg1)==addr_desc.end()) //i.e arg1 is a constant!!
            {
                
                // printf("\tmovq $%s, %%", i->arg1);
                 cout<<"\tmovq"<<" $"<<i->arg1<<", %"<<R1<<endl;
            }
            else
           {  
             cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp)"<<", %"<<R1<<endl;

            }}}

            
            if(i->result[0]=='*'){
                
             cout<<"\tmovq "<<addr_desc[i->result.substr(1)]<<"(%rbp), %rbx"<<endl;
                cout<<"\tmovq "<<" %"<<R1<<", (%rbx)"<<endl;
           
            }
            else
            {if(addr_desc.find(i->result)==addr_desc.end()) //i.e the result is a new var/ temp
            {

                 
                addr_desc[i->result]=net_offset;
                //cout<<"net offset in assignment= "<<net_offset<<endl;
              //cout<<"inside =, and its a new assigned var= "<<i->result<<"!!!!!"<<endl;
                net_offset-=16;
                //cout<<"\tsubq $8, %rsp"<<endl;
            }
            
             cout<<"\tmovq "<<"%"<<R1<<", "<< addr_desc[i->result]<< "(%rbp)"<<endl;
        }

        }
        
        if(i->op == "pushparam")
        {    
            if(f_k==0){cout<<"\tsubq $"<<-net_offset-k-16<<", %rsp"<<endl;
                k=-net_offset-16;}
            f_k=1;
            if(addr_desc.find(i->arg1)==addr_desc.end()) 
            { 
                cout<<"\tmovq"<<" $"<<i->arg1<<", %rcx"<<endl;
        }
            else cout<<"\tmovq "<<addr_desc[i->arg1]<<"(%rbp), %rcx"<<endl;

             cout<<"\tmovq %rcx ,"<<"0"<<"(%rsp)"<<endl;

          
            cout<<"\tsubq $16, %rsp"<<endl;
             stack_off+=16;
             net_offset-=16;
            // cout<<"\tsubq $8, %rsp"<<endl;
        }
        if(i->op=="Stackpointer"){
            //cout<<"\taddq $"<< stack_off<<", %rsp"<<endl; //this is to clear the space allocated to arguments
            //cout<<"\tsubq $"<<stack_off<<", %rsp"<<endl;
             net_offset+=stack_off;
             stack_off=0;
        }

       
        
         free_reg();
    }
    
}


void writeToFile() {
    // Open a file for writing
    std::ofstream outputFile("output.txt");
    if (!outputFile.is_open()) {
        std::cerr << "Error: Failed to open the file." << std::endl;
        return; // Return without writing if file cannot be opened
    }
 for(auto &i:code)
    {
        
       if(isString(i->op)){
        string new_lab=str_name+to_string(str_cnt);
        str_cnt++;

        str_data[i->op]=new_lab;
        i->op=new_lab;
       } 
       if (isString(i->arg1)){
        string new_lab=str_name+to_string(str_cnt);
        str_cnt++;
         str_data[i->arg1]=new_lab;
         i->arg1=new_lab;
       } 
       if(isString(i->arg2)) {
        string new_lab=str_name+to_string(str_cnt);
        str_cnt++;
         str_data[i->arg2]=new_lab;
         i->arg2=new_lab;
       } 
       if(isString(i->result)){
        string new_lab=str_name+to_string(str_cnt);
        str_cnt++;
         str_data[i->result]=new_lab;
         i->result=new_lab;
       }
        
    }
    // Write the contents of the code vector to the file
    for (auto i : code) {
        if(i->arg1=="*constructor"){
             // fillin(class_name+".__init__"+":","*constructor","*"+class_name,"");
            outputFile<<i->op<<endl;
        }
        else if(i->op=="label") {outputFile<<i->arg1<<endl;outputFile<<endl;}
        else if(i->op=="pushh") {
            int a1=(allowedtypes[i->result]);
            int a2=std::stoi(i->arg2);
            outputFile<<i->op<<" "<<i->arg1<<" "<<a1-a2<<endl;
            i->arg2=to_string(a1-a2);
        }
        else if(i->op=="Begin_Function:") {outputFile<<i->op<<" "<<endl;
        //i->arg1<<endl;
        }
        else if(i->op=="Stackpointer") {outputFile<<i->op<<" "<<i->result<<endl;}
        else if(i->arg1=="Function"&&i->arg2==""&&i->result=="") {outputFile<<i->op<<endl;outputFile<<endl;}
        else if(i->arg1==""&&i->arg2==""&&i->result=="") {outputFile<<i->op<<endl;outputFile<<endl;}
        else if(i->op=="if") outputFile<<i->op<<" "<<i->arg1<<" "<<i->arg2<<" "<<i->result<<endl;
        else if(i->arg1=="popparam") {  outputFile<<i->result<<i->op<<i->arg1<<" "<<i->arg2<<endl;}
        else if(i->op=="if_F"||i->op=="if_T") {
        outputFile << i->op<<" "<<i->arg1<<" "<<i->arg2 <<" "<< i->result <<std::endl;    
        }
        else if(i->op=="goto") {
            outputFile<<i->op<<" "<<i->result<<endl;
        }
        else if(i->op=="return") outputFile<<i->op<<" "<<i->arg1<<endl;
        else if(i->arg2=="goto"&&i->op==""&&i->arg1=="") outputFile<<i->arg2<<" "<<i->result<<endl;
        else if(i->arg1=="allocmem" && i->op=="push") outputFile<<i->result<<"= "<<i->arg1<<" "<<i->arg2<<" "<<endl;
          //fillin("call","_"+$1->name,$5->type,$5->tempvar);
        else if(i->op=="call"&&i->arg1!=""&&i->arg2!=""&&i->result!=""){
            outputFile<<i->op<<" "<<i->arg1<<" "<<i->result<<endl;
        }
        else if(i->op=="call") outputFile<<i->op<<" "<<i->result<<endl;
        else if(i->op=="pushparam") outputFile<<i->op<<" "<<i->arg1<<endl;
        else if(i->op=="=" && i->arg2!="" && i->arg1!="allocmem"){
        outputFile << i->result <<"="<< i->arg1<<" " <<std::endl;}
        else if(i->op!="=" && i->arg2==""){
        outputFile << i->result <<"="<<i->op << i->arg1 <<std::endl;}
        else if(i->arg2=="") {
        outputFile << i->result<< i->op << i->arg1 <<std::endl;  
        }
        
    
        else {
            outputFile<<i->result<<"="<<"("<<i->arg1<<i->op<<i->arg2<<")"<<endl;
        }

    }

    // Close the file
    outputFile.close();

    //std::cout << "Data has been written to output.txt" << std::endl;
}

int main(int argc, char* argv[]) {
  bool verbose = false;
  for(int i = 1; i < argc; i++){        
        if(std::string(argv[i]) == "--help" || std::string(argv[i]) == "-h") {
            //cout<<"help "<<endl;
            print_help_page();
            return -1;
        }
        else if(std::string(argv[i]) == "--input" || std::string(argv[i]) == "-i") {
          //cout<<"here"<<endl;
            if((i + 1) < argc) input_file = argv[i+1];
            else cout << "Error: No input filename given";
            i++;
        }
        else if(std::string(argv[i]) == "--output" || std::string(argv[i]) == "-o") {
          //cout<<"be here"<<endl;
            if((i + 1) < argc) output_file = argv[i+1];
            else cout << "Error: No output filename given";
            i++;
        }
                else if(std::string(argv[i]) == "--verbose" || std::string(argv[i]) == "-v") {
            verbose = true;
        }
  
  }
    //yyout = stderr;
    if(verbose) yydebug=1;
    program = fopen(input_file.c_str(), "r");
    if(!program) {
        cout << "Error: Program file could not be opened" << endl;
        return -1;
    }
    yyin = program;
    yyparse();
    writeToFile();
  
   gen_asm();
    create_csv(global_table);
    fclose(program);

}

void yyerror(const char *s) {
    cout<<s<<" at "<<line_no<<endl;
  //  //cout<<"error because of ="<<yytext<<"="<<endl;
    exit(1);
}