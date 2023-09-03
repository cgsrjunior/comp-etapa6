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

string generate_label_lbf_while(){
    string str;
    str = ".LBF" + std::to_string(counter) + ":\n";
    counter++;
}

void print_line_asm(Operation_Asm_Item item){
    if(item.label_needed)
        generate_func_label(item.instruction);
    else
        if((item.op1 == "") && (item.op2 == "")){
            cout << "\t" << item.instruction << endl;
        }
        else if(item.op2 == ""){
            cout << "\t" << item.instruction << " " << item.op1 << endl;
        }
        else{
            cout << "\t" << item.instruction << " " << item.op1 << ", " << item.op2 << endl;
        }
}