#pragma once
#include <iostream>
#include <string>

using namespace std;

//This struct should be only used to store global items
//The idea here is create a list of global declarations
//and then use the accumulated info to mount the final header
struct Global_Asm_Item{
    string global_label;
    int size_item;
    //If is a function or a object
    string global_type;
    //In case of global declarations, we going to use this flag whenever we need to introduce
    // .comm inside a declaration block
    bool set_value;
};

//Struct to store the current operation on the tree
struct Operation_Asm_Item{
    //Label of the instruction
    string instruction;
    //The value of first operand
    int op1;
    //The value of second operand
    int op2;
};

//Auxiliary functions
void generate_label_lbf();