#include "SizeExpression.h"
#include "io.h"
#include "grammar.tab.h"
#include "PrimitiveType.h"
#include "Token.h"

#define O_SUPER Expression()

O_IMPLEMENT(SizeExpression, void *, ctor, (void *_self, va_list *app))
{
  struct SizeExpression * self = O_CAST(_self, SizeExpression());
  self = O_SUPER->ctor(self, app);
  self->param = O_CAST(va_arg(*app, struct Type *), Type());
  O_CALL(self->param, retain);
  return self;
}

O_IMPLEMENT(SizeExpression, void *, dtor, (void *_self))
{
  struct SizeExpression *self = O_CAST(_self, SizeExpression());
  O_CALL(self->param, release);
  return O_SUPER->dtor(self);
}

O_IMPLEMENT(SizeExpression, void, type_check, (void *_self))
{
  struct SizeExpression *self = O_CAST(_self, SizeExpression());
  O_CALL(self->param, type_check);
  struct Token * type_token = O_CALL(self->param, get_token);
  struct Token * int_token = O_CALL_CLASS(Token(), new, "int", INT, type_token->file, type_token->line);
  self->type = O_CALL_CLASS(PrimitiveType(), new, int_token);
  O_CALL(self->type, retain);
}

O_IMPLEMENT(SizeExpression, void, generate, (void *_self))
{
  struct SizeExpression *self = O_CAST(_self, SizeExpression());
  fprintf(out, "sizeof (");
  O_CALL(self->param, generate);
  fprintf(out, ")");
}

O_OBJECT(SizeExpression, Expression);
O_OBJECT_METHOD(SizeExpression, ctor);
O_OBJECT_METHOD(SizeExpression, dtor);
O_OBJECT_METHOD(SizeExpression, generate);
O_OBJECT_METHOD(SizeExpression, type_check);
O_END_OBJECT
