/*
 * carbon Compiler and programming language for libco2
 *
 * Copyright (C) 2011 Peterpaul Taekele Klein Haneveld
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
%{
#include "co2/Compiler.h"
  /* Declarations */
#include "co2/ArgumentDeclaration.h"
#include "co2/ClassDeclaration.h"
#include "co2/ConstructorDeclaration.h"
#include "co2/Declaration.h"
#include "co2/DestructorDeclaration.h"
#include "co2/FunctionDeclaration.h"
#include "co2/InterfaceDeclaration.h"
#include "co2/InterfaceMethodDefinition.h"
#include "co2/StructDeclaration.h"
#include "co2/TypeDeclaration.h"
#include "co2/VariableDeclaration.h"
  /* Statements */
#include "co2/BreakStatement.h"
#include "co2/CaseStatement.h"
#include "co2/CatchStatement.h"
#include "co2/CompoundStatement.h"
#include "co2/ContinueStatement.h"
#include "co2/DeleteStatement.h"
#include "co2/DoStatement.h"
#include "co2/ExpressionStatement.h"
#include "co2/FinallyStatement.h"
  /* #include "co2/ForEachStatement.h" */
#include "co2/ForStatement.h"
#include "co2/IfStatement.h"
#include "co2/ReturnStatement.h"
#include "co2/Statement.h"
#include "co2/SwitchStatement.h"
#include "co2/TryStatement.h"
#include "co2/ThrowStatement.h"
#include "co2/WhileStatement.h"
  /* Expressions */
#include "co2/BinaryExpression.h"
#include "co2/CastExpression.h"
#include "co2/ConditionalBinaryExpression.h"
#include "co2/ConditionalExpression.h"
#include "co2/Expression.h"
#include "co2/FunctionCallExpression.h"
#include "co2/IsOfExpression.h"
#include "co2/NestedExpression.h"
#include "co2/NewExpression.h"
#include "co2/NullExpression.h"
#include "co2/SizeExpression.h"
#include "co2/SuperExpression.h"
#include "co2/TokenExpression.h"
#include "co2/UnaryExpression.h"
#include "co2/VarArgExpression.h"
  /* Types */
#include "co2/ArrayType.h"
#include "co2/FunctionType.h"
#include "co2/ObjectType.h"
#include "co2/PrimitiveType.h"
#include "co2/Type.h"
  /* Support */
#include "co2/File.h"
#include "co2/io.h"
#include "co2/Path.h"
#include "co2/RefList.h"
#include "co2/Scope.h"
#include "co2/Token.h"

  extern char *yytext;
  extern void yyerror(const char *);
  extern int yywrap(void);
  extern void VariableDeclaration_set_type(void *_var, va_list *app);
  extern void Declaration_set_class_decl(void *_decl, va_list *app);

  %}

%union {
  struct CompileObject * object;
  struct Declaration * declaration;
  struct Expression * expression;
  struct File * file;
  struct Path * path;
  struct RefList * list;
  struct Statement * statement;
  struct Token * token;
  struct Type * type;
  struct Scope * scope;
}

%token <token> BREAK
%token <token> CASE
%token <token> CATCH
%token <token> CHAR
%token <token> CHAR_CONSTANT
%token <token> CLASS
%token <token> CONTINUE
%token <token> DEFAULT
%token <token> DO
%token <token> DOUBLE
%token <token> DELETE
%token <token> ELSE
%token <token> FINALLY
%token <token> FLOAT
%token <token> FLOAT_CONSTANT
%token <token> FOR
 /* %token <token> FOREACH */
%token <token> GET_VA_ARG
%token <token> IDENTIFIER
%token <token> IF
%token <token> IMPORT
%token <token> INT
%token <token> INT_CONSTANT
%token <token> INTERFACE
%token <token> NEW
%token <token> NULL_
%token <token> RETURN
%token <token> SELF
%token <token> SIZEOF
%token <token> STRING_CONSTANT
%token <token> STRUCT
%token <token> SUPER
%token <token> SWITCH
%token <token> THROW
%token <token> TRY
%token <token> TYPEDEF
%token <token> TYPE_IDENTIFIER
%token <token> UNSIGNED
 /* '...' */
