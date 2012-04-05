#	initialize.asm
#	Andrew Latham
#	EECS 314 Final Project
#	Initializes and displays a 9 x 9 array to represent a Sudoku table based on user input
#	Registers Used:
#	$s0:  The array
#	$t0:  Temporary i for user query loop
#	$t1:  Temporary array address for user query loop
#	$t2:  Temporary i for print loop
#	$t3:  Temporary array address for print loop

	.text
main:
	li		$v0, 9		#9 is the syscall to allocate heap memory for an array.  Specify how many bytes to alloate in $a0.
	li		$a0, 324	#Allocate 324 bytes (81 words)
	syscall
	move	$s0, $v0	#So $s0 is the array.
	move	$t1, $s0	#$t1 loops through the array in initialization.
	
	li		$t0, 0		#$t0 is i
	#Initialize everything to zero
allzerosstart:
	beq		$t0, 81, allzerosstop
	sw		$zero, ($t1)
	addi	$t0, 1
	addi	$t1, 4
	j allzerosstart
allzerosstop:
	
	li		$t0, 0
	move	$t1, $s0
	
	jal		printboard
	
initstart:
	beq		$t0, 81, initend
	
	#Print "Enter the value to go in cell i":
	li		$v0, 4			#4 is the syscall to display a word.
	la		$a0, PromptNo
	syscall
	li		$v0, 1			#1 is the syscall to display a number
	move	$a0, $t0	
	syscall
	li		$v0, 4
	la		$a0, Semicolon
	syscall
	li		$v0, 5
	syscall
	sw		$v0, ($t1)		#Gets the value from the user and stores it in $s0[i]
	
	li		$a0, 9						#$a0 isnt important right now
	bgt		$v0, $a0, invalidinput		#If the value is > 9, it is invalid
	blt		$v0, $zero, invalidinput	#If the value is < 0, it is invalid
	bge		$v0, $zero, validinput		#The value must be >= 0 (not sure if this is necessary, but I want to make sure it is numeric)
	j		invalidinput
validinput:
	
	addi	$t0, $t0, 1					#Increment i
	addi	$t1, $t1, 4					#Increment the array address
	
	jal		printboard					#Print the board
	j 		initstart					#Loop back
	
invalidinput:
	li		$v0, 4						#Tell the user their input is invalid.
	la		$a0, Invalid
	syscall
	sw		$zero, ($t1)
	j initstart
	
initend:
	jal		printboard
	j 		end

printboard:
	li		$t2, 0
	move	$t3, $s0
	
printstart:
	beq		$t2, 81, printend
	
	li		$v0, 1
	lw		$a0, ($t3)
	beq		$a0, $zero, printspace
	syscall
	j 		notzero
printspace:
	li		$v0, 4
	la		$a0, Underscore
	syscall
notzero:
	
	addi	$t2, $t2, 1
	addi	$t3, $t3, 4
	
	li		$v0, 4
	la		$a0, Space
	syscall
	
	li		$t4, 3
	div		$t2, $t4
	mfhi	$t4
	bne		$t4, $zero, stopspaces
	li		$v0, 4
	la		$a0, Space
	syscall
	
	li		$t4, 9
	div		$t2, $t4
	mfhi	$t4
	bne		$t4, $zero, stopspaces
	li		$v0, 4
	la		$a0, NewLine
	syscall
	
	li		$t4, 27
	div		$t2, $t4
	mfhi	$t4
	bne		$t4, $zero, stopspaces
	li		$v0, 4
	la		$a0, NewLine
	syscall
	
stopspaces:
	j 		printstart
printend:
	jr		$ra
	
	
end:
	li		$v0, 10
	syscall
	
	
	


.data
PromptNo:	.asciiz "\nEnter the value (0 for blank) to go in cell "
Semicolon:	.asciiz ": "
NewLine:	.asciiz "\n"
Space:		.asciiz " "
Invalid:	.asciiz "\nInvalid Input"
Underscore:	.asciiz "_"