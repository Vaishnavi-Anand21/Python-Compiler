%{

#define YYDEBUG 1
#include<bits/stdc++.h>
using namespace std;
extern int yylineno;
extern char* yytext;
extern int yyparse();
#include <fstream>
#define YYERROR_VERBOSE 1

extern FILE* yyin;
void yyerror(const char *s);
int yylex(void);

struct node{
    string label;
    vector <pair<struct node*,string>> children;

};

struct node* new_NODE(){
    struct node* n=new node;
    n->label="NEW";

    return n;
}


void print_ast_dot_recursive(std::ofstream& file, node* node) {
    if (node == nullptr)
        return;

    std::string s = node->label;
    const char* v = s.c_str();
    file << "  node_" << node << " [label=\"" << v << "\"];\n";

    for (size_t i = 0; i < node->children.size(); i++) {
        if (node->children[i].first != nullptr) {
            std::string s1 = node->children[i].second;
            const char* v1 = s1.c_str();
            file << "  node_" << node << " -> node_" << node->children[i].first << " [label=\"" << v1 << "\"];\n";
            print_ast_dot_recursive(file, node->children[i].first);
        }
    }
}

void print_ast_dot_to_file(const std::string& filename, node* root) {
    std::ofstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Error opening file: " << filename << std::endl;
        exit(EXIT_FAILURE);
    }

    file << "digraph AST {\n";
    print_ast_dot_recursive(file, root);
    file << "}\n";
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
%}


%union{
    struct node* node;
    char* str;
}

%start start_file
%token <str> var
%token <str> semicolon
%token <str> NEWLINE
%token <str> EQUAL
%token <str> colon
%token <str> comma
%token <str> plus_eq
%token <str> minus_eq
%token <str> star_eq
%token <str> slash_eq
%token <str> double_slash_eq
%token <str> mod_eq
%token <str> double_star_eq
%token <str> a_eq
%token <str> o_eq
%token <str> x_eq
%token <str> lshift_eq
%token <str> rshift_eq
%token <str> indent
%token <str> dedent
%token <str> BREAK
%token <str> CONTINUE
%token <str> RETURN
%token <str> IF
%token <str> elif
%token <str> ELSE
%token <str> WHILE
%token <str> FOR
%token <str> in
%token <str> AND
%token <str> OR
%token <str> NOT
%token <str> is
%token <str> double_eq
%token <str> NOT_EQ
%token <str> GREATER
%token <str> lesser
%token <str> greater_eq
%token <str> lesser_eq
%token <str> PLUS
%token <str> MINUS
%token <str> star 
%token <str> slash
%token <str> double_slash
%token <str> double_star
%token <str> mod
%token <str> BIT_OR
%token <str> BIT_AND
%token <str> BIT_XOR
%token <str> BIT_NOT
%token <str> lshift
%token <str> rshift
%token <str> ropen
%token <str> rclose
%token <str> SOPEN
%token <str> sclose
%token <str> num
%token <str> STRING
%token <str> none
%token <str> TRUe
%token <str> FALSe
%token <str> dot
%token <str> CLASS
%token ENDMARKER
%token <str> arrow
%token <str> def

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
%type <node> annasign
%type <str> augasign
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
%type<node> test_plus
%type <node> and_expr
%type <node> shift_expr
%type <node> arith_expr
%type <node> term
%type <node> factor
%type <node> power
%type <node> atom_expr
%type <node> trailer
%type <node> atom
%type <node> string_plus
%type <node> arglist
%type <node> argument
%type <node> exprlist
%type <node> testlist
%type <node> classdef
%type <node> test_new
%type <node> expr_new
%type <node> arg_new
%type <node> typedargslist_new
%%
start_file :NEWLINE start_file | file_input{  root =$1;};
file_input : stmt_plus ENDMARKER {
            struct node* temp= new_NODE();
            temp->label="code start";
            temp->children.push_back({$1,""});//empty
             $$=temp;
            }
            | ENDMARKER {$$=NULL;};
stmt_plus : stmt_plus stmt{
    $1->children.push_back({$2,""});//empty, pusing back stmt
    $$=$1;
}
|stmt {
    struct node* temp=new_NODE();
    temp->label="stmt";
    temp->children.push_back({$1,""}); //empty
    $$=temp;
    };
 
