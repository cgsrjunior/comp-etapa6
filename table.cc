#include <iostream>
#include <string>
#include <algorithm>
#include <map>
#include "table.hh"

using namespace std;

//This code will find the column that the element was given
//If a element cannot be found, return -1
int StackTable::find_symbol_table(string token_value) {
    int i = 0;
    for (i = this->stack_table.size()-1; i>=0; i--) {
        if (this->stack_table[i].label.compare(token_value) == 0){
            break;
        }
    }
    return i;
}

//This code will find the column that the element was given if
//token value and id_nature matches the searching
//If a element cannot be found, return -1
int StackTable::find_symbol_filter_type(string token_value, Nature id_nature) {
    int i = 0;
    for (i = this->stack_table.size()-1; i>=0; i--) {
        if ((this->stack_table[i].label.compare(token_value) == 0) && this->stack_table[i].data.nature == id_nature){
            break;
        }
    }
    return i;
}


Symbol StackTable::get_symbol_occurence(string token_value){
    int i = this->find_symbol_table(token_value);
    if (i <= 0){
        exit(ERR_UNDECLARED);
    }
    else{
        //This will return a symbol structure
        return this->stack_table[i].data;
    }
}

//Get symbol addr reference
Symbol& StackTable::rec_symbol_occurence(string key_value){
    int i = this->find_symbol_table(key_value);
    if (i <= 0){
        exit(ERR_UNDECLARED);
    }
    //This will return a symbol structure
    return this->stack_table[i].data;
}



Symbol StackTable::get_symbol_by_type(string token_value, Nature id_nature){
    int i = this->find_symbol_filter_type(token_value, id_nature);
    if (i <= 0){
        exit(ERR_UNDECLARED);
    }
    else{
        //This will return a symbol structure
        return this->stack_table[i].data;
    }
}

//This function should be used to check if we launch a declared or undeclared
// variable error
bool StackTable::value_declared(string value){
    return find_symbol_table(value) >= 0;
}

//This function should be used to check if we launch a declared or undeclared
// variable error
bool StackTable::value_declared_nature_filter(string value, Nature id_nature){
    return find_symbol_filter_type(value, id_nature) >= 0;
}

void StackTable::create_table_entry(string token_value, Symbol ast_symbol){
    //Check if variable exists before and in case of non-existant,
    //create the variable entry in the stack
    SymbolList new_data{
        token_value,
        ast_symbol
    };
        this->stack_table.push_back(new_data);
}

void StackTable::create_atribution_entry(string token_value, Symbol ast_symbol){
    //Check if variable exists before and in case of existant,
    //create the atribution symbol entry in the stack
    if(value_declared(token_value)){
        SymbolList new_data{
            token_value,
            ast_symbol
        };
        this->stack_table.push_back(new_data);
    }
    else{
        exit(ERR_UNDECLARED);
    }   
}

int check_bad_attrib(Nature expected, Nature received) {
    if (expected != received)
        switch (expected) {
            case Nature::LIT: //Omissão de warning
                return 0;
            case Nature::ID:
                return ERR_VARIABLE;
            case Nature::FUNC:
                return ERR_FUNCTION;
        }
    return 0; //Result expected
}

NodeType inference_type (NodeType id_type_1, NodeType id_type_2) {
/*
 *  Dado dois simbolos, faz inferência e retorna o tipo.
 */

    if (id_type_1 == id_type_2) {
        return id_type_1;
    }
    else if (id_type_1 == NodeType::FLOAT_TYPE && id_type_2 == NodeType::INT_TYPE){
        return NodeType::FLOAT_TYPE;
    }        
    else if (id_type_1 == NodeType::BOOL_TYPE && id_type_2 == NodeType::INT_TYPE){
        return NodeType::INT_TYPE;
    }
    else if (id_type_1 == NodeType::BOOL_TYPE && id_type_2 == NodeType::FLOAT_TYPE){
        return NodeType::FLOAT_TYPE;
    }
    else
         return NodeType::ERROR_TYPE;
}