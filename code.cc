#include <iostream>
#include "code.hh"

//This counter will be use to generate new LBFs if necessary
//EX: LBF0: , LBF1 and so on
int counter = 0;

void generate_label_lbf(){
    cout << ".LBF" << counter << ":" << endl;
    counter++;
}