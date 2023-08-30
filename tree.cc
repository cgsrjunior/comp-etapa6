#include <iostream>
#include <string>
#include <sstream>
#include <algorithm>
#include "tree.hh"

using namespace std;

extern int yylineno;

AstNode::AstNode(int number, TkType token_tp, string value){
    this->lex.line_number = number;
	this->lex.token_type = token_tp;
	this->lex.token_val = value;
}


void AstNode::add_child(AstNode* child) {
    try{
        if (child != nullptr) {
            this->children.push_back(smart_pointer(child));
        }
    }
    catch(const exception& er)
    {
        cout<< "Exception caught: " << er.what() << endl;
    }
}

string AstNode::formatstring() {
        try{
            switch (this->lex.token_type) {
            /*
                case TkType::TK_SP_CHAR:
                    return string(&get<char>(this->lex.token_val), 1);
                case TkType::TK_PR:
                case TkType::TK_OC:
                    return string(get<string>(this->lex.token_val)); 
            */
                case TkType::TK_ID:
                    if (this->func_call) {
                        return string("call ")+ this->lex.token_val;
                    }
                    else 
                        return this->lex.token_val;          
            /*            
                case TkType::TK_LIT_INT:
                    //return to_string(get<int>(this->lex.token_val));
                case TkType::TK_LIT_FLOAT:
                    //return to_string(get<float>(this->lex.token_val));
                case TkType::TK_LIT_BOOL:
                    //return to_string(get<bool>(this->lex.token_val));
            */
                default:
                    return this->lex.token_val;
                }
        }
        catch (const exception& er){
            std::cout << er.what() << endl;
        }
    return this->lex.token_val;
}

void AstNode::reg_func_call(bool value){ 
    try{
        this->func_call = value;
    }
    catch(const exception& er)
    {
        cout<< "Exception caught: " << er.what() << endl;
    }
}

void print_tree(shared_ptr<AstNode> tree) {
    try{
        cout << tree << " [label=\"" << tree->formatstring() << "\"];" << endl;
	    for (auto& child : tree->children) {
		    cout << tree << ", " << child << endl;
		    print_tree(child);
    	}
    }
    catch(const exception& er)
    {
        cout<< "Exception caught: " << er.what() << endl;
    }
}

void exporta(void* tree) {
    try{
        if (tree != nullptr) {
            auto arv = shared_ptr<AstNode>((AstNode*) tree);
            print_tree(arv);
        }
    }
    catch(const exception& er)
    {
        cout<< "Exception caught: " << er.what() << endl;
    }

    
}

int checkAtrib(shared_ptr<AstNode> node){
    if (node != nullptr)
        if (node->lex.token_val.find("<="))
            return 1;
    return 0;
}

string nodetype_to_string(NodeType node_type){

    //Since we need this to put the type on the symbol table
    //This should be working
    switch(node_type){
        case NodeType::BOOL_TYPE:
            return "bool";
        case NodeType::INT_TYPE:
            return "int";
        case NodeType::FLOAT_TYPE:
            return "float";
        default:
            return "Algo deu errado.";
    }
}

NodeType string_to_nodetype(string node_type){

    //Since we need this to put the type on the symbol table
    //This should be working
    if( node_type == "bool"){
        return NodeType::BOOL_TYPE;
    }
    else if( node_type == "int"){
        return NodeType::INT_TYPE;
    }
    else if( node_type == "float"){
        return NodeType::FLOAT_TYPE;
    }
    else{
        return NodeType::ERROR_TYPE;
    }
}

/*
shared_ptr<AstNode> lastNode(shared_ptr<AstNode> node){
    
    if(node->children.empty()){
        return node;
    }

    shared_ptr<AstNode> last_element = node->children.back();

  == TODO TOMORROW
    while(node->children->lex.token_type != TkType::TK_ID){
        cout << "AAAAAAAAAAAAAAAAAAAAAAAA" << endl;
    }


    Tipo tipo = nodo->filho[ultimo]->lexico->tipo;
    char valor = nodo->filho[ultimo]->lexico->valor;

    while (tipo == OPERADOR_COMPOSTO  tipo == CARACTERE_ESPECIAL   tipo == PALAVRA_RESERVADA)
    {
        nodo = nodo->filho[ultimo];
        if(nodo->num_filhos == 0)
        {
            break;
        }
        ultimo = nodo->num_filhos - 1;
        tipo = nodo->filho[ultimo]->lexico->tipo;
        valor = nodo->filho[ultimo]->lexico->valor;
    }
    return nodo;
}
*/
