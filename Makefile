## 
## Simple makefile for decaf programming projects
##


.PHONY: clean strip

# C++11 support on CAEN machines
PATH := /usr/um/gcc-4.7.0/bin:$(PATH) 
LD_LIBRARY_PATH := /usr/um/gcc-4.7.0/lib64 
LD_RUN_PATH := /usr/um/gcc-4.7.0/lib64

# Set the default target. When you make with no arguments,
# this will be the target built.
COMPILER = dcc
PREPROCESSOR = dpp
PRODUCTS = $(COMPILER) $(PREPROCESSOR)
default: $(PRODUCTS)

# Set up the list of source and object files
SRCS = errors.cc utility.cc libyywrap.cc main.cc

# OBJS can deal with either .cc or .c files listed in SRCS
OBJS = lex.yy.o $(patsubst %.cc, %.o, $(filter %.cc,$(SRCS))) $(patsubst %.c, %.o, $(filter %.c, $(SRCS)))

JUNK = $(OBJS) $(PREP_OBJS) lex.yy.c dpp.yy.c y.tab.c y.tab.h *.core core $(COMPILER).purify purify.log 

# Define the tools we are going to use
CC= g++
LD = g++
LEX = flex
YACC = bison

# Set up the necessary flags for the tools

# We want debugging and most warnings, but lex/yacc generate some
# static symbols we don't use, so turn off unused warnings to avoid clutter
# Also STL has some signed/unsigned comparisons we want to suppress
CFLAGS = -g -Wall -Wno-unused -Wno-sign-compare -std=c++11

# The -d flag tells lex to set up for debugging. Can turn on/off by
# setting value of global yy_flex_debug inside the scanner itself
LEXFLAGS = -d

# The -d flag tells yacc to generate header with token types
# The -v flag writes out a verbose description of the states and conflicts
# The -t flag turns on debugging capability
# The -y flag means imitate yacc's output file naming conventions
YACCFLAGS = -dvty

# Link with standard c library, math library, and lex library
LIBS = -lc -lm

# Rules for various parts of the target

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $*.c

%.o: %.cc
	$(CC) $(CFLAGS) -c -o $@ $*.cc

lex.yy.c: scanner.l
	$(LEX) $(LEXFLAGS) scanner.l


# rules to build compiler (dcc)

$(COMPILER) : $(PREPROCESSOR) $(OBJS)
	$(LD) -o $@ $(OBJS) $(LIBS)

$(COMPILER).purify : $(OBJS)
	purify -log-file=purify.log -cache-dir=/tmp/$(USER) -leaks-at-exit=no $(LD) -o $@ $(OBJS) $(LIBS)

# rules to build preprocessor (dpp) j
PREP_SRCS = dppmain.cc
PREP_OBJS =  libyywrap.o dpp.yy.o utility.o errors.o\
            $(patsubst %.cc, %.o, $(filter %.cc,$(PREP_SRCS))) $(patsubst %.c, %.o, $(filter %.c, $(PREP_SRCS)))

$(PREPROCESSOR) : $(PREP_OBJS)
	$(LD) -o $@ $(PREP_OBJS) $(LIBS)

dpp.yy.c : dpp.l
	$(LEX) -odpp.yy.c dpp.l

# This target is to build small for testing (no debugging info), removes
# all intermediate products, too
strip : $(PRODUCTS)
	strip $(PRODUCTS)
	rm -rf $(JUNK)


# make depend will set up the header file dependencies for the 
# assignment.  You should make depend whenever you add a new header
# file to the project or move the project between machines
#
depend:
	sed -i '/^# DO NOT DELETE$$/{q}' Makefile
	$(CC) -MM -MG $(SRCS) $(PREP_SRCS) >> Makefile

clean:
	rm -f $(JUNK) y.output $(PRODUCTS)

# DO NOT DELETE
errors.o: errors.cc errors.h location.h
utility.o: utility.cc utility.h list.h
libyywrap.o: libyywrap.cc
main.o: main.cc utility.h errors.h location.h scanner.h
dppmain.o: dppmain.cc scanner.h
