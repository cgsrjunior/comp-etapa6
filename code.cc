#include <iostream>
#include "code.hh"

//This counter will be use to generate new LBFs if necessary
//EX: LBF0: , LBF1 and so on
int counter = 0;

//Function to use when instruction = function definition
void generate_func_label(string name_func){
    cout << name_func << ":" << endl;
    generate_label_lbf();
    //cout << ".LBF" << counter << ":" << endl;
    counter++;
}

void generate_label_lbf(){
    cout << ".LBF" << counter << ":" << endl;
    counter++;
}

void print_line_asm(Operation_Asm_Item item){
    cout << "\t" << item.instruction << item.op1 << item.op2 << endl;
}