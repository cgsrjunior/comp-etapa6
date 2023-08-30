
/* Trabalho de Compiladores - Cleiber Rodrigues e Cintia Valente */
/* Cartões: 00270139 - 00228540 */

%{
#include <iostream>
#include <memory>
#include "tree.hh"
#include "table.hh"
#include "iloc.hh"

using namespace std;

extern int get_line_number(void);
void throw_error_message (AstNode* node, int error_code);
extern void *arvore;
int yylex(void);
int yyerror (const char *message);

StackTable stack_table{};
string main_token;
label_type main_label = 99;
vector<vector<reg_type>> param_regs {};
vector<Token_assoc> label_memory {};

%}

%code requires{
      #include <memory>
      #include "tree.hh"
      #include "table.hh"
      #include "iloc.hh"
}

%union {
      AstNode* valor_lexico;
}

%define parse.error verbose

%token<valor_lexico> TK_PR_INT
%token<valor_lexico> TK_PR_FLOAT
%token<valor_lexico> TK_PR_BOOL
%token<valor_lexico> TK_PR_IF
%token<valor_lexico> TK_PR_ELSE
%token<valor_lexico> TK_PR_WHILE
%token<valor_lexico> TK_PR_RETURN
%token<valor_lexico> TK_OC_LE
%token<valor_lexico> TK_OC_GE
%token<valor_lexico> TK_OC_EQ
%token<valor_lexico> TK_OC_NE
%token<valor_lexico> TK_OC_AND
%token<valor_lexico> TK_OC_OR
%token<valor_lexico> TK_OC_MAP
%token<valor_lexico> TK_IDENTIFICADOR
%token<valor_lexico> TK_LIT_INT
%token<valor_lexico> TK_LIT_FLOAT
%token<valor_lexico> TK_LIT_FALSE
%token<valor_lexico> TK_LIT_TRUE
%token<valor_lexico> TK_ERRO
%token<valor_lexico> '-' '!' '*' '/' '%' '+' '<' '>' '&' '|' '='

%type<valor_lexico> programa
%type<valor_lexico> list_decl
%type<valor_lexico> decl
%type<valor_lexico> var
%type<valor_lexico> list_id
%type<valor_lexico> type
%type<valor_lexico> func
%type<valor_lexico> list_param
%type<valor_lexico> body
%type<valor_lexico> list_cmd
%type<valor_lexico> cmd
%type<valor_lexico> cmd_flux_ctrl
%type<valor_lexico> cmd_func_call
%type<valor_lexico> func_call_param
%type<valor_lexico> unary_operand
%type<valor_lexico> bin_sec_expr
%type<valor_lexico> bin_thr_expr
%type<valor_lexico> bin_fou_expr
%type<valor_lexico> bin_fif_expr
%type<valor_lexico> bin_six_expr
%type<valor_lexico> bin_sev_expr
%type<valor_lexico> expr
%type<valor_lexico> expr_1
%type<valor_lexico> expr_2
%type<valor_lexico> expr_3
%type<valor_lexico> expr_4
%type<valor_lexico> expr_5
%type<valor_lexico> unary_expr
%type<valor_lexico> parenthesis_prec
%type<valor_lexico> operand
%type<valor_lexico> list_arg
%type<valor_lexico> cmd_var
%type<valor_lexico> cmd_atrib
%type<valor_lexico> init_var
%type<valor_lexico> cmd_return
%type<valor_lexico> list_id_atrib
%type<valor_lexico> id_atrib
%type<valor_lexico> lit
%type<valor_lexico> id_label
%type<valor_lexico> name_func
%type<valor_lexico> id_param
%type<valor_lexico> id_var_decl
%type<valor_lexico> id_var

%start programa

%%

programa    : {stack_table.create_new_stack();} list_decl {
               $$ = $2;
               //e5 goes here - main label generation
               //Command list declarations
               auto main_symbol_table = stack_table.rec_symbol_occurence(main_token);
               vector<Command> code = create_call_commands(main_label, main_symbol_table, {});

               // Using insert - vector library
               code.insert(code.begin(), Command{Instruct::ADD_I, Cod_ILOC::RSP, 4, Cod_ILOC::RSP, Cod_ILOC::NO_REG});
               code.insert(code.begin(), Command{Instruct::I2I, Cod_ILOC::RFP, Cod_ILOC::NO_REG, Cod_ILOC::RSP, Cod_ILOC::NO_REG});
               Cod_ILOC::label_type end = Cod_ILOC::get_new_label();
               code.push_back(Command{Instruct::JUMP_I, Cod_ILOC::NO_REG, Cod_ILOC::NO_REG, end, Cod_ILOC::NO_REG});
               for (auto command : $2->code_element.code) {
                  code.push_back(command);
               }
               //Nedd to out a halt on this code
               code.push_back(Command{end, Instruct::HALT});
               //Hanging code into the tree
               $2->code_element.code = code;
               //End main code generation
               arvore = $$; 
               stack_table.pop_table();
            }
            ;
        