%token <token> VA_ARG
%token <token> VA_LIST
%token <token> VOID
%token <token> WHILE

 /* Declarations */
%type	<declaration>	class_declaration
%type	<declaration>	class_header
%type	<declaration>	constructor_declaration
%type	<declaration>	declaration
%type	<list>		declaration_list
%type	<list>		declaration_list_content
%type	<list>		definition_declaration
%type	<list>		definition_list
%type	<list>		definition
%type	<declaration>	destructor_declaration
%type	<declaration>	formal_argument
%type	<list>		formal_argument_list
%type	<list>		formal_argument_list_var
%type	<declaration>	function_declaration
%type	<declaration>	function_header
%type	<token>		header_file
%type	<object>	implemented_interface_method
%type	<list>		implemented_interface_methods
%type	<declaration>	interface_declaration
%type	<declaration>	interface_header
%type	<list>		interface_list
%type	<list>		interface_method_declaration_list
%type	<list>		opt_formal_argument_list
%type	<declaration>	struct_declaration
%type	<list>		struct_declaration_body
%type	<declaration>	type_declaration
%type	<declaration>	variable_declaration_id
%type	<list>		variable_declaration_id_list
%type	<list>		variable_declaration_list
 /* Statements */
%type	<statement>	break_statement
%type	<list>		case_content_list
%type	<statement>	case_statement
%type	<list>		case_statement_list
%type	<list>		case_statement_list_with_default
%type	<statement>	catch_statement
%type	<list>		catch_statement_list
%type	<list>		compound_content
%type	<list>		compound_content_list
%type	<statement>	compound_statement
%type	<statement>	continue_statement
%type	<statement>	default_case
%type	<statement>	delete_statement
%type	<statement>	do_statement
%type	<statement>	expression_statement
 /* %type	<statement>	foreach_statement */
%type	<statement>	for_statement
%type	<statement>	if_statement
%type	<statement>	return_statement
%type	<statement>	statement
%type	<statement>	switch_statement
%type	<statement>	throw_statement
%type	<statement>	try_statement
%type	<statement>	while_statement
 /* Types */
%type	<list>		opt_type_list
%type	<type>		type
%type	<list>		type_list
 /* Expressions */
%type	<list>		actual_argument_list
%type	<expression>	constant
%type	<expression>	expression
%type	<list>		opt_actual_argument_list
%type	<token>		string_constant
%type	<token>		identifier

 /* Solve shift-reduce conflict for if-else */
%nonassoc	IFX
%nonassoc	ELSE

 /* Solve shift-reduce conflict for constructor, in combination with '(' */
%nonassoc	CONSTRUCTX

%nonassoc	CATCHX
%nonassoc	CATCH
%nonassoc	FINALLY

%left		<token>	','
%right		<token>	'=' INCREASE DECREASE MULTIPLY DIVIDE POWER REMINDER AND_IS OR_IS XOR_IS
%left		<token>	OR '|' 
%left		<token>	AND '&'
%left		<token>	EQ NEQ IS_OF
%nonassoc	<token>	'<' LEQ '>' GEQ
%left		<token> XOR '#'
%left		<token>	SHIFTL SHIFTR
%left		<token>	'+' '-'
%left		<token>	'*' '/' '%' '^'
%right		<token>	'!' UNARY_MINUS UNARY_PLUS ADDRESS_OF DEREFERENCE
 /* Solve shift-reduce conflict for casts */
%right	CASTX
%left		<token> ':' '?'
%left		<token>	'(' '[' '.'

%start input
%expect 0

%%

input
:	global_declaration_list
;

global_declaration_list
:	global_declaration_list declaration_list_content
{
  O_CALL (current_file->declarations, merge, $2);
}
|	/* empty */
;

declaration_list
:	declaration_list declaration_list_content
{
  $$ = O_CALL($1, merge, $2);
}
|	/* empty */
{
  $$ = O_CALL_CLASS(RefList(), new, 8, Declaration());
}
;

