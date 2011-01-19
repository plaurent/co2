#include "ClassDeclaration.h"
#include "FunctionDeclaration.h"
#include "ArgumentDeclaration.h"
#include "VariableDeclaration.h"
#include "ConstructorDeclaration.h"
#include "DestructorDeclaration.h"
#include "InterfaceDeclaration.h"
#include "Type.h"
#include "ObjectType.h"
#include "Token.h"
#include "RefList.h"
#include "FunctionType.h"
#include "io.h"
#include "Statement.h"
#include "Scope.h"
#include "PrimitiveType.h"
#include "grammar.tab.h"

#define O_SUPER ObjectTypeDeclaration()

O_IMPLEMENT (ClassDeclaration, void *, ctor, (void *_self, va_list * app))
{
  struct ClassDeclaration *self = O_CAST (_self, ClassDeclaration ());
  self = O_SUPER->ctor (self, app);
  self->superclass = O_BRANCH_RETAIN_ARG (Token);
  self->interfaces = O_BRANCH_RETAIN_ARG (RefList);
  return self;
}

O_IMPLEMENT (ClassDeclaration, void *, dtor, (void *_self))
{
  struct ClassDeclaration *self = O_CAST (_self, ClassDeclaration ());
  O_BRANCH_CALL (self->superclass, release);
  O_BRANCH_CALL (self->interfaces, release);
  return O_SUPER->dtor (self);  
}

O_IMPLEMENT (ClassDeclaration, void, accept, (void *_self, struct BaseCompileObjectVisitor *visitor))
{
  struct ClassDeclaration *self = O_CAST (_self, ClassDeclaration ());
  O_CALL (self->members, map_args, accept, visitor);
  O_CALL (visitor, visit, self);
}

int
new_constructor_filter (void *_constructor)
{
  struct ConstructorDeclaration *constructor =
    O_CAST (_constructor, ConstructorDeclaration ());
  if (strcmp (constructor->name->name->data, "ctor") != 0)
    {
      return O_BRANCH_CALL (constructor->scope->parent,
			    lookup_type_in_this_scope, constructor->name,
			    ConstructorDeclaration ()) == NULL;
    }
  return false;
}

void
ClassDeclaration_generate_constructor_arguments (void *_arg)
{
  struct ArgumentDeclaration *arg = O_CAST (_arg, ArgumentDeclaration ());
  O_CALL (arg, generate);
  if (o_is_a (arg->type, ObjectType ()))
    {
      struct ObjectType *type = (struct ObjectType *) arg->type;
      if (o_is_of (type->decl, ClassDeclaration ()))
	{
	  fprintf (out, " = O_BRANCH_CAST (va_arg(*app, ");
	  O_CALL (type, generate);
	  fprintf (out, "), ");
	  O_CALL (type->token, generate);
	  fprintf (out, "());\n");
	  return;
	}
    }
  fprintf (out, " = va_arg (*app, ");
  O_CALL (arg->type, generate);
  fprintf (out, ");\n");
}

void
ClassDeclaration_generate_constructor_definition (void *_constructor_decl,
						  va_list * app)
{
  struct ConstructorDeclaration *constructor_decl =
    O_CAST (_constructor_decl, ConstructorDeclaration ());
  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  fprintf (out, "O_METHOD_DEF (");
  O_CALL (class_decl->name, generate);
  fprintf (out, ", void *, ");
  if (strcmp (constructor_decl->name->name->data, "ctor") != 0)
    {
      fprintf (out, "ctor_");
    }
  O_CALL (constructor_decl->name, generate);
  fprintf (out, ", (void *_self, va_list *app));\n");
}

void
ClassDeclaration_generate_method_definition (void *_method_decl,
					     va_list * app)
{
  struct FunctionDeclaration *method_decl =
    O_CAST (_method_decl, FunctionDeclaration ());
  if (method_decl->interface_decl)
    {
      return;
    }

  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  struct FunctionType *method_type =
    o_cast (method_decl->type, FunctionType ());
  fprintf (out, "O_METHOD_DEF (");
  O_CALL (class_decl->name, generate);
  fprintf (out, ", ");
  O_CALL (method_type->return_type, generate);
  fprintf (out, ", ");
  O_CALL (method_decl->name, generate);
  fprintf (out, ", (void *_self");
  O_CALL (method_decl->formal_arguments, map,
	  ObjectTypeDeclaration_generate_method_arguments);
  fprintf (out, "));\n");
}

void
ClassDeclaration_generate_constructor_registration (void *_constructor_decl,
						    va_list * app)
{
  struct ConstructorDeclaration *constructor_decl =
    O_CAST (_constructor_decl, ConstructorDeclaration ());
  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  fprintf (out, "; \\\n O_METHOD (");
  O_CALL (class_decl->name, generate);
  fprintf (out, ", ");
  if (strcmp (constructor_decl->name->name->data, "ctor") != 0)
    {
      fprintf (out, "ctor_");
    }
  O_CALL (constructor_decl->name, generate);
  fprintf (out, ")");
}