funcdef : def var parameters colon suite{
    struct node* temp=new_NODE();
    temp->label=$1;
    struct node* temp1=new_NODE();
    string var=$2;
    string leaf_label= "var("+var+")";
    temp1->label=leaf_label;
    temp->children.push_back({temp1,"func name"});
    temp->children.push_back({$3,"params"});
    temp->children.push_back({$5,""}); //empty
    $$=temp;
}
|def var parameters arrow test colon suite{
    struct node* temp= new_NODE();
    temp->label=$1;
    struct node* temp1=new_NODE();
    string var=$2;
    string leaf_label= "var("+var+")";
    temp1->label=leaf_label;
    temp->children.push_back({temp1,"func name"});
    temp->children.push_back({$5,"type"});
    temp->children.push_back({$3,"params"});
    temp->children.push_back({$7,""});
    $$=temp;

};

parameters:ropen rclose {
    $$=NULL;
}
| ropen typedargslist rclose{
    $$=$2;
};

typedargslist: typedargslist_new {$$=$1;}
               |typedargslist_new comma {$$=$1;};

typedargslist_new: typedargslist_new comma tfpdef {
                   $$->children.push_back({$3,""});
                   }
                   |typedargslist_new comma tfpdef EQUAL test {
                    struct node*temp=new_NODE();
                    temp->label="=";
                    temp->children.push_back({$3,""});
                    temp->children.push_back({$5,""});
                    $$->children.push_back({temp,""});
                   }
                   |tfpdef {
                   $$=new_NODE();
                   $$->label="argument list";
                   $$->children.push_back({$1,""});}
                   |tfpdef EQUAL test {
                    struct node*temp=new_NODE();
                    temp->label="=";
                    temp->children.push_back({$1,""});
                    temp->children.push_back({$3,""});
                    $$=temp;
                   };              

tfpdef:test {$$=$1;}
|test colon test {
    struct node* temp=new_NODE();
    temp->label="argument";
    temp->children.push_back({$3,"type"});
    temp->children.push_back({$1,"name"});
    $$=temp;
};

stmt : simple_stmt {$$=$1;}
| compound_stmt {$$=$1;};

simple_stmt: small_stmt NEWLINE {$$=$1;}
| small_stmt semicolon simple_stmt{
  struct node* temp= new_NODE();
  temp->label= "stmt";
  temp->children.push_back({$1,""});
   temp->children.push_back({$3,"type"});
   $$=temp;
}
| small_stmt semicolon NEWLINE;

small_stmt: expr_stmt 
|flow_stmt;

