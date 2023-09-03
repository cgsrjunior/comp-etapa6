#pragma once
#include <vector>
#include <string>
#include <memory>
#include "code.hh"

using namespace std;

//Enum for the new field specified in E4
enum class NodeType{
    INT_TYPE,
    FLOAT_TYPE,
    BOOL_TYPE,
    ERROR_TYPE
};

enum class TkType {
    TK_SP_CHAR, // char
    TK_PR, // std::string
    TK_OC, // std::string
    TK_ID, // std::string
    TK_LIT_INT, // int
    TK_LIT_FLOAT, // float
    TK_LIT_BOOL, // bool
    TK_TYPE_ERROR //Error signaling
};

const vector<char> invalid_chars {',', ';', '(', ')', '{', '}', '[', ']'};

struct LexValue {
    int line_number;
    TkType token_type;
    string token_val;
};

struct AstNode {
    public:
        LexValue lex;
        vector<shared_ptr<AstNode>> children;
        bool func_call = false;

        //This field will determined by the operation of the node if necessary
        NodeType type;

        //New fields for e6
        //This need to be a list because one command line can be translated
        //into multiple functions
        vector<Operation_Asm_Item> code;

        //New functions for e6
        inline void attach_code(Operation_Asm_Item inst) { code.push_back(inst); };


        //End definitions for e6

        //Gets and sets for the new type field defined in E4
        inline NodeType get_type_node()                { return this->type; }
        inline void set_type_node(NodeType new_type)   { this->type = new_type; }

        //Create new gets and sets for token_value
        inline string get_tk_value()                   { return this->lex.token_val; }
        inline void   set_tk_value(string token_value) { this->lex.token_val = token_value; }

        //Function for getting line number of current command of ast
        inline int get_line_num() { return this->lex.line_number; }

        //Constructor - create only node without child
        AstNode(int number, TkType token_tp, string value);
        //Function to add child
        void add_child(AstNode *node);
        //Convert labels into string
        string formatstring();
        void reg_func_call(bool value);

};

//Convert node label to string
string nodetype_to_string(NodeType node);
NodeType string_to_nodetype(string node_type);
//Smart pointer for the tree
typedef shared_ptr<AstNode> smart_pointer;
//Function to export the tree
void exporta(void* tree);
//Function to print the tree
void print_tree(shared_ptr<AstNode> tree);
//Get last node
shared_ptr<AstNode> lastNode(shared_ptr<AstNode> node);
//Check node attribute
int checkAtrib(shared_ptr<AstNode> tree);