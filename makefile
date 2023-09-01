#
# UFRGS - Compiladores - Etapa 1
# Cleiber Rodrigues e Cintia Valente
# Cartões 00270139 - 00228540
#
# Makefile for single compiler call

FLAGS=-Wall -g
COMP=g++-10 -std=c++20
 
etapa4: compile_font
	${COMP} ${FLAGS} -o etapa6 lex.yy.o parser.tab.o table.o tree.o code.o main.o -lfl
compile_font: parser.tab.c lex.yy.c
	${COMP} ${FLAGS} -c parser.tab.c lex.yy.c main.c tree.cc table.cc code.cc
parser.tab.c: parser.y
	bison -d parser.y
lex.yy.c: scanner.l
	flex scanner.l


clean:
	rm *.o lex.yy.c* parser.tab.* *.hh.gch etapa*