expr_stmt: test annasign {
        $2->label="declare";
        $2->children.push_back({$1,"name"});
        $$=$2;
}
| test augasign test {
    if(strcmp($2,"+=")==0){
        $$=new_NODE();
        $$->label="=";
        $$->children.push_back({$1,""});
        struct node* temp=new_NODE();
        temp->label="+";
        temp->children.push_back({$1,""});
        temp->children.push_back({$3,""});
        $$->children.push_back({temp,""});
    }
    else if(strcmp($2,"-=")==0){
        $$=new_NODE();
        $$->label="=";
        $$->children.push_back({$1,""});
        struct node* temp=new_NODE();
        temp->label="-";
        temp->children.push_back({$1,""});
        temp->children.push_back({$3,""});
        $$->children.push_back({temp,""});
    }
    else if(strcmp($2,"*=")==0){
        $$=new_NODE();
        $$->label="=";
        $$->children.push_back({$1,""});
        struct node* temp=new_NODE();
        temp->label="*";
        temp->children.push_back({$1,""});
        temp->children.push_back({$3,""});
        $$->children.push_back({temp,""});
    }
    else if(strcmp($2,"/=")==0){
        $$=new_NODE();
        $$->label="=";
        $$->children.push_back({$1,""});
        struct node* temp=new_NODE();
        temp->label="/";
        temp->children.push_back({$1,""});
        temp->children.push_back({$3,""});
        $$->children.push_back({temp,""});
    }
    else if(strcmp($2,"//=")==0){
        $$=new_NODE();
        $$->label="=";
        $$->children.push_back({$1,""});
        struct node* temp=new_NODE();
        temp->label="//";
        temp->children.push_back({$1,""});
        temp->children.push_back({$3,""});
        $$->children.push_back({temp,""});
    }
    else if(strcmp($2,"%=")==0){
        $$=new_NODE();
        $$->label="=";
        $$->children.push_back({$1,""});
        struct node* temp=new_NODE();
        temp->label="%";
        temp->children.push_back({$1,""});
        temp->children.push_back({$3,""});
        $$->children.push_back({temp,""});
    }
    else if(strcmp($2,"**=")==0){
        $$=new_NODE();
        $$->label="=";
        $$->children.push_back({$1,""});
        struct node* temp=new_NODE();
        temp->label="**";
        temp->children.push_back({$1,""});
        temp->children.push_back({$3,""});
        $$->children.push_back({temp,""});
    }
    else if(strcmp($2,"&=")==0){
        $$=new_NODE();
        $$->label="=";
        $$->children.push_back({$1,""});
        struct node* temp=new_NODE();
        temp->label="&";
        temp->children.push_back({$1,""});
        temp->children.push_back({$3,""});
        $$->children.push_back({temp,""});
    }
    else if(strcmp($2,"|=")==0){
        $$=new_NODE();
        $$->label="=";
        $$->children.push_back({$1,""});
        struct node* temp=new_NODE();
        temp->label="|";
        temp->children.push_back({$1,""});
        $$->children.push_back({temp,""});
}
}
| test 
| test EQUAL test_plus {
    $$=new_NODE();
    $$->label=$2;
    $$->children.push_back({$1,""});
    $$->children.push_back({$3,""});
};
test_plus:  test EQUAL test_plus {
    $$=new_NODE();
    $$->label=$2;
    $$->children.push_back({$1,""});
    $$->children.push_back({$3,""});
}
| test ;
annasign : colon test {
    struct node* temp=new_NODE();
    temp->children.push_back({$2, "type"});
    $$=temp;
}
| colon test EQUAL test{
    struct node* temp=new_NODE();
    temp->label=$3;
    temp->children.push_back({$2,"type"});
    temp->children.push_back({$4,"value"});
    $$=temp;
};
augasign: plus_eq 
| minus_eq 
| star_eq 
| slash_eq 
| double_slash_eq 
| mod_eq 
| double_star_eq 
| a_eq 
| o_eq 
| x_eq 
| lshift_eq 
| rshift_eq ;

flow_stmt: break_stmt{$$=$1;}
|continue_stmt {$$=$1;}
|return_stmt {$$=$1;};

break_stmt: BREAK {
  struct node* temp=new_NODE();
  string var=$1;
    string leaf_label= "BREAK("+var+")";
    temp->label=leaf_label;
  $$=temp;
  };
continue_stmt: CONTINUE{struct node* temp=new_NODE();
    string var=$1;
    string leaf_label= "CONTINUE("+var+")";
    temp->label=leaf_label;
    $$=temp;};
return_stmt: RETURN { 
    struct node* temp=new_NODE();
    string var=$1;
    string leaf_label= "RETURN("+var+")";
    temp->label=leaf_label;
    $$=temp;}
    |RETURN test { 
    struct node* temp=new_NODE();
    temp->label=$1;
    temp->children.push_back({$2,"return val"});
    $$=temp;
    };

compound_stmt: if_stmt|while_stmt|for_stmt|funcdef|classdef;

if_stmt: IF test colon suite {
    struct node* temp=new_NODE();
    temp->label=$1;
    temp->children.push_back({$2,"condition"}); //for the condition
    temp->children.push_back({$4,"true"}); //for the body if the if is true
    $$=temp;
}
| IF test colon suite ELSE colon suite {
    struct node* temp=new_NODE();
    temp->label=$1;
    temp->children.push_back({$2,"condition"}); //for the condition
    temp->children.push_back({$4,"true"}); //for the body if the if is true
    struct node* temp1= new_NODE();
    temp1->label=$5;
    temp1->children.push_back({$7,""});
    temp->children.push_back({temp1,"false"}); //for the body if the if is false
    $$=temp;

}

 | IF test colon suite elif_star {
    struct node*temp=new_NODE();temp->label=$1;
    temp->children.push_back({$2,"condition"}); //for the condition
    temp->children.push_back({$4,"true"}); //for the body if the if is true
    temp->children.push_back({$5,"false"});
    $$=temp; 
 };
