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
#ifndef IsOfExpression_H
#define IsOfExpression_H

#include "co2/Expression.h"

#define IsOfExpressionClass_Attr		\
  ExpressionClass_Attr

#define IsOfExpression_Attr			\
  Expression_Attr;				\
  struct Expression * expr_to_check;		\
  struct Expression * class_expr

O_CLASS(IsOfExpression, Expression);

#endif /* IsOfExpression_H */