declaration_list_content
:	declaration 
{
  $$ = O_CALL_CLASS(RefList(), new, 8, Declaration()); 
  O_CALL($$, append, $1); 
}
|	variable_declaration_list
|	definition_declaration
|	function_header ';'
{
  O_CALL(current_scope, leave);
  O_CALL(current_scope, declare, $1);
  $$ = O_CALL_CLASS(RefList(), new, 8, Declaration()); 
  O_CALL($$, append, $1); 
}
;

declaration
:	function_declaration
{
  O_CALL(current_scope, declare, $1);
}
|	struct_declaration
|	class_declaration
|	interface_declaration
{
  O_CALL(current_scope, declare, $1);
}
|	constructor_declaration
{
  O_CALL(current_scope, declare, $1);
}
|	destructor_declaration
{
  O_CALL(current_scope, declare, $1);
}
|	type_declaration
{
  O_CALL(current_scope, declare, $1);
}
;

type_declaration
:	TYPEDEF TYPE_IDENTIFIER '=' type ';'
{
  $$ = O_CALL_CLASS (TypeDeclaration (), new, $2, $4, false);
}
|	TYPEDEF TYPE_IDENTIFIER '=' STRUCT type ';'
{
  $$ = O_CALL_CLASS (TypeDeclaration (), new, $2, $5, true);
}
|	TYPEDEF TYPE_IDENTIFIER '=' IDENTIFIER ';'
{
  struct Type * type = O_CALL_CLASS (PrimitiveType (), new, $4);
  $$ = O_CALL_CLASS (TypeDeclaration (), new, $2, type, false);
}
|	TYPEDEF TYPE_IDENTIFIER '=' STRUCT IDENTIFIER ';'
{
  struct Type * type = O_CALL_CLASS (PrimitiveType (), new, $5);
  $$ = O_CALL_CLASS (TypeDeclaration (), new, $2, type, true);
}
;

definition_declaration
:	header_file definition
{
  $$ = $2;
  O_CALL($$, map_args, Declaration_list_set_include_header, $1);
}
|	header_file '{' definition_list '}'
{
  $$ = $3;
  O_CALL($$, map_args, Declaration_list_set_include_header, $1);
}
;

definition_list
:	definition_list definition
{
  O_CALL($1, merge, $2);
}
|	definition
;

definition
:	function_header ';'
{
  O_CALL(current_scope, leave);
  O_CALL(current_scope, declare, $1);
  $$ = O_CALL_CLASS(RefList(), new, 8, Declaration());
  O_CALL($$, append, $1);
}
|	declaration 
{
  $$ = O_CALL_CLASS(RefList(), new, 8, Declaration()); 
  O_CALL($$, append, $1); 
}
|	variable_declaration_list
;

header_file
:	'[' STRING_CONSTANT ']'
{
  $$ = $2;
}
;

variable_declaration_list
:	type variable_declaration_id_list ';' 
{
  O_CALL($2, map_args, VariableDeclaration_set_type, $1);
  $$ = $2;
}
;

variable_declaration_id_list
:	variable_declaration_id_list ',' variable_declaration_id
{
  O_CALL($$, append, $3);
}
|	variable_declaration_id
{
  $$ = O_CALL_CLASS(RefList(), new, 8, Declaration());
  O_CALL($$, append, $1);
}
;

variable_declaration_id
:	IDENTIFIER
{
  $$ = O_CALL_CLASS(VariableDeclaration(), new, $1, NULL);
  O_CALL(current_scope, declare, $$);
}
|	CLASS
{
  $$ = O_CALL_CLASS(VariableDeclaration(), new, $1, NULL);
  O_CALL(current_scope, declare, $$);
}
|	IDENTIFIER '=' expression
{
  $$ = O_CALL_CLASS(VariableDeclaration(), new, $1, $3);
  O_CALL(current_scope, declare, $$);
}
;

