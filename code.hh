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
};