elif_star: elif test colon suite {
    struct node* temp=new_NODE();
    temp->label=$1;
    temp->children.push_back({$2,"condition"});
    temp->children.push_back({$4,"true"});
    $$=temp;
}
|elif test colon suite ELSE colon suite {
    struct node* temp=new_NODE();
    temp->label=$1;
    temp->children.push_back({$2,"condition"});
    temp->children.push_back({$4,"true"});
    struct node* temp1= new_NODE();
    temp1->label=$5;
    temp1->children.push_back({$7,""});
    temp->children.push_back({temp1,"false"});
    $$=temp;
}
| elif test colon suite elif_star {
    struct node* temp=new_NODE();
    temp->label=$1;
    temp->children.push_back({$2,"condition"});
    temp->children.push_back({$4,"true"});
    temp->children.push_back({$5,""});
    $$=temp;

}; 

while_stmt: WHILE test colon suite{
    struct node* temp=new_NODE();temp->label=$1;
    temp->children.push_back({$2,"condition"}); //test of the while
    temp->children.push_back({$4,"true"}); //for the body for the while 
    $$=temp;
}
| WHILE test colon suite ELSE colon suite{
    struct node* temp=new_NODE();temp->label=$1;
    temp->children.push_back({$2,"condition"}); //test of the while
    temp->children.push_back({$4,"true"}); //for the body for the while 
    struct node* extra_temp_node= new_NODE();
    extra_temp_node->label=$5;
    extra_temp_node->children.push_back({$7,""}); //suite is the only child of else
    temp->children.push_back({extra_temp_node,"false"}); //else is another child of while
    $$= temp;
}
;
for_stmt: FOR exprlist in testlist colon suite {
    struct node* temp=new_NODE();
    temp->label="for";
    // int k=0;
    for (auto i:$2->children){
        temp->children.push_back({i.first,"iterator"});
    }
    delete($2);
    //cout<<($2->children[0]).first->label<<endl;
    //temp->children.push_back({$4,"range"});
    for(auto i: $4->children) temp->children.push_back({i.first,"iteratable"});
    delete($4);
    temp->children.push_back({$6,"true"});
    $$=temp;
}
| FOR exprlist in testlist colon suite ELSE colon suite{
     $2->label="for";
     int k=0;
    for (auto i:$2->children){
        k++;
        i.second+="iter";
        //cout<<i.second<<endl;
    }
    //cout<<k<<endl;
    //temp->children.push_back({$4,"range"});
    for(auto i: $4->children) $2->children.push_back(i);
    $2->children.push_back({$6,"true"});
    struct node* temp1= new_NODE();
    temp1->label=$7;
    temp1->children.push_back({$9,""});
    $2->children.push_back({temp1,"false"});
    $$=$2;
};

suite:simple_stmt {$$=$1;}
|NEWLINE indent stmt_plus dedent{
    
    $$=$3;
};

test: or_test {$$=$1;}
    |or_test IF or_test ELSE test {

        struct node* temp=new_NODE();
        temp->label="if";
        temp->children.push_back({$3, "condition"});
        temp->children.push_back({$1, "True"});
        temp->children.push_back({$5, "False"});
       $$=temp;

    };

or_test:and_test {$$=$1;}
| or_test OR and_test{
    struct node* temp=new_NODE();
    temp->label=$2;
    temp->children.push_back({$1,""});
    temp->children.push_back({$3,""});
    $$=temp;
};

and_test:not_test {$$=$1;}
|and_test AND not_test{
    struct node* temp=new_NODE();
    temp->label=$2;
    temp->children.push_back({$1,""});
    temp->children.push_back({$3,""});
    $$=temp;
};