function_declaration
:	function_header implemented_interface_methods statement
{
  struct FunctionDeclaration * decl = O_CAST($1, FunctionDeclaration());
  decl->implemented_methods = O_CALL($2, retain);
  decl->body = O_CALL($3, retain);
  O_CALL(current_scope, leave);
}
;

implemented_interface_methods
:	implemented_interface_methods implemented_interface_method
{
  O_CALL ($1, append, $2);
}
|	/* empty */
{
  $$ = O_CALL_CLASS (RefList (), new, 8, InterfaceMethodDefinition ());
}
;

implemented_interface_method
:	',' TYPE_IDENTIFIER
{
  $$ = O_CALL_CLASS (InterfaceMethodDefinition (), new, $2, NULL);
}
|	',' TYPE_IDENTIFIER '.' IDENTIFIER
{
  $$ = O_CALL_CLASS (InterfaceMethodDefinition (), new, $2, $4);
}
;

function_header
:	type IDENTIFIER '(' 
{ 
  O_CALL_CLASS(Scope(), new, ARGUMENT_SCOPE, $2); 
}
formal_argument_list_var ')'
{
  struct FunctionType * type = O_CALL_CLASS(FunctionType(), new_ctor, _FunctionType_ctor_from_decl, $1, $5);
  $$ = O_CALL_CLASS(FunctionDeclaration(), new, $2, type, $5, NULL);
}
;

formal_argument_list_var
:	formal_argument_list ',' VA_ARG
{
  struct Type * type = O_CALL_CLASS(PrimitiveType(), new, $3);
  struct ArgumentDeclaration * arg = O_CALL_CLASS(ArgumentDeclaration(), new, $3, type);
  O_CALL($$, append, arg);
}
|	opt_formal_argument_list
|	VA_ARG
{
  $$ = O_CALL_CLASS(RefList(), new, 8, ArgumentDeclaration());
  struct Type * type = O_CALL_CLASS(PrimitiveType(), new, $1);
  struct ArgumentDeclaration * arg = O_CALL_CLASS(ArgumentDeclaration(), new, $1, type);
  O_CALL($$, append, arg);
}
;

opt_formal_argument_list
:	formal_argument_list
|	/* empty */
{
  $$ = O_CALL_CLASS(RefList(), new, 8, ArgumentDeclaration());
}
;

formal_argument_list
:	formal_argument_list ',' formal_argument
{
  O_CALL($$, append, $3);
}
|	formal_argument
{
  $$ = O_CALL_CLASS(RefList(), new, 8, ArgumentDeclaration());
  O_CALL($$, append, $1);
}
;

formal_argument
:	type IDENTIFIER
{
  $$ = O_CALL_CLASS(ArgumentDeclaration(), new, $2, $1);
  O_CALL(current_scope, declare, $$);
}
;

struct_declaration
:	STRUCT identifier
{
  $<scope>$ = O_CALL_CLASS (Scope (), new, STRUCT_SCOPE, $2);
}
'{' struct_declaration_body '}'
{
  O_CALL (current_scope, leave);
  $$ = O_CALL_CLASS (StructDeclaration (), new, $2, $<scope>3, $5);
  O_CALL (current_scope, declare, $$);
}
;

identifier
: TYPE_IDENTIFIER
| IDENTIFIER
;

struct_declaration_body
:	struct_declaration_body variable_declaration_list
{
  O_CALL ($1, merge, $2);
}
|	/* empty */
{
  $$ = O_CALL_CLASS (RefList (), new, 8, VariableDeclaration ());
}
;

class_declaration
:	class_header 
{
  O_CALL(current_scope, declare, $1);
  struct ClassDeclaration * decl = O_CAST($1, ClassDeclaration());
  decl->member_scope = O_CALL_CLASS(Scope(), new, CLASS_SCOPE, decl->name);
}
'{' declaration_list '}'
{
  O_CALL(current_scope, leave);
  struct ClassDeclaration * decl = O_CAST($1, ClassDeclaration());
  decl->members = O_CALL($4, retain);
  O_CALL(decl->members, map_args, Declaration_set_class_decl, decl);
  decl->member_scope->parent = NULL;
  $$ =(struct Declaration *) decl;
}
;

