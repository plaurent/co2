MAINTAINERCLEANFILES=Makefile.in
ACLOCAL_AMFLAGS=-I m4

lib_LTLIBRARIES=libco2-base-1.0.la
libco2_base_1_0_ladir=$(includedir)/co2-base-1.0/co2

libco2_base_1_0_la_CO2SOURCES=\
co2/Array.co2\
co2/ArrayIterator.co2\
co2/ArrayList.co2\
co2/BaseObject.co2\
co2/ClassCastException.co2\
co2/Collection.co2\
co2/Comparable.co2\
co2/ConsoleHandler.co2\
co2/DoubleLinkedList.co2\
co2/DoubleLinkedListIterator.co2\
co2/DoubleLinkedItem.co2\
co2/Enum.co2\
co2/Exception.co2\
co2/HashMap.co2\
co2/HashMapIterator.co2\
co2/HashSet.co2\
co2/HashSetIterator.co2\
co2/IndexOutOfBoundsException.co2\
co2/IntArray.co2\
co2/Iterable.co2\
co2/Iterator.co2\
co2/KeyValuePair.co2\
co2/Level.co2\
co2/List.co2\
co2/ListIterator.co2\
co2/LogFormatter.co2\
co2/Logger.co2\
co2/LogHandler.co2\
co2/LogRecord.co2\
co2/Map.co2\
co2/OutOfMemoryException.co2\
co2/RefObject.co2\
co2/ReleasePool.co2\
co2/ReleasePoolItem.co2\
co2/Set.co2\
co2/SimpleFormatter.co2\
co2/Stack.co2\
co2/String.co2\
co2/Throwable.co2

GENERATED_CSOURCES=\
$(libco2_base_1_0_la_CO2SOURCES:.co2=.c)

GENERATED_CHEADERS=\
$(libco2_base_1_0_la_CO2SOURCES:.co2=.h)

GENERATED_CO2DEPEND=\
$(libco2_base_1_0_la_CO2SOURCES:.co2=.d)

BUILT_SOURCES=\
$(GENERATED_CSOURCES)\
$(GENERATED_CHEADERS)

libco2_base_1_0_la_SOURCES=\
$(libco2_base_1_0_la_CO2SOURCES)\
$(GENERATED_CSOURCES)

libco2_base_1_0_la_HEADERS=\
$(libco2_base_1_0_la_CO2SOURCES)\
$(GENERATED_CHEADERS)

libco2_base_1_0_la_CPPFLAGS=-O0 -g3 -DO_DEBUG

CARBON_FLAGS=-I $(srcdir)

%.c: %.co2
if CARBON_EXISTS
	-rm -f $(builddir)/$@
	$(CARBON) $(CARBON_FLAGS) $< $(builddir)/$@;
else
	echo "please install carbon first";
endif

%.h: %.c

if CARBON_EXISTS
%.d: %.co2
	-rm -f $(builddir)/$@
	mkdir -p `dirname $(builddir)/$@`
	echo -n "`echo $(builddir)/$@ | sed 's/\.d/.c/g'` " > $(builddir)/$@
	$(CARBON) --depend $(CARBON_FLAGS) $< $(builddir)/$@ >> $(builddir)/$@ || rm -f $(builddir)/$@;
endif

clean-local:
if CARBON_EXISTS
	-rm -f $(GENERATED_CHEADERS) $(GENERATED_CSOURCES);
endif

distclean-local:
#	-rm -f $(bin_PROGRAMS)
if CARBON_EXISTS
	-rm -f $(GENERATED_CO2DEPEND)
endif

if CARBON_EXISTS
include $(GENERATED_CO2DEPEND)
endif