not_test: NOT not_test {
    struct node* temp=new_NODE();
    temp->label=$1;
    temp->children.push_back({$2,""});
    $$=temp;}
 | comparison {$$=$1;};

comparison: expr{$$=$1;}
|expr comp_op comparison{
    $2->children.push_back({$1,""});
    $2->children.push_back({$3,""});
    $$=$2;
};

comp_op: double_eq {
    struct node* temp=new_NODE();
    temp->label=$1;
    $$=temp;}
| NOT_EQ 
{struct node* temp=new_NODE();
temp->label=$1;
$$=temp;}
| GREATER  
{struct node* temp=new_NODE();
temp->label=$1;
$$=temp;}
| lesser  
{struct node* temp=new_NODE();
temp->label=$1;
$$=temp;}
| greater_eq  
{struct node* temp=new_NODE();
temp->label=$1;
$$=temp;}
| lesser_eq  
{struct node* temp=new_NODE();
temp->label=$1;
$$=temp;}
| in  
{struct node* temp=new_NODE();
temp->label=$1;
$$=temp;}
| NOT in 
{struct node* temp=new_NODE();
temp->label=$1;
$$=temp;}
| is  
{struct node* temp=new_NODE();
temp->label=$1;
$$=temp;}
| is NOT 
{struct node* temp=new_NODE();
temp->label=$1;
$$=temp;};

expr:xor_expr{$$=$1;}
| expr BIT_OR xor_expr{
struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
};

xor_expr: and_expr{$$=$1;}
| xor_expr BIT_XOR and_expr{
struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
};

and_expr:shift_expr {$$=$1;}
| and_expr BIT_AND shift_expr{
struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
};

shift_expr:arith_expr{ $$=$1;}
|shift_expr lshift arith_expr{
struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
}
|shift_expr rshift arith_expr{
struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
};

arith_expr:term{$$=$1;}
|arith_expr PLUS term{
struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
}
|arith_expr MINUS term{
struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
};

term:factor {$$=$1;}
|term star factor {struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;}
|term slash factor {
    struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
}
|term double_slash factor
{
struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
}
|term mod factor{
struct node* temp=new_NODE();
temp->label=$2;
temp->children.push_back({$1,""});
temp->children.push_back({$3,""});$$=temp;
};

factor:PLUS factor { 
    struct node* temp=new_NODE();temp->label=$1;
    temp->children.push_back({$2,""}); //only child is factor
    $$=temp;}
|MINUS factor {
    struct node* temp=new_NODE();temp->label=$1;
    temp->children.push_back({$2,""}); //only child is factor
    $$=temp;
}
|BIT_NOT factor {
    struct node* temp=new_NODE();temp->label=$1;
    temp->children.push_back({$2,""}); //only child is factor
    $$=temp;
}
|power {$$=$1;}
;
power:atom_expr {$$=$1;}|atom_expr double_star factor{
    struct node* temp=new_NODE();temp->label=$2;
    temp->children.push_back({$1,""}); //left child is atom_expr
    temp->children.push_back({$3,""}); //right child is factor
    $$=temp;
};

atom_expr: atom | atom_expr trailer {
    struct node*temp=new_NODE();
    temp->children.push_back({$1,edge.c_str()}); //left child is atom_expr
    temp->label=head;
    if($2){
        temp->children.push_back({$2,""}); //right child is factor
    }
    $$=temp;
}



atom: ropen testlist rclose {
        $2->label="( )";
        $$=$2;

        // struct node*temp_node1=new_NODE();
        // temp_node1->label=$1;
        // struct node*temp_node2=new_NODE();
        // temp_node2->label=$3;
        // temp_node1->children.push_back({$2,""}); 
        // temp_node1->children.push_back({temp_node2,""}); 
        // $$=temp_node1;
        
}
|SOPEN testlist sclose {
    $2->label="[]";
    $$=$2;
    
}
|ropen rclose {
    struct node* temp=new_NODE();
    temp->label="( )";
    $$=temp;
    }
|SOPEN sclose {
    struct node* temp=new_NODE();
    temp->label="[]";
    $$=temp;
}

|var {struct node*temp=new_NODE();
        string var=$1;
        string leaf_label= "var("+var+")";
        temp->label=leaf_label;
    $$=temp;}