class_header
:	CLASS TYPE_IDENTIFIER ':' TYPE_IDENTIFIER interface_list
{
  O_CALL ($1, delete);
  $$ = O_CALL_CLASS(ClassDeclaration(), new, $2, $4, $5);
}
|	CLASS TYPE_IDENTIFIER interface_list
{
  O_CALL ($1, delete);
  $$ = O_CALL_CLASS(ClassDeclaration(), new, $2, NULL, $3);
}
;

interface_list
:	interface_list ',' TYPE_IDENTIFIER
{
  O_CALL($$, append, $3);
}
|	/* empty */
{
  $$ = O_CALL_CLASS(RefList(), new, 8, Token());
}
;

statement
:	compound_statement
|	if_statement
|	expression_statement
|	do_statement
|	while_statement
|	for_statement
	/* |	foreach_statement */
|	return_statement
|	delete_statement
|	try_statement
|	throw_statement
|	break_statement
|	continue_statement
|	switch_statement
;

compound_statement
:	'{' 
{
  O_CALL_CLASS(Scope(), new, COMPOUND_SCOPE, NULL);
}
compound_content_list '}'
{
  O_CALL(current_scope, leave);
  $$ = O_CALL_CLASS(CompoundStatement(), new, $3);
}
;

compound_content_list
:	compound_content_list compound_content
{
  O_CALL($$, merge, $2);
}
|	/* empty */
{
  $$ = O_CALL_CLASS(RefList(), new, 8, CompileObject());
}
;

compound_content
:	statement
{
  $$ = O_CALL_CLASS(RefList(), new, 8, CompileObject());
  O_CALL($$, append, $1);
}
|	declaration
{
  $$ = O_CALL_CLASS(RefList(), new, 8, CompileObject());
  O_CALL($$, append, $1);
}
|	variable_declaration_list
{
  $$ = O_CALL_CLASS(RefList(), new, 8, CompileObject());
  O_CALL($$, merge, $1);
}
;

try_statement
:	TRY statement catch_statement_list %prec CATCHX
{
  $$ = O_CALL_CLASS (TryStatement (), new, $2, $3, NULL);
}
|	TRY statement catch_statement_list FINALLY statement
{
  struct Statement * final = O_CALL_CLASS (FinallyStatement (), new, $5);
  $$ = O_CALL_CLASS (TryStatement (), new, $2, $3, final);
}
;

catch_statement_list
:	catch_statement_list catch_statement
{
  O_CALL ($1, append, $2);
}
|	/* empty */
{
  $$ = O_CALL_CLASS (RefList (), new, 8, CatchStatement ());
}
;

catch_statement
:	CATCH 
{
  $<scope>$ = O_CALL_CLASS (Scope (), new, CATCH_SCOPE, NULL);
}
'(' formal_argument ')' statement
{
  O_CALL (current_scope, leave);
  $$ = O_CALL_CLASS (CatchStatement (), new, $<scope>2, $4, $6);
}
;

throw_statement
:	THROW expression ';'
{
  $$ = O_CALL_CLASS (ThrowStatement (), new, $2);
}
;

if_statement
:	IF '(' expression ')' statement %prec IFX
{
  $$ = O_CALL_CLASS(IfStatement(), new, $3, $5, NULL);
}
|	IF '(' expression ')' statement ELSE statement
{
  $$ = O_CALL_CLASS(IfStatement(), new, $3, $5, $7);
}
;

expression_statement
:	expression ';'
{
  $$ = O_CALL_CLASS(ExpressionStatement(), new, $1);
}
;

do_statement
:	DO statement WHILE expression ';'
{
  $$ = O_CALL_CLASS(DoStatement(), new, $2, $4);
}
;

while_statement
:	WHILE '(' expression ')' statement
{
  $$ = O_CALL_CLASS(WhileStatement(), new, $3, $5);
}
;

for_statement
:	FOR '(' expression ';' expression ';' expression ')' statement
{
  $$ = O_CALL_CLASS(ForStatement(), new, $3, $5, $7, $9);
}
;