list_decl   : list_decl decl {
              if($2!=nullptr && $1!=nullptr){
                  $$ = $1;
                  $$->add_child($2);
               }
               else if($1 != nullptr){
                  $$ = $1;
               }
               else if($2 !=nullptr){
                  $$ = $2;
               }
               else
                  $$ = nullptr;
            }
            | {$$ = nullptr;}
            ;

decl        : var ';' {$$ = nullptr;}
            | func {$$ = $1;}
            ;

/* Separar variaveis em listas por tipo */
var         : type list_id {$$ = nullptr;}
            ;

list_id     : list_id ',' id_label {$$ = nullptr;}
            | id_label {$$ = nullptr;}
            ;

type        : TK_PR_INT   {$$ = $1;}
            | TK_PR_FLOAT {$$ = $1;}
            | TK_PR_BOOL  {$$ = $1;}
            ;

func        : TK_IDENTIFICADOR {
                  if(stack_table.value_declared($1->get_tk_value())){
                        //cout << "func ERR_DECLARED" << endl;
                        throw_error_message($1, ERR_DECLARED);
                        exit(ERR_DECLARED);
                  }
                  else{
                        Symbol simbol{
                              $1->get_line_num(),
                              Nature::FUNC,
                              $1->get_tk_value(),
                              $1
                        };
                        stack_table.create_table_entry($1->get_tk_value(),simbol);
                  }
            } '(' list_param ')' TK_OC_MAP type body {$$ = $1; $$->add_child($8); /*delete $1;*/}
            ;


list_param  : list_param ',' id_param {$$ = nullptr;}
            | id_param {$$ = nullptr;}
            | {$$ = nullptr;}
            ;


body        : {stack_table.create_new_stack();}'{' list_cmd '}' {$$ = $3; stack_table.pop_table();}
            ;


list_cmd    :  cmd ';' list_cmd  {
               if($3 != nullptr && $1 != nullptr){
                  $$  = $1;
                  $$->add_child($3);
               }
               else if($1 != nullptr){
                  $$ = $1;
               }
               else if($3 != nullptr){
                  $$ = $3;
               }
               else
                  $$ = nullptr;
                  
            }
            |  {$$ = nullptr;}
            ;

cmd         : cmd_var         {$$ = $1; /* cout << "<=" << endl; */}
            | cmd_atrib       {$$ = $1;}
            | cmd_func_call   {$$ = $1;  cout << "cmd:func_call" << endl; }
            | cmd_return      {$$ = $1; /* cout << "return" << endl; */}
            | cmd_flux_ctrl   {$$ = $1;}
            | body            {$$ = $1; /* cout << "body" << endl; */}

            ;

cmd_var     : type list_id_atrib {$$ = $2; /*cout << "getting atrib rule" << endl; */}
            ;

list_id_atrib   : list_id_atrib ',' id_atrib{
                        $$ = $1;
                }
                | list_id_atrib ',' init_var{
                  if($1 != nullptr && $3 != nullptr)
                  {
                        $$ = $1;
                        $$->add_child($3);
                  }
                  else if ($1 != nullptr){
                        $$=$1;
                  }
                  else if($3 != nullptr){
                        $$=$3;
                  }
                  else
                        $$=nullptr;
                        
                }

                | init_var {$$ = $1;}
                | id_atrib {$$ = nullptr;}
                ;

init_var        : id_label TK_OC_LE lit{
                  $$ = $2;
                  $$->add_child($1);
                  $$->add_child($3);
                }
                ;

id_atrib        : id_label {$$ = nullptr;}
                ;


lit             : TK_LIT_INT   {
                  $$ = $1;
                  $$->set_type_node(NodeType::INT_TYPE);
                  Symbol lit_type{
                        $1->get_line_num(),
                        Nature::LIT,
                        nodetype_to_string($1->get_type_node()),
                        $1
                  };
                  stack_table.create_table_entry($1->get_tk_value(),lit_type);

            }
                | TK_LIT_FLOAT {
                  $$ = $1;
                  $$->set_type_node(NodeType::FLOAT_TYPE);
                  Symbol lit_type{
                        $1->get_line_num(),
                        Nature::LIT,
                        nodetype_to_string($1->get_type_node()),
                        $1
                  };
                  stack_table.create_table_entry($1->get_tk_value(),lit_type);

            }
                | TK_LIT_TRUE  {
                  $$ = $1;
                  $$->set_type_node(NodeType::BOOL_TYPE);
                  Symbol lit_type{
                        $1->get_line_num(),
                        Nature::LIT,
                        nodetype_to_string($1->get_type_node()),
                        $1
                  };
                  stack_table.create_table_entry($1->get_tk_value(),lit_type);

            }
                | TK_LIT_FALSE {
                  $$ = $1;
                  $$->set_type_node(NodeType::BOOL_TYPE);
                  Symbol lit_type{
                        $1->get_line_num(),
                        Nature::LIT,
                        nodetype_to_string($1->get_type_node()),
                        $1
                  };
                  stack_table.create_table_entry($1->get_tk_value(),lit_type);

            }
            ;

