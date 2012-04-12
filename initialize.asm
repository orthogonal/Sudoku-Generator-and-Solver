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
	li		$t2, 0					#$t2 is i
	move	$t3, $s0				#$t3 is the index of the array ($s0[i])
	
printstart:
	beq		$t2, 81, printend		#while (i < 81)
	
	lw		$a0, ($t3)				#Get $s0[i] ($t3 holds the index in memory that the value will be at)
	beq		$a0, $zero, printspace	#If it is 0 print a space, if it is not then just continue and print it.
	li		$v0, 1
	syscall
	j 		notzero					#Skip all the printing-a-space stuff since it is not a space.
printspace:
	li		$v0, 4
	la		$a0, Underscore
	syscall							#Print the space
notzero:
	
	addi	$t2, $t2, 1				#i++
	addi	$t3, $t3, 4				#Increment the array pointer
	
	li		$v0, 4
	la		$a0, Space
	syscall							#Output a space (between the numbers)
	
	li		$a0, 3					#This checks if i = 0 mod 3, and if it is then it outputs another space.
	div		$t2, $a0				#This way there is a bigger space between the blocks of the table.
	mfhi	$a0
	bne		$a0, $zero, stopspaces	#If i != 0 mod 3, it will be != 0 mod 9 and 0 mod 27 as well, so skip the next few steps.
	li		$v0, 4
	la		$a0, Space
	syscall
	
	li		$a0, 9					#This checks if i = 0 mod 9, and if it is, then it outputs a new line.
	div		$t2, $a0				
	mfhi	$a0
	bne		$a0, $zero, stopspaces
	li		$v0, 4
	la		$a0, NewLine
	syscall
	
	li		$a0, 27					#This checks if i = 0 mod 27, and if it is, then it outputs another new line.
	div		$t2, $a0				#This way, there is a blank line between sets of blocks (vertically).
	mfhi	$a0
	bne		$a0, $zero, stopspaces
	li		$v0, 4
	la		$a0, NewLine
	syscall
	
stopspaces:
	j 		printstart				#Loop back around.
printend:
	jr		$ra						#Return (this is a void function).
	
	
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
First:		.asciiz "Please choose an option:\n1:  Solve a Sudoku Puzzle\n2:  Generate a Sudoku Puzzle"