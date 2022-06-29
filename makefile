mufang: lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o mufang -DYYDEBUG

lex.yy.c: y.tab.c mufang.l
	lex mufang.l

y.tab.c: mufang.y
	yacc -d mufang.y

clean: 
	rm -rf lex.yy.c y.tab.c y.tab.h mufang mufang.dSYM

run:
	make clean
	make
	./mufang