void
ClassDeclaration_generate_method_registration (void *_method_decl,
					       va_list * app)
{
  struct FunctionDeclaration *method_decl =
    O_CAST (_method_decl, FunctionDeclaration ());
  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  fprintf (out, "; \\\n O_METHOD (");
  if (method_decl->interface_decl)
    {
      O_CALL (method_decl->interface_decl->name, generate);
    }
  else
    {
      O_CALL (class_decl->name, generate);
    }
  fprintf (out, ", ");
  O_CALL (method_decl->name, generate);
  fprintf (out, ")");
}

void
ClassDeclaration_generate_constructor_registration_2 (void *_constructor_decl,
						      va_list * app)
{
  struct ConstructorDeclaration *constructor_decl =
    O_CAST (_constructor_decl, ConstructorDeclaration ());
  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  fprintf (out, "O_OBJECT_METHOD (");
  O_CALL (class_decl->name, generate);
  fprintf (out, ", ");
  if (strcmp (constructor_decl->name->name->data, "ctor") != 0)
    {
      fprintf (out, "ctor_");
    }
  O_CALL (constructor_decl->name, generate);
  fprintf (out, ");\n");
}

void
ClassDeclaration_generate_destructor_registration_2 (void *_destructor_decl,
						     va_list * app)
{
  struct DestructorDeclaration *destructor_decl =
    O_CAST (_destructor_decl, DestructorDeclaration ());
  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  fprintf (out, "O_OBJECT_METHOD (");
  O_CALL (class_decl->name, generate);
  fprintf (out, ", dtor);\n");
}

void
ClassDeclaration_generate_interface_method_registration (void *_method_decl,
							 va_list * app)
{
  struct Declaration *method_decl = O_CAST (_method_decl, Declaration ());
  struct Token *token = O_GET_ARG (Token);

  fprintf (out, "O_OBJECT_IF_METHOD (");
  O_CALL (token, generate);
  fprintf (out, ", ");
  O_CALL (method_decl->name, generate);
  fprintf (out, ");\n");
}

void
ClassDeclaration_generate_method_implementation_2 (void *_interface_name,
						   va_list * app)
{
  struct Token *interface_name = O_CAST (_interface_name, Token ());
  struct Token *implementation_name = O_GET_ARG (Token);
  struct Declaration *_decl =
    O_CALL (global_scope, lookup_in_this_scope, interface_name);
  struct InterfaceDeclaration *interface_decl =
    O_CAST (_decl, InterfaceDeclaration ());

  fprintf (out, "O_OBJECT_IF (");
  O_CALL (interface_name, generate);
  fprintf (out, ");\n");
  O_CALL (interface_decl->members, map_args,
	  ClassDeclaration_generate_interface_method_registration,
	  implementation_name);
  fprintf (out, "O_OBJECT_IF_END\n");
}

void
ClassDeclaration_generate_constructor_implementation (void *_constructor_decl,
						      va_list * app)
{
  struct ConstructorDeclaration *constructor_decl =
    O_CAST (_constructor_decl, ConstructorDeclaration ());
  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  fprintf (out, "O_IMPLEMENT (");
  O_CALL (class_decl->name, generate);
  fprintf (out, ", void *");
  fprintf (out, ", ");
  if (strcmp (constructor_decl->name->name->data, "ctor") != 0)
    {
      fprintf (out, "ctor_");
    }
  O_CALL (constructor_decl->name, generate);
  fprintf (out, ", (void *_self, va_list *app))\n");
  fprintf (out, "{\n");
  fprintf (out, "struct ");
  O_CALL (class_decl->name, generate);
  fprintf (out, "* self = O_CAST (_self, ");
  O_CALL (class_decl->name, generate);
  fprintf (out, " ());\n");
  O_CALL (constructor_decl->formal_arguments, map,
	  ClassDeclaration_generate_constructor_arguments);

  O_CALL (constructor_decl->body, generate);
  fprintf (out, "return self;\n");
  fprintf (out, "}\n\n");
}

void
ClassDeclaration_generate_destructor_implementation (void *_destructor_decl,
						     va_list * app)
{
  struct DestructorDeclaration *destructor_decl =
    O_CAST (_destructor_decl, DestructorDeclaration ());
  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  fprintf (out, "O_IMPLEMENT (");
  O_CALL (class_decl->name, generate);
  fprintf (out, ", void *");
  fprintf (out, ", dtor, (void *_self))\n");
  fprintf (out, "{\n");
  fprintf (out, "struct ");
  O_CALL (class_decl->name, generate);
  fprintf (out, "* self = O_CAST (_self, ");
  O_CALL (class_decl->name, generate);
  fprintf (out, " ());\n");
  O_CALL (destructor_decl->body, generate);
  fprintf (out, "return O_SUPER->dtor (self);\n");
  fprintf (out, "}\n\n");
}

