#	Gregory Fowler, Andrew Latham, Patrick Melvin, Caley Shem-Crumrine
#	EECS 314 Final Project
#	Sudoku Generator & Solver
#
#	main.asm
#	Main assembly file (from which the user runs the program)

.text
main:
	la	$a0	hello_1
	li	$v0	4
	syscall
	
	li	$v0	10			#	Always terminate the program with these two lines
	syscall				#	Otherwise there will be random data floating around since the program won't end

.data
	hello_1:	.ascciz	"Test \n"

#	Finish main.asm