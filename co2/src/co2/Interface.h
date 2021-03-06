/*
 * libco2 Library for object oriented programming in C
 *
 * Copyright (C) 2011,2012 Peterpaul Taekele Klein Haneveld
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#ifndef _INTERFACE_H
#define _INTERFACE_H

#include "co2/Object.h"

#define O_METHOD_IF(klass,type,name,args,act_args)			\
	O_FUNCTION_DEF(klass,type,name,args) {				\
		struct klass * interface =				\
			o_get_interface(_self, klass());		\
		return interface->name act_args;			\
	}

#define O_IMPLEMENT_IF_BINDING(klass,type,name,args,act_args)		\
	static O_FUNCTION_DEF(klass,type,name##_impl,args) {		\
		struct klass * self = O_CAST(_self, klass());		\
		return self->class->name act_args;			\
	}								\

#define O_IMPLEMENT_IF(klass,type,name,args,act_args)			\
	O_IMPLEMENT_IF_BINDING(klass,type,name,args,act_args)		\
	O_FUNCTION_DEF(_##klass,type,name,args)

#define O_OBJECT_IF(IF)							\
	{								\
	struct IF * interface = O_CALL_CLASS(IF(), new, O_STRING(IF), self->interface_list); \
	self->interface_list = interface

#define O_OBJECT_IF_METHOD(klass,method)		\
	interface->method = klass##_##method##_impl

#define O_OBJECT_IF_METHOD_BINDING(klass,if_method,method)	\
	interface->if_method = klass##_##method##_impl

#define O_OBJECT_IF_END				\
	}

#ifdef O_DEBUG
#define O_CALL_IF(interface,o,msg,...)					\
  ({typeof(o) _tmp = o;							\
    struct interface * _if = o_get_interface(_tmp, interface());	\
    assertTrue(_if,"runtime error: %s at %p doesn't implement %s.",	\
	       _tmp->class->class_name, (void *)_tmp, __STRING(interface));	\
    assertTrue(_if->msg,"runtime error: %s at %p doesn't respond to %s.", \
	       _tmp->class->class_name, (void *)_tmp, __STRING(msg));		\
    _if->msg(_tmp,##__VA_ARGS__);})
#define O_BRANCH_CALL_IF(interface,o,msg,...)				\
  ({typeof(o) _tmp = o;							\
    struct interface * _if = _tmp ? o_get_interface(_tmp, interface()) : NULL; \
    assertTrue(_tmp ? _if : true,					\
	       "runtime error: %s at %p doesn't implement %s.",		\
	       _tmp->class->class_name, (void *)_tmp, __STRING(interface));	\
    assertTrue(_tmp ? _if->msg : true,					\
	       "runtime error: %s at %p doesn't respond to %s.",	\
	       _tmp->class->class_name, (void *)_tmp, __STRING(msg));		\
    _tmp ? _if->msg(_tmp,##__VA_ARGS__) : (typeof(_if->msg(_tmp,##__VA_ARGS__)))0;})
#else
#define O_CALL_IF(interface,o,msg,...)					\
  ({typeof(o) _tmp = o;							\
    struct interface * _if = o_get_interface(_tmp, interface());	\
    _if->msg(_tmp,##__VA_ARGS__);})
#define O_BRANCH_CALL_IF(interface,o,msg,...)				\
  ({typeof(o) _tmp = o;							\
    struct interface * _if = _tmp ? o_get_interface(_tmp, interface()) : NULL; \
    _tmp ? _if->msg(_tmp,##__VA_ARGS__) : (typeof(_if->msg(_tmp,##__VA_ARGS__)))0;})
#endif /* O_DEBUG */

/* Interface */
#define InterfaceClass_Attr			\
	ObjectClass_Attr

#define Interface_Attr							\
	Object_Attr;							\
	char * name;							\
	struct Interface * next

O_CLASS(Interface, Object);

#endif				/* _INTERFACE_H */