void
ClassDeclaration_generate_method_implementation (void *_method_decl,
						 va_list * app)
{
  struct FunctionDeclaration *method_decl =
    O_CAST (_method_decl, FunctionDeclaration ());
  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  struct FunctionType *method_type =
    o_cast (method_decl->type, FunctionType ());
  if (method_decl->interface_decl)
    {
      fprintf (out, "O_IMPLEMENT_IF (");
    }
  else
    {
      fprintf (out, "O_IMPLEMENT (");
    }
  O_CALL (class_decl->name, generate);
  fprintf (out, ", ");
  O_CALL (method_type->return_type, generate);
  fprintf (out, ", ");
  O_CALL (method_decl->name, generate);
  fprintf (out, ", (void *_self");
  O_CALL (method_decl->formal_arguments, map,
	  ObjectTypeDeclaration_generate_method_arguments);
  if (method_decl->interface_decl)
    {
      fprintf (out, "), (_self");
      O_CALL (method_decl->formal_arguments, map,
	      ObjectTypeDeclaration_generate_method_argument_names);
    }
  fprintf (out, "))\n");
  fprintf (out, "{\n");
  fprintf (out, "struct ");
  O_CALL (class_decl->name, generate);
  fprintf (out, "* self = O_CAST (_self, ");
  O_CALL (class_decl->name, generate);
  fprintf (out, " ());\n");

  if (method_type->has_var_args)
    {
      fprintf (out, "va_list ap;\n");
      fprintf (out, "va_start (ap, ");
      if (method_decl->formal_arguments->length == 1)
	{
	  fprintf (out, "_self");
	}
      else
	{
	  struct ArgumentDeclaration *arg_decl =
	    O_CALL (method_decl->formal_arguments, get,
		    method_decl->formal_arguments->length - 2);
	  O_CALL (arg_decl->name, generate);
	}
      fprintf (out, ");\n");
    }

  O_CALL (method_decl->body, generate);

  if (method_type->has_var_args && 
      (o_is_of (method_type->return_type, PrimitiveType ())
       && ((struct PrimitiveType *) method_type->return_type)->token->type == VOID))
    {
      fprintf (out, "va_end (ap);\n");
    }

  fprintf (out, "}\n\n");
}

void
ClassDeclaration_generate_attribute_registration (void *_method_decl,
						  va_list * app)
{
  struct VariableDeclaration *method_decl =
    O_CAST (_method_decl, VariableDeclaration ());
  struct ClassDeclaration *class_decl = O_GET_ARG (ClassDeclaration);
  fprintf (out, "; \\\n ");
  O_CALL (method_decl->type, generate);
  fprintf (out, " ");
  O_CALL (method_decl->name, generate);
}

void
generate_superclass (struct ClassDeclaration *self)
{
  if (self->superclass)
    {
      O_CALL (self->superclass, generate);
    }
  else
    {
      fprintf (out, "Object");
    }
}

O_IMPLEMENT (ClassDeclaration, void, type_check, (void *_self))
{
  struct ClassDeclaration *self = O_CAST (_self, ClassDeclaration ());
  O_CALL (current_context, add, self);
  if (self->superclass)
    {
      struct Declaration *_super_class =
	O_CALL (self->scope, lookup, self->superclass);
      if (_super_class)
	{
	  struct ClassDeclaration *super_class =
	    O_CAST (_super_class, ClassDeclaration ());
	  self->member_scope->parent = super_class->member_scope;
	}
    }
  /* TODO check whether:
   * 1. superclasses already implement interfaces, if so: fail
   * 2. foreach interface, methods already exists in other interface (including interfaces from superclasses), if so: fail
   * 3. class (including superclasses) implements all methods of all interfaces, if not: fail
   */
  O_CALL (self->members, map, Declaration_list_type_check);
  O_CALL (current_context, remove_last);
}

O_IMPLEMENT (ClassDeclaration, bool, is_compatible,
	     (void *_self, void *_other))
{
  struct ClassDeclaration *self = O_CAST (_self, ClassDeclaration ());
  struct ClassDeclaration *other = o_cast (_other, ClassDeclaration ());
  while (other && other->superclass && self != other)
    {
      other =
	(struct ClassDeclaration *) O_CALL (global_scope, lookup,
					    other->superclass);
    }
  return self == other;
}

O_OBJECT (ClassDeclaration, Declaration);
O_OBJECT_METHOD (ClassDeclaration, ctor);
O_OBJECT_METHOD (ClassDeclaration, dtor);
O_OBJECT_METHOD (ClassDeclaration, accept);
O_OBJECT_METHOD (ClassDeclaration, type_check);
O_OBJECT_METHOD (ClassDeclaration, is_compatible);
O_END_OBJECT
