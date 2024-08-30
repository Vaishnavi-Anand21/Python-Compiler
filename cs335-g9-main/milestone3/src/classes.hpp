#ifndef CLASSES_HPP
#define CLASSES_HPP

#include<bits/stdc++.h>
#include<unordered_map>
using namespace std;


struct quadraple {
    string op;
    string arg1;
    string arg2;
    string result;
};

class Node {
public:
    string name;
    string type = "";
    bool filled_flow=false;
    bool l_value = false; // left side assignment - true
    bool isConst = false;
    bool isCheck = false; // set to true when accessed by 1st time
    bool isLeaf = true;   // declaration - true
    bool isList = false;
    bool list_access=false;
    int no_of_arguments = 0;
    int str_len=0;
    bool isinitial=false;
    string ret_type = "";
    vector<quadraple*> truelist;
    vector<quadraple*> falselist;
    string tempvar;
    Node() {
        // Initialize member variables with default values
        name = "";
        type = "";
        l_value = false;
        isConst = false;
        isCheck = false;
        isLeaf = true;
        
        isList = false;
        no_of_arguments = 0;
        ret_type = "";
        tempvar = "";
        // Note: truelist and falselist vectors will be initialized empty by default
    }

    Node(string label, string type, bool l_value) {
        this->name = label;
        this->type = type;
        this->l_value = l_value;
    }

    Node(const char* label, string type, bool l_value) {
        this->name = label;
        this->type = type;
        this->l_value = l_value;
    }

    Node(const char* label) {
        this->name = label;
    }

    Node(const char* label, string type, bool l_value, bool isConst) {
        this->name = label;
        this->type = type;
        this->l_value = l_value;
        this->isConst = isConst;
    }
};

class Symbol {
public:
    string name;
    string type;
   int num_e=0;
    bool isinitial=false;
    unsigned long lineno;
    unsigned long size = 0;
    unsigned long offset=0;
    int str_len=0;
    //unsigned long long base_addr;
    int no_of_arguments = 0;
    bool isList = false;
    string ret_type = "";
};

class Symbol_table {
public:
    unordered_map<string, Symbol*> tab_var;
    unordered_map<string, Symbol*> tab_func_class;
    string type;
    string name;
    vector<string> arguments;
    Symbol_table* parent;
    vector<string> ordered_var;
    unordered_map<string, Symbol_table*> children;
    Symbol_table* inherited;
    int inherited_size=0;
    string ret_type = "";
    int no_of_arguments = 0;
    unsigned long line_no;
    unsigned long offset=0;

    Symbol_table() : parent(nullptr), inherited(nullptr), line_no(0) {
        Symbol* s=new Symbol();
        s->name="int";
        s->type="class";
        s->lineno= 0;
        s->size=4;
        this->tab_func_class["int"]=s;
        Symbol_table* child=new Symbol_table(this, 0, "int");
        child->type="class";
        this->children["int"]=child;
        s=new Symbol();
        s->name="bool";
        s->size=1;
        s->type="class";
        s->lineno= 0;
        this->tab_func_class["bool"]=s;
         child=new Symbol_table(this, 0, "bool");
        child->type="class";
        this->children["bool"]=child;
        s=new Symbol();
        s->name="float";
        s->size=8;
        s->type="class";
        s->lineno= 0;
        this->tab_func_class["float"]=s;
         child=new Symbol_table(this, 0, "float");
        child->type="class";
        this->children["float"]=child;
        s=new Symbol();
        s->name="str";
        s->size=0;
        s->type="class";
        s->lineno= 0;
        this->tab_func_class["str"]=s;
         child=new Symbol_table(this, 0, "str");
        child->type="class";
        this->children["str"]=child;
        s=new Symbol();
        s->name="__name__";
        s->type="str";
        s->lineno= 0;
         s->isinitial=true;
        this->tab_var["__name__"]=s;

        s=new Symbol();
        s->name="print";
       
        s->type="function";
        s->lineno= 0;
        this->tab_func_class["print"]=s;
        child=new Symbol_table(this, 0, "print");
        child->type="function";
        this->children["print"]=child;
        s=new Symbol();
        s->name="range";
        s->type="function";
        s->lineno= 0;
        s->ret_type="int";
        this->tab_func_class["range"]=s;
        child=new Symbol_table(this, 0, "range");
        child->ret_type="int";
        child->type="function";
        this->children["range"]=child;
        s=new Symbol();
        s->name="len";
        s->type="function";
        s->lineno= 0;
        s->ret_type="int";
        this->tab_func_class["len"]=s;
        child=new Symbol_table(this, 0, "len");
        child->ret_type="int";
        child->type="function";
        this->children["len"]=child;
       
    }

    Symbol_table(Symbol_table* p, unsigned long l, string key_type) {
        //cout<<"i hate this"<<p->name<<" "<<key_type<<endl;
        parent = p;
        line_no = l;
        
        if (p->children.find(key_type) != p->children.end()) {
            p->children.erase(key_type);
        }
        p->children.insert({key_type, this});
        this->name=key_type;
    }
};

#endif // YOUR_HEADER_FILE_HPP