id_label: TK_IDENTIFICADOR {
            Symbol new_data{
                  $1->get_line_num(),
                  Nature::ID,
                  $1->get_tk_value(),
                  $1
            };
            //Need to check if viable create the variable
            if(stack_table.value_declared($1->get_tk_value())){
                  //A second look is needed just to check if the name found is a function
                  Symbol s = stack_table.get_symbol_occurence($1->get_tk_value());
                  if(s.nature == Nature::FUNC){
                        stack_table.create_table_entry($1->get_tk_value(), new_data);
                  }
                  else{
                        throw_error_message ($1, ERR_DECLARED);
                        exit(ERR_DECLARED);
                  }
            }
            else{
                  stack_table.create_table_entry($1->get_tk_value(), new_data);
            }
            /*delete $1;*/
        }
        ;     



cmd_flux_ctrl   : TK_PR_IF '(' expr ')' body {
                        $$ = $1;
                        $$->add_child($3);
                        $$->add_child($5);
                }
                | TK_PR_IF '(' expr ')' body TK_PR_ELSE body {$$ = $1; $$->add_child($3); $$->add_child($5); $$->add_child($7);}
                | TK_PR_WHILE '(' expr ')' body {$$ = $1; $$->add_child($3); $$->add_child($5);}


cmd_func_call: name_func {
                  //Need to check if function exists
                  if(stack_table.value_declared_nature_filter($1->get_tk_value(), Nature::FUNC)){
                        //Need to pick the first occurence on table
                        cout << "Verificar a()" << endl;
                        Symbol s = stack_table.get_symbol_by_type($1->get_tk_value(), Nature::FUNC);
                        int check_symbol = check_bad_attrib(s.nature, Nature::FUNC);
                        if(check_symbol > 0){
                              throw_error_message($1, check_symbol);
                              exit(check_symbol);
                        }
                  }
                  else{
                        throw_error_message ($1, ERR_UNDECLARED);
                        exit(ERR_UNDECLARED);
                  }
            } 
            '(' list_arg ')' {$$ = $1; $$->reg_func_call(true); $$->add_child($4);}
            ;

func_call_param : name_func '(' list_arg ')' {$$ = $1; $$->add_child($3);}
                ;


unary_operand : '-'     {$$ = $1;}
              | '!'     {$$ = $1;}
              ;

bin_sec_expr : '*'      {$$ = $1;}
             | '/'      {$$ = $1;}
             | '%'      {$$ = $1;}
             ;

bin_thr_expr : '+'      {$$ = $1;}
             | '-'      {$$ = $1;}
             ;

bin_fou_expr : '<'      {$$ = $1;}
             | '>'      {$$ = $1;}
             | TK_OC_LE {$$ = $1;}
             | TK_OC_GE {$$ = $1;}
             ;

bin_fif_expr : TK_OC_NE {$$ = $1;}
             | TK_OC_EQ {$$ = $1;}
             ;

bin_six_expr: TK_OC_AND {$$ = $1;}
             ;

bin_sev_expr: TK_OC_OR {$$ = $1;}
             ;

expr: expr_1 {$$ = $1;} 
    | expr bin_sev_expr expr_1 {
            $$ = $2; 
            $$->add_child($1); 
            $$->add_child($3);
            $$->set_type_node(inference_type($1->get_type_node(),$3->get_type_node()));
      }
    | {$$ = nullptr;}
    ;

expr_1: expr_2 {$$ = $1;}
      | expr_1 bin_six_expr expr_2 {
            $$ = $2; 
            $$->add_child($1); 
            $$->add_child($3);
            $$->set_type_node(inference_type($1->get_type_node(),$3->get_type_node()));
      }
      ;

expr_2: expr_3 {$$ = $1;}
      | expr_2 bin_fif_expr expr_3 {
            $$ = $2; $$->add_child($1); 
            $$->add_child($3);
            $$->set_type_node(inference_type($1->get_type_node(),$3->get_type_node()));
      }
      ;

expr_3: expr_4                     {$$ = $1;}
      | expr_3 bin_fou_expr expr_4 {
                  $$ = $2; $$->add_child($1); 
                  $$->add_child($3);
                  $$->set_type_node(inference_type($1->get_type_node(),$3->get_type_node()));
            }
      ;

