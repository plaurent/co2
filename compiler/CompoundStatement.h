#ifndef CompoundStatement_H
#define CompoundStatement_H

#include "Statement.h"
#include "RefList.h"

#define CompoundStatementClass_Attr			\
  StatementClass_Attr

#define CompoundStatement_Attr				\
  Statement_Attr;					\
  struct RefList * body

O_CLASS(CompoundStatement, Statement);

#endif /* CompoundStatement_H */
