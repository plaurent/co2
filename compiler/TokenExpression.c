#include "TokenExpression.h"
#include "grammar.tab.h"
#include "VarDeclaration.h"
#include "FunDeclaration.h"
#include "ArgDeclaration.h"
#include "PrimitiveType.h"
#include "ArrayType.h"
#include "FunctionType.h"
#include "Token.h"
#include "grammar.tab.h"

#define O_SUPER Expression()

O_IMPLEMENT(TokenExpression, void *, ctor, (void *_self, va_list *app), (_self, app))
{
  struct TokenExpression * self = O_CAST(_self, TokenExpression());
  self = O_SUPER->ctor(self, app);
  self->token = O_CAST(va_arg(*app, struct Token *), Token());
  O_CALL(self->token, retain);
  if (self->token->type == IDENTIFIER)
    {
      self->scope = current_scope;
    }
  return self;
}

O_IMPLEMENT(TokenExpression, void *, dtor, (void *_self), (_self))
{
  struct TokenExpression *self = O_CAST(_self, TokenExpression());
  O_CALL(self->token, release);
  O_BRANCH_CALL(self->decl, release);
  return O_SUPER->dtor(self);
}

O_IMPLEMENT(TokenExpression, void, generate, (void *_self), (_self))
{
  struct TokenExpression *self = O_CAST(_self, TokenExpression());
  O_CALL(self->token, generate);
}

O_IMPLEMENT(TokenExpression, void, set_scope, (void *_self, void *_scope), (_self, _scope))
{
  struct TokenExpression *self = O_CAST(_self, TokenExpression());
  self->scope = O_CAST(_scope, Scope());
}

O_IMPLEMENT(TokenExpression, void, type_check, (void *_self), (_self))
{
  struct TokenExpression *self = O_CAST(_self, TokenExpression());
  switch (self->token->type)
    {
    case IDENTIFIER:
      self->decl = O_CALL(self->scope, lookup, self->token);
      if (!self->decl) return;
      O_CALL(self->decl, retain);
      self->type = O_CALL(self->decl->type, retain);
      break;
    case INT_CONSTANT:
      {
	struct Token * token = O_CALL_CLASS(Token(), new, "int", INT, self->token->file, self->token->line);
	self->type = O_CALL_CLASS(PrimitiveType(), new, token);
	O_CALL(self->type, retain);
      }
      break;
    case STRING_CONSTANT:
      {
	struct Token * token = O_CALL_CLASS(Token(), new, "char", CHAR, self->token->file, self->token->line);
	struct Type * base_type = O_CALL_CLASS(PrimitiveType(), new, token);
	self->type = O_CALL_CLASS(ArrayType(), new, base_type);
	O_CALL(self->type, retain);
      }
      break;
    case CHAR_CONSTANT:
      {
	struct Token * token = O_CALL_CLASS(Token(), new, "char", CHAR, self->token->file, self->token->line);
	self->type = O_CALL_CLASS(PrimitiveType(), new, token);
	O_CALL(self->type, retain);
      }
      break;
    case FLOAT_CONSTANT:
      {
	struct Token * token = O_CALL_CLASS(Token(), new, "float", FLOAT, self->token->file, self->token->line);
	self->type = O_CALL_CLASS(PrimitiveType(), new, token);
	O_CALL(self->type, retain);
      }
      break;
    default:
      error(self->token, "Unhandled TokenExpression: %s\n", self->token->name->data);
      break;
    }
  // check whether token type is an identifier or a constant.
  // lookup in the scope where this expression is located
  // when it is a var declaration, set self->type = decl->type
  // when it is a fun declaration, set self->type = decl->return_type
  // when it is a class declaration, set self->type = new PrimitiveType(self->token)
  // when it is an interface declaration, see class declaration
  // when it ia a macro declaration, ...?
}

O_OBJECT(TokenExpression, Expression);
O_OBJECT_METHOD(TokenExpression, ctor);
O_OBJECT_METHOD(TokenExpression, dtor);
O_OBJECT_METHOD(TokenExpression, generate);
O_OBJECT_METHOD(TokenExpression, type_check);
O_OBJECT_METHOD(TokenExpression, set_scope);
O_END_OBJECT