return_statement
:	RETURN expression ';'
{
  $$ = O_CALL_CLASS(ReturnStatement(), new, $2);
}
|	RETURN ';'
{
  $$ = O_CALL_CLASS(ReturnStatement(), new, NULL);
}
;

delete_statement
:	DELETE expression ';'
{
  $$ = O_CALL_CLASS(DeleteStatement(), new, $2);
}
;

break_statement
:	BREAK ';'
{
  $$ = O_CALL_CLASS(BreakStatement(), new);
}
;

continue_statement
:	CONTINUE ';'
{
  $$ = O_CALL_CLASS(ContinueStatement(), new);
}
;

switch_statement
:	SWITCH '(' expression ')' '{' case_statement_list_with_default '}'
{
  $$ = O_CALL_CLASS (SwitchStatement (), new, $3, $6);
}
;

case_statement_list_with_default
:	case_statement_list default_case
{
  O_CALL ($$, append, $2);
}
|	case_statement_list
;


case_statement_list
:	case_statement_list case_statement
{
  O_CALL ($$, append, $2);
}
|	/* empty */
{
  $$ = O_CALL_CLASS (RefList (), new, 0, Statement ());
}
;

case_statement
:	CASE constant ':' case_content_list
{
  $$ = O_CALL_CLASS (CaseStatement (), new, $2, $4);
}
;

case_content_list
:	case_content_list statement
{
  O_CALL ($$, append, $2);
}
|	/* empty */
{
  $$ = O_CALL_CLASS (RefList (), new, 8, Statement ());
}
;

default_case
:	DEFAULT ':' case_content_list
{
  $$ = O_CALL_CLASS (CaseStatement (), new, NULL, $3);
}
;

interface_declaration
:	interface_header 
{
  struct InterfaceDeclaration * decl = O_CAST($1, InterfaceDeclaration());
  decl->member_scope = O_CALL_CLASS(Scope(), new, INTERFACE_SCOPE, decl->name);
}
'{' interface_method_declaration_list '}'
{
  O_CALL(current_scope, leave);
  struct InterfaceDeclaration * decl = O_CAST($1, InterfaceDeclaration());
  decl->members = O_CALL($4, retain);
}
;

interface_header
:	INTERFACE TYPE_IDENTIFIER interface_list 
{
  $$ = O_CALL_CLASS(InterfaceDeclaration(), new, $2, $3);
}
;

interface_method_declaration_list
:	interface_method_declaration_list function_header ';'
{
  O_CALL(current_scope, leave);
  O_CALL(current_scope, declare, $2);
  O_CALL($1, append, $2);
}
|	interface_method_declaration_list function_declaration
{
  O_CALL(current_scope, declare, $2);
  O_CALL($1, append, $2);
}
|	/* empty */
{
  $$ = O_CALL_CLASS(RefList(), new, 8, Declaration());
}
;

type
:	TYPE_IDENTIFIER %prec CONSTRUCTX
{
  $$ = O_CALL_CLASS(ObjectType(), new, $1, NULL);
}
|	INT
{
  $$ = O_CALL_CLASS(PrimitiveType(), new, $1);
}
|	UNSIGNED
{
  $$ = O_CALL_CLASS(PrimitiveType(), new, $1);
}
|	FLOAT
{
  $$ = O_CALL_CLASS(PrimitiveType(), new, $1);
}
|	DOUBLE
{
  $$ = O_CALL_CLASS(PrimitiveType(), new, $1);
}
|	CHAR
{
  $$ = O_CALL_CLASS(PrimitiveType(), new, $1);
}
|	type '[' ']'
{
  $$ = O_CALL_CLASS(ArrayType(), new, $1);
}
|	type '*'
{
  $$ = O_CALL_CLASS(ArrayType(), new, $1);
}
|	VA_LIST
{
  $$ = O_CALL_CLASS(PrimitiveType(), new, $1);
}
|	VOID
{
  $$ = O_CALL_CLASS(PrimitiveType(), new, $1);
}
|	type '(' '*' ')' '(' opt_type_list ')'
{
	$$ = O_CALL_CLASS(FunctionType(), new, $1, $6);
}
;

