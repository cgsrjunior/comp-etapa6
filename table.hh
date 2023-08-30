#pragma once
#include <vector>
#include <string>
#include "tree.hh"

using namespace std;

//2.1 field request nature
enum class Nature {
    LIT,
    ID,
    FUNC
};

//B Códigos de retorno 
#define ERR_UNDECLARED 10 //2.2
#define ERR_DECLARED 11 //2.2
#define ERR_VARIABLE 20 //2.3
#define ERR_FUNCTION 21 //2.3

struct Symbol {
    int line;
    Nature nature;
    string type; //TODO check this after finished
    AstNode* data;
};

struct SymbolList{
    string label; //Token Value
    Symbol data;
};


//Structure to declare whenever we push/pop tables
struct StackTable {
    vector<SymbolList> stack_table {};

    //Initialize the stack
    inline void create_new_stack(){ this->stack_table.push_back(SymbolList{});}

    //Get and set for stacktable
    inline void push_table(SymbolList& tb) { this->stack_table.push_back(tb); }
    inline void pop_table()                { this->stack_table.pop_back(); } //Remove the table on the top of the program

    //Pick up the last table whenever needed
    SymbolList& return_top()               { return this->stack_table.back(); }

    int find_symbol_table(string token_value); //Returned the index found in the table
    int find_symbol_filter_type(string token_value, Nature id_nature); 

    Symbol get_symbol_occurence(string token_value);

    //Search function with filters
    Symbol get_symbol_by_type(string token_value, Nature id_nature);

    //Working fine for tests
    bool value_declared(string value);
    //This is the definitive search
    bool value_declared_nature_filter(string value, Nature id_nature);

    //Check declarations for raise ERR_DECLARED/UNDECLARED
    void create_table_entry(string token_value, Symbol ast_symbol);
    void create_atribution_entry(string token_value, Symbol ast_symbol);

    Symbol get_symbol_table(string value);

    //New functions for e5
    Symbol& rec_symbol_occurence(string key_value);
};

int check_bad_attrib(Nature expected, Nature received);

NodeType inference_type(NodeType id_type_1, NodeType id_type_2);