expr_4: expr_5                     {$$ = $1;}
      | expr_4 bin_thr_expr expr_5 {
            $$ = $2; 
            $$->add_child($1); 
            $$->add_child($3);
            $$->set_type_node(inference_type($1->get_type_node(),$3->get_type_node()));
      }
      ;

expr_5: unary_expr                     {$$ = $1;}
      | expr_5 bin_sec_expr unary_expr {
            $$ = $2; 
            $$->add_child($1); 
            $$->add_child($3);
            $$->set_type_node(inference_type($1->get_type_node(),$3->get_type_node()));
      }
      ;

unary_expr: parenthesis_prec               {$$ = $1;}
          | unary_operand parenthesis_prec {
            cout << "check parenthesis" << endl;
            $$ = $1; 
            $$->add_child($2);
            $$->set_type_node($2->get_type_node());
          }
          ;


parenthesis_prec    :  operand      {$$ = $1;}
                    | '(' expr ')'  {$$ = $2;}
                    ;

operand     : id_var        {$$ = $1; }
            | lit             {$$ = $1;}
            | func_call_param {
                  $$ = $1;
                  //If a variable was called as a function, we need to throw an error right there
                  cout << "parameter read" << endl;
            }
            ;

//Here we need to check if our label was reffering to a func too
id_var:     TK_IDENTIFICADOR {
                  if(!(stack_table.value_declared($1->get_tk_value()))){
                              //cout << "Entrei no id_var_decl" << endl;
                              throw_error_message ($1, ERR_UNDECLARED);
                              exit(ERR_UNDECLARED);
                  }
            }
            ;

list_arg    : list_arg ',' expr {$$ = $3; $$->add_child($1);}
            | expr {$$ = $1;}
            ;


cmd_atrib   : id_var_decl '=' expr {
                  //First we need to check if the variable was created before we make the atribution command
                  try{
                        if(!(stack_table.value_declared($1->get_tk_value()))){
                              cout << "Entrei no id_var_decl" << endl;
                              throw_error_message ($1, ERR_UNDECLARED);
                              exit(ERR_UNDECLARED);
                        }
                        $$ = $2; 
                        $$->add_child($1); 
                        $$->add_child($3);
                        /*delete $1;*/
                  }
                  catch(const exception& er)
                  {
                        cout<< "Exception caught: " << er.what() << endl;
                  }
            }
            ;

id_var_decl: TK_IDENTIFICADOR {
            try{
                  if (stack_table.value_declared($1->get_tk_value())) {
                        $$ = $1; // Tem que ser var, se não é erro
                        auto s = stack_table.get_symbol_occurence($1->get_tk_value());
                        int exit_code = check_bad_attrib(s.nature, Nature::ID);
                        if (exit_code > 0) {
                              //cout << "Entrei no id_var_decl" << endl;
                              throw_error_message($1, exit_code);
                              exit(exit_code);
                        }
                        $$->set_type_node(string_to_nodetype(s.type));
                  }
                  else{
                        //cout << "Entrei no else id_var_decl" << endl;
                        throw_error_message($1, ERR_UNDECLARED);
                        exit(ERR_UNDECLARED);
                  }
            }
            catch(const exception& er)
            {
                  cout<< "Exception caught: " << er.what() << endl;
            }
      }
      ;

cmd_return  : TK_PR_RETURN expr {$$ = $1; $$->add_child($2);}
            ;
 

name_func: TK_IDENTIFICADOR {$$ = $1;}
         ;     

id_param: type id_label {
            $$ = nullptr; //delete $2;
      }
      ;

%%
int yyerror (const char *message)
{
    printf("Error line %d: %s\n", get_line_number(), message);
    return 1;
}

void throw_error_message (AstNode* node, int error_code) {
    int line_number = node->get_line_num();
    string token_val = node->formatstring();
    string token_type;

    //cout << token_val << endl;

    switch(error_code){
      case ERR_DECLARED:
            cout << "[error found on line " << line_number
                  << "] variable/function " << token_val << " already be declared." << endl;
                  break;
      case ERR_UNDECLARED:
            cout << "[error found on line " << line_number
                  << "] variable/function " << token_val << " wasn't declared." << endl;
                  break;
      case ERR_VARIABLE:
            cout << "[error found on line " << line_number
                  << "] inappropriate usage of variable " << token_val << "." << endl;
                  break;
      case ERR_FUNCTION:
            cout << "[error found on line " << line_number
                  << "] inappropriate usage of function " << token_val << "." << endl;
                  break;
      default:
            cout << "[error found on line " << line_number
                  << "] conversion " << token_type << " >> undentified error." << endl;
    }
}