|num {struct node*temp=new_NODE();
        string var=$1;
        string leaf_label= "num("+var+")";
        temp->label=leaf_label;
        $$=temp;}
|string_plus 
|none {struct node*temp=new_NODE();string var=$1;
        string leaf_label= "none("+var+")";
        temp->label=leaf_label;
        $$=temp;}
|TRUe {struct node*temp=new_NODE();
        string var=$1;
        string leaf_label= "TRUe("+var+")";
        temp->label=leaf_label;
        $$=temp;}
|FALSe{struct node*temp=new_NODE();
        string var=$1;
        string leaf_label= "FALSe("+var+")";
        temp->label=leaf_label;
        $$=temp;};


string_plus:string_plus STRING{
    struct node* temp1=new_NODE();
    string var=$2;
        string leaf_label= "STRING("+var+")";
        temp1->label=leaf_label;
    //temp1->label=$2;
    $1->children.push_back({temp1,""});
    $$=$1;
}
|STRING{
    struct node* temp=new_NODE();
    temp->label="string";
   struct node* temp1=new_NODE();
    string var=$1;
        string leaf_label= "STRING("+var+")";
        temp1->label=leaf_label;
    temp->children.push_back({temp1,""});
    $$=temp;
};

trailer: ropen rclose{$$=NULL;head="Function";edge="Name";} 
|ropen arglist rclose  {$$=$2;head="Function";edge="Name";}
|SOPEN arglist sclose {$$=$2;head="[]";edge="";} 
| dot var {$$=new_NODE();$$->label=$2;head=".";edge="";}




exprlist: expr_new {$$=$1;}
| expr_new comma  {
    $$=$1; 
};

expr_new:expr_new comma expr {$1->children.push_back({$3,""});$$=$1;}
|expr {$$=new_NODE();$$->label="exprlist";$$->children.push_back({$1,""});};


testlist: test_new {$$=$1;}
| test_new comma  {
    $$=$1; 
};
test_new:test_new comma test {$1->children.push_back({$3,""});$$=$1;}
|test {$$=new_NODE();$$->label="testlist";$$->children.push_back({$1,""});};

classdef: CLASS var colon suite {
    struct node* temp=new_NODE();
    temp->label=$1;
    struct node* temp1=new_NODE();
    //temp1->label=$2;
    string var=$2;
        string leaf_label= "var("+var+")";
        temp1->label=leaf_label;
    temp->children.push_back({temp1,"class name"});
    temp->children.push_back({$4,""});
    $$=temp;
}
|CLASS var ropen rclose colon suite{
    struct node* temp=new_NODE();
    temp->label=$1;
    struct node* temp1=new_NODE();
    //temp1->label=$2;
        string var=$2;
        string leaf_label= "var("+var+")";
        temp1->label=leaf_label;
    temp->children.push_back({temp1,""});
    temp->children.push_back({$6,""});
    $$=temp;
}
|CLASS var ropen arglist rclose colon suite{
    struct node* temp=new_NODE();
    temp->label=$1;
    struct node* temp1=new_NODE();
    //temp1->label=$2;
        string var=$2;
        string leaf_label= "var("+var+")";
        temp1->label=leaf_label;
    temp->children.push_back({temp1,""});
    temp->children.push_back({$4,""});
    temp->children.push_back({$7,""});
    $$=temp;
};



arglist: arg_new {$$=$1;}
| arg_new comma  {
    $$=$1; 
};
arg_new:arg_new comma argument {$1->children.push_back({$3,""});$$=$1;}
|argument {
    $$=new_NODE();
    $$->label="arguments";
    $$->children.push_back({$1,""});
    
};

argument:test {$$=$1;}
|test EQUAL test { 
   struct node*temp=new_NODE();
   temp->label=$2;
   temp->children.push_back({$1,""});
   temp->children.push_back({$3,""});
   $$=temp;
};





%%

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
    print_ast_dot_to_file(output_file.c_str(), root);
    fclose(program);

}


void yyerror(const char *s) {
    fprintf(stderr,"error in parsing,%d\n",yylineno);
}