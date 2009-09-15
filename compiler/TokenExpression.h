#ifndef TokenExpression_H
#define TokenExpression_H

#include "Expression.h"
#include "Token.h"

#define TokenExpressionClass_Attr			\
  ExpressionClass_Attr

#define TokenExpression_Attr				\
  Expression_Attr;					\
  struct Token * token;					\
  struct Scope * scope;					\
  struct Declaration * decl

O_CLASS(TokenExpression, Expression);

#endif /* TokenExpression_H */