opt_type_list
:	type_list
|	/* empty */
{
	$$ = O_CALL_CLASS(RefList(), new, 8, Type());
}
;

type_list
:	type_list ',' type
{
	O_CALL($1, append, $3);
}
|	type
{
	$$ = O_CALL_CLASS(RefList(), new, 8, Type());
	O_CALL($$, append, $1);
}
;

expression
:	constant
|	IDENTIFIER { $$ = O_CALL_CLASS(TokenExpression(), new, $1); }
|	CLASS { $$ = O_CALL_CLASS(TokenExpression(), new, $1); }
|	SELF { $$ = O_CALL_CLASS(TokenExpression(), new, $1); }
|	VA_ARG { $$ = O_CALL_CLASS(TokenExpression(), new, $1); }
|	expression '(' opt_actual_argument_list ')' { $$ = O_CALL_CLASS(FunctionCallExpression(), new, $1, $3); }
|	expression '[' expression ']' { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '.' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '?' '.' expression { $$ = O_CALL_CLASS(ConditionalBinaryExpression(), new, $1, $<token>3, $4); }
|	expression '+' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '-' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '/' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '*' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '^' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '%' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '&' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '|' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '#' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '=' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression AND expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression OR expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression XOR expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression EQ expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression NEQ expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '<' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression '>' expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression LEQ expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression GEQ expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression SHIFTR expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression SHIFTL expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression INCREASE expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression DECREASE expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression MULTIPLY expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression DIVIDE expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression POWER expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression REMINDER expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression AND_IS expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression OR_IS expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	expression XOR_IS expression { $$ = O_CALL_CLASS(BinaryExpression(), new, $1, $<token>2, $3); }
|	'-' expression %prec UNARY_MINUS { $$ = O_CALL_CLASS(UnaryExpression(), new, $1, $2); }
|	'+' expression %prec UNARY_PLUS { $$ = O_CALL_CLASS(UnaryExpression(), new, $1, $2); }
|	'!' expression { $$ = O_CALL_CLASS(UnaryExpression(), new, $1, $2); }
|	'&' expression %prec ADDRESS_OF { $$ = O_CALL_CLASS(UnaryExpression(), new, $1, $2); }
|	'*' expression %prec DEREFERENCE { $$ = O_CALL_CLASS(UnaryExpression(), new, $1, $2); }
|	'(' expression ')' { $$ = O_CALL_CLASS(NestedExpression(), new, $2); }
|	NEW type '[' expression ']' { $$ = O_CALL_CLASS(NewExpression(), new, $2, $4); }
|	NEW type '(' opt_actual_argument_list ')' { $$ = O_CALL_CLASS(NewExpression(), new, $2, $4); }
|	NEW type '.' IDENTIFIER '(' opt_actual_argument_list ')' 
{
  struct TokenExpression * token_expr = O_CALL_CLASS(TokenExpression(), new, $4);
  struct NewExpression * new_expr = O_CALL_CLASS(NewExpression(), new, $2, $6);
  O_CALL(new_expr, set_ctor_name, token_expr);
  $$ =(struct Expression *) new_expr;
}
|	SUPER '(' opt_actual_argument_list ')' { $$ = O_CALL_CLASS(SuperExpression(), new, $1, NULL, $3); }
|	SUPER '.' IDENTIFIER '(' opt_actual_argument_list ')' { $$ = O_CALL_CLASS(SuperExpression(), new, $1, $3, $5); }
|	GET_VA_ARG '(' type ')' { $$ = O_CALL_CLASS(VarArgExpression(), new, $3, NULL); }
|	GET_VA_ARG '(' expression ',' type ')' { $$ = O_CALL_CLASS(VarArgExpression(), new, $5, $3); }
|	SIZEOF '(' type ')' { $$ = O_CALL_CLASS(SizeExpression(), new, $3); }
|	'(' type ')' expression %prec CASTX { $$ = O_CALL_CLASS(CastExpression(), new, $2, $4); }
|	expression '?' expression ':' expression { $$ = O_CALL_CLASS(ConditionalExpression (), new, $1, $3, $5); }
|	expression IS_OF TYPE_IDENTIFIER {
  struct TokenExpression * expr = O_CALL_CLASS(TokenExpression(), new, $3);
  $$ = O_CALL_CLASS(IsOfExpression (), new, $1, expr);
}
|	expression IS_OF expression { $$ = O_CALL_CLASS(IsOfExpression (), new, $1, $3); }
;

constant
:	CHAR_CONSTANT { $$ = O_CALL_CLASS(TokenExpression(), new, $1); }
|	FLOAT_CONSTANT { $$ = O_CALL_CLASS(TokenExpression(), new, $1); }
|	INT_CONSTANT { $$ = O_CALL_CLASS(TokenExpression(), new, $1); }
|	string_constant { $$ = O_CALL_CLASS(TokenExpression(), new, $1); }
|	NULL_ { $$ = O_CALL_CLASS(NullExpression(), new, $1); }
;

opt_actual_argument_list
:	actual_argument_list
|	/* empty */
{
  $$ = O_CALL_CLASS(RefList(), new, 8, Expression());
}
;

actual_argument_list
:	actual_argument_list ',' expression
{
  O_CALL($$, append, $3);

}
|	expression
{
  $$ = O_CALL_CLASS(RefList(), new, 8, Expression());
  O_CALL($$, append, $1);
}
;

string_constant
:	string_constant STRING_CONSTANT
{
  O_CALL($1->name, append, $2->name);
  O_CALL($2, delete);
}
|	STRING_CONSTANT
;

constructor_declaration
:	TYPE_IDENTIFIER '(' 
{ 
  $<token>$ = O_CALL_CLASS(Token(), new_ctor, _Token_ctor_from_token, $1, "ctor", IDENTIFIER);
  O_CALL_CLASS(Scope(), new, ARGUMENT_SCOPE, $<token>$);
}
formal_argument_list_var ')' statement
{
  $$ = O_CALL_CLASS(ConstructorDeclaration(), new, $<token>3, $1, $4, $6);
  O_CALL(current_scope, leave);
}
|	TYPE_IDENTIFIER '.' IDENTIFIER '(' 
{ 
  O_CALL_CLASS(Scope(), new, ARGUMENT_SCOPE, $3); 
}
formal_argument_list_var ')' statement
{
  $$ = O_CALL_CLASS(ConstructorDeclaration(), new, $3, $1, $6, $8);
  O_CALL(current_scope, leave);
}
;

destructor_declaration
:	'~' TYPE_IDENTIFIER '(' ')' statement
{
  struct Token * dtor_name = O_CALL_CLASS(Token(), new_ctor, _Token_ctor_from_token, $2, "dtor", IDENTIFIER);
  $$ = O_CALL_CLASS(DestructorDeclaration(), new, dtor_name, $2, $5);
}
;

%%
void yyerror(const char * msg)
{
  error(yylval.token, "%s near '%s'\n", msg, yytext);
}
int parse()
{
  global_scope = O_CALL_CLASS(Scope(), new, GLOBAL_SCOPE, NULL);
  int result = yyparse();
  O_CALL(current_scope, leave);
  if(result == 0)
    {
      assertTrue(current_scope == NULL, "current_scope(%d) is not NULL", current_scope->type);
      // O_CALL(parsed_file, parse_imports);
    }
  return result;
}
void VariableDeclaration_set_type(void *_decl, va_list *app)
{
  struct VariableDeclaration * decl = O_CAST(_decl, VariableDeclaration());
  O_CALL(decl, set_type, va_arg(*app, struct Type *));
}
void Declaration_set_class_decl(void *_decl, va_list *app)
{
  struct Declaration * decl = O_CAST(_decl, Declaration());
  O_CALL(decl, set_class_decl, va_arg(*app, void *));
}
