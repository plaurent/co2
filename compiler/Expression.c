#include "Expression.h"

#define O_SUPER CompileObject()

O_IMPLEMENT(Expression, void *, ctor, (void *_self, va_list *app), (_self, app))
{
  struct Expression * self = O_CAST(_self, Expression());
  self = O_SUPER->ctor(self, app);
  /* TODO initialize */
  self->operand[0] = O_BRANCH_CAST(va_arg(*app, struct Expression *), Expression());
  self->operator = O_BRANCH_CAST(va_arg(*app, struct Token *), Token());
  self->operand[1] = O_BRANCH_CAST(va_arg(*app, struct Expression *), Expression());
  return self;
}

O_IMPLEMENT(Expression, void *, dtor, (void *_self), (_self))
{
  struct Expression *self = O_CAST(_self, Expression());
  /* TODO cleanup */
  return O_SUPER->dtor(self);
}

O_OBJECT(Expression, CompileObject);
O_OBJECT_METHOD(Expression, ctor);
O_OBJECT_METHOD(Expression, dtor);
O_END_OBJECT