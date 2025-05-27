clear: 
	rm -rf *.o *.a *_test

fmt: 
	clang-format -style=LLVM -i `find -regex ".+\.[ch]"`

check_fmt:
	clang-format -style=LLVM -i `find -regex ".+\.[ch]"` --dry-run --Werror


stack.o: stack.c stack.h
	gcc -g -c stack.c -o stack.o

stack.a: stack.o
	ar rc stack.a stack.o
	

stack_test.o: stack_test.c
	gcc -g -c stack_test.c -o stack_test.o

stack_test: stack_test.o stack.a
	gcc -g -o stack_test stack_test.o stack.a -lm


test: stack_test
	@for test in $(shell find . -maxdepth 2 -type f -regex '.*_test'); do \
		echo "$$test is running"; \
		./$$test || exit 1; \
		echo "$$test is checking for memory leaks"; \
		# valgrind --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all --quiet ./$$test >/dev/null 2>&1 echo $?; \
		valgrind --vgdb=no --leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all --quiet ./$$test; \
	done
