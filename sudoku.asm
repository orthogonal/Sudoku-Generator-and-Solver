#################################################################
#	sudoku.asm
#	Gregory Fowler, Andrew Latham, Patrick Melvin, Caley Shem-Crumrine
#	EECS 314 Final Project
#	Gives the user the option to either generate a solvable Sudoku puzzle or use an engine to solve a user-specified puzzle.
#	Registers used:
#	$s0:  Base address of the output Sudoku puzzle
#	$s1:  Base address of the input Sudoku puzzle
#################################################################

	.text	
main:
	la		$a0, Welcome
	li		$v0, 4
	syscall
	
	li		$v0, 9
	li		$a0, 324
	syscall
	move	$s1, $v0	# So $s1 is the base address of the input array.
	
#####
#	OK, the two arrays (input and output) are now initialized.  First, the user decides what he/she wants to do.
#####Wr

first_choice:

	li		$v0, 4
	la		$a0, First
	syscall
	
	li		$v0, 5
	syscall

#####
#	Now $v0 holds the value the user put in.  it is 1 if they want to solve a puzzle and 2 if they want to generate one.
#####
	
	li		$a0, 1
	beq		$v0, $a0, define_puzzle
	
	li		$a0, 2
	beq		$v0, $a0, generate_puzzle
	
	# If the user did not put either 1 or 2, then what they put is invalid.  Ask them again.
	li		$v0, 4
	la		$a0, Invalid
	syscall
	j		first_choice




#####################################
##	Function RandomGeneration:
##	Generates a random number between 0 and 8 
##	The user can put a number from 1 through 9, or 0 for a blank.  Invalid inputs are rejected.
##	After each input, the board is re-printed.  To the user this looks like a live update.
##	Since this will inevitably come at the beginning of the program, we can afford to be 
##			cavalier about which registers are being used.
##	The array is initialized to be all zeroes.  Then, for each index, the user is prompted, and their
##			input is received.  If it is valid, it is saved and i is incremented.  If it is invalid,
##			the user is informed of this and prompted to re-enter their value.
##	This section does not check to see if the Sudoku puzzle is solveable, or even valid.
##	
##	Registers:
##	$t0:  i, which is the index of the input array that is currently being modified.
##	$t1:  A pointer to the index of the input array currently being modified. 
##	$a0:  Used for constants in a variety of places.
######################################

RandomGeneration:

	la $t0, FirstPuzzle
	li $t1, 0

# Get two sufficiently large input values in order to seed the RNG
			
GetFirstValue:	
	la $a0, AskFirstValue
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	# check that the user entered an appropriate value.  If they didn't, try again

	blt $v0, 1000, GetFirstValue
	bgt $v0, 99999, GetFirstValue
	
	move $s7, $v0
	
	bne $s7, 12345, GetSecondValue	# check for an easter egg. if the user didn't enter an appropriate value, just move on.
	la $a0, LuggageCode
	li $v0, 4
	syscall
	
GetSecondValue:
	la $a0, AskSecondValue
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	move $t0, $v0	# temporarily move the second value to t0.  This will be overwritten later, but I'll be done with it by then.
	
	bne $v0, 1337, NoEggs
	la $a0, NotLeet
	li $v0, 4
	syscall
	
	j Constants
	
	
NoEggs:	blt $v0, 1000, GetSecondValue
	bgt $v0, 99999, GetSecondValue
		
####### These are all constants.
Constants:
	li $t9, 10000 	# the remainder will be divided by 10000 to get a number between 0 and 8
	add $s7, $s7, $t0
	li $s4, 61	# store a in s4
	li $s5, 3571	# store c in s5
	li $s6, 90000	# store m in s6
	
########
	li $t7, 1000 
	
GetDifficulty:
	la $a0, AskDifficulty
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	blt		$v0, 1, GetDifficulty
	bgt		$v0, 9, GetDifficulty
	
	move $s0, $v0	# move the difficulty into s0
	
difficulty_end:

	# TEST
	b	generate_puzzle_2
	
###### $t8 is the 1-digit random number.





















######
#	If the user chooses to solve a puzzle, they first have to input the puzzle they want to solve.
#	So we first have this puzzle-input sequence.
######

#####################################
##	Function define_puzzle
##	This loops through each index 0 - 81 and asks the user what number to put there.
##	The user can put a number from 1 through 9, or 0 for a blank.  Invalid inputs are rejected.
##	After each input, the board is re-printed.  To the user this looks like a live update.
##	Since this will inevitably come at the beginning of the program, we can afford to be 
##			cavalier about which registers are being used.
##	The array is initialized to be all zeroes.  Then, for each index, the user is prompted, and their
##			input is received.  If it is valid, it is saved and i is incremented.  If it is invalid,
##			the user is informed of this and prompted to re-enter their value.
##	This section does not check to see if the Sudoku puzzle is solveable, or even valid.
##	This is for the input array, so $s1 is being defined.
##	
##	Registers:
##	$t0:  i, which is the index of the input array that is currently being modified.
##	$t1:  A pointer to the index of the input array currently being modified. 
##	$a0:  Used for constants in a variety of places.
######################################

define_puzzle:
	move	$t1, $s1	# $t1 loops through the input array in initialization.
	
	li		$t0, 0		# $t0 is i
	
	# Initialize all of $s1 to zero
allzerosstart:
	beq		$t0, 81, allzerosstop
	sw		$zero, ($t1)
	addi	$t0, $t0, 1
	addi	$t1, $t1, 4
	j allzerosstart
	
allzerosstop:				# Continue, now that everything is 0.
	
	li		$t0, 0
	move	$t1, $s1
	
	move	$s2, $s1
	jal		printboard
	
initstart:
	beq		$t0, 81, initend
	
	#Print "Enter the value to go in cell i":
	li		$v0, 4			# 4 is the syscall to display a word.
	la		$a0, PromptNo
	syscall
	li		$v0, 1			# 1 is the syscall to display a number
	move	$a0, $t0	
	syscall
	li		$v0, 4
	la		$a0, Semicolon
	syscall
	li		$v0, 5
	syscall
	sw		$v0, ($t1)		# Gets the value from the user and stores it in $s0[i]
	
	li		$a0, 9						# $a0 isnt important right now
	bgt		$v0, $a0, invalidinput		# If the value is > 9, it is invalid
	blt		$v0, $zero, invalidinput	# If the value is < 0, it is invalid
	bge		$v0, $zero, validinput		# The value must be >= 0 (not sure if this is necessary, but I want to make sure it is numeric)
	j		invalidinput
validinput:
	
	addi	$t0, $t0, 1					# Increment i
	addi	$t1, $t1, 4					# Increment the array address
	
	move	$s2, $s1
	jal		printboard					# Print the board
	j 		initstart					# Loop back
	
invalidinput:
	li		$v0, 4						# Tell the user their input is invalid.
	la		$a0, Invalid
	syscall
	sw		$zero, ($t1)
	j initstart
	
initend:
	j		solve						# Now it solves the puzzle.
	
#####################################


#####################################
##	Function printboard
##	This takes $s2 as an argument.  $s2 must be a pointer to the puzzle to be printed.
##	The puzzle is output to the console.
##	To call this function, use the following syntax:
##		addi	$sp, $sp, -8	
##		sw		$a0, 0($sp)
##		sw		$ra, 4($sp)
##		move	$s2, PointerToArray
##		jal		printboard	
##		lw		$ra, 4($sp)
##		lw		$a0, 0($sp)	
##		addi	$sp, $sp, 8
##	$t7 and $t8 are used.  They are usually constants.
##	Their constant values are returned to normal at the end of operation, so it is alright.
##	
##	Registers:
##	$s2:  A pointer to the start of the array.  Passed as an argument.
##	$t7:  i, which is the current index in the array.  Starts at 0, but it considers 
##				the array indices to be 1 through 81 for modular convenience.
##	$t8:  A pointer to various indices within the array.
##	$ra:  A pointer to the memory address of the point of execution before printboard was called.
######################################

printboard:
	li		$t7, 0					# $t7 is i
	move	$t8, $s2				# $t8 is the index of the array ($s2[i])
	la		$a0, NewLine
	li		$v0, 4
	syscall
	
printstart:
	beq		$t7, 81, printend		# while (i < 81)
	
	lw		$a0, ($t8)				# Get $s2[i] ($t8 holds the index in memory that the value will be at)
	beq		$a0, $zero, printspace	# If it is 0 print a space, if it is not then just continue and print it.
	li		$v0, 1
	syscall
	j 		notzero					# Skip all the printing-a-space stuff since it is not a space.

printspace:
	li		$v0, 4
	la		$a0, Underscore
	syscall							# Print the space

notzero:	
	addi	$t7, $t7, 1				# i++
	addi	$t8, $t8, 4				# Increment the array pointer
	
	li		$v0, 4
	la		$a0, Space
	syscall							# Output a space (between the numbers)
	
	li		$a0, 3					# This checks if i = 0 mod 3, and if it is then it outputs another space.
	div		$t7, $a0				# This way there is a bigger space between the blocks of the table.
	mfhi	$a0
	bne		$a0, $zero, stopspaces	# If i != 0 mod 3, it will be != 0 mod 9 and 0 mod 27 as well, so skip the next few steps.
	li		$v0, 4
	la		$a0, Space
	syscall
	
	li		$a0, 9					# This checks if i = 0 mod 9, and if it is, then it outputs a new line.
	div		$t7, $a0				
	mfhi	$a0
	bne		$a0, $zero, stopspaces
	li		$v0, 4
	la		$a0, NewLine
	syscall
	
	li		$a0, 27					# This checks if i = 0 mod 27, and if it is, then it outputs another new line.
	div		$t7, $a0				# This way, there is a blank line between sets of blocks (vertically).
	mfhi	$a0
	bne		$a0, $zero, stopspaces
	li		$v0, 4
	la		$a0, NewLine
	syscall
	
stopspaces:
	j 		printstart				# Loop back around.

printend:
	li		$t7, 8
	li		$t8, 9
	jr		$ra						# Return (this is a void function).
	
########################################


#####################################
##	Function generate_puzzle
##	This takes a predefined solved sudoku board (array starter_board, see .data section for declaration)
##	and switches random pairs of cells, pairs of rows, or pairs of columns a random amount of times.
##	
##	Registers:
##	$t0: number of switches to be made (1000-9000, defined using random number generator)
##	$t1: temporarily holds multiplicand; holds what kind of switch is to be made (0-2); temp for row_switch loop
##	$t3: holds first row/cell/column to be switched.
##	$t4: holds second row/cell/column to be switched.
######################################

generate_puzzle: 

	# Generate random number from 1-9, multiply by 1000.
	# This will be the number of switches performed.
	
	b		RandomGeneration
generate_puzzle_2:
	addi	$sp, $sp, -8	
	sw		$a0, 0($sp)
	sw		$ra, 4($sp)
	jal		RandomNumberGenerator
	lw		$ra, 4($sp)
	lw		$a0, 0($sp)	
	addi	$sp, $sp, 8
	
	move	$t0, $t8		# $t0 holds random number
	li		$t1, 1000
	mul		$t0, $t0, $t1
	
	srl		$s3, $t0, 4
	
	la		$a0, Generating
	li		$v0, 4
	syscall
	
switch_loop:
	# Loops through $t0 times, performs one switch per loop.
	beqz	$t0, print_board
	addi	$t0, $t0, -1			# decrement counter
	
	div		$t0, $s3
	mfhi	$a0
	bne		$a0, $zero, no_print_dot
	
	la		$a0, Dot
	li		$v0, 4
	syscall
no_print_dot:
	
	# Generate random number from 0-9.
	# This will be the type of switch to perform.
	addi	$sp, $sp, -8	
	sw		$a0, 0($sp)
	sw		$ra, 4($sp)
	jal		RandomNumberGenerator
	lw		$ra, 4($sp)
	lw		$a0, 0($sp)	
	addi	$sp, $sp, 8
	move	$t1, $t8		# $t1 holds random number
	li		$t2, 3			# Used for comparisons.
	
	# Determine which switch to make, call appropriate function
	sub		$t1, $t1, $t2		# $t1 - 3
	blez	$t1, switch_rows	# if $t1 <= 3, switch rows
	sub		$t1, $t1, $t2		# $t2 - 3
	blez	$t1, switch_cols	# if $t1 <= 6, switch columns
	sub		$t1, $t1, $t2		# $t2 - 3
	blez	$t1, switch_cells	# if $t1 <= 9, switch cells

	print_board:
		la		$t1, starter_board	# Load first array address
		move	$s2, $t1
		move	$s1, $t1
		b		WriteZeroes


#####
#		Switches two entire rows, but only within the same row of squares.
#####
	
switch_rows:
	# Generate two random numbers to determine which rows to switch
	# First number is 1-9
	addi	$sp, $sp, -8	
	sw		$a0, 0($sp)
	sw		$ra, 4($sp)
	jal		RandomNumberGenerator
	lw		$ra, 4($sp)
	lw		$a0, 0($sp)	
	addi	$sp, $sp, 8
	move	$t3, $t8		# $t3 holds random number
	
	# Second number is 1-2, as rows must be in the same square
	addi	$sp, $sp, -8	
	sw		$a0, 0($sp)
	sw		$ra, 4($sp)
	jal		RandomNumberGenerator
	lw		$ra, 4($sp)
	lw		$a0, 0($sp)	
	addi	$sp, $sp, 8
	move	$t4, $t8		# $t4 holds random number
	li		$t5, 5			# for comparison
	sub		$t4, $t4, $t5
	blez	$t4, t4_1		# if $t4 <= 5, set to 1
	li		$t4, 2			# else set to 2
	b		square_one

t4_1:
	li		$t4, 1
	b		square_one
	
	# Ensure rows are within the same square (square_one, square_two, or square_three)
	square_one:
		li		$t2, 3			# Used for comparisons.
		sub		$t2, $t3, $t2
		bgtz	$t2, square_two	# if row1 > 3 (not in square 1)
		add		$t4, $t4, $t3	# row2 += row1
		li		$t2, 3
		sub		$t2, $t4, $t2
		blez	$t2, row_switch	# if row2 <= 3, proceed to switch
		addi	$t4, $t4, -3	# row2 -= 3
		b		row_switch

	square_two:
		li		$t2, 6
		sub		$t2, $t3, $t2
		bgtz	$t2, square_three	# if row1 > 6 (not in square 1 or 2)
		add		$t4, $t4, $t3		# row2 += row1
		li		$t2, 6
		sub		$t2, $t4, $t2
		blez	$t2, row_switch		# if row2 <= 6, proceed to switch
		addi	$t4, $t4, -3		# row2 -= 3
		b		row_switch
		
	square_three:
		add		$t4, $t4, $t3		# row2 += row1
		li		$t2, 9
		sub		$t2, $t4, $t2
		blez	$t2, row_switch		# if row2 <= 9, proceed to switch
		addi	$t4, $t4, -3		# row2 -= 3
		
	# Perform row switch.
	row_switch:
		# Calculate indices of the first cell in each row, store them back in their registers.
		li		$t2, 9
		addi	$t3, $t3, -1
		mul		$t3, $t3, $t2	# Index of cell1 = (row1 - 1) * 9
		addi	$t4, $t4, -1
		mul		$t4, $t4, $t2	# Index of cell2 = (row2 - 1) * 9
	
	row_switch_loop:
		# Loops through 9 times
		beqz	$t2, switch_loop	
		addi	$t2, $t2, -1
		
		# Get address and value of cell1.
		move	$t5, $t3			# copy $t3
		la		$t1, starter_board	# Load first array address
		add		$t5, $t5, $t5    	# double the index of row1
		add		$t5, $t5, $t5    	# double the index again (now 4x)
		add		$t1, $t1, $t5		# $t1 = address of cell1
		lw		$t5, 0($t1)			# $t1 = value of cell1
		
		# Get address and value of cell2.
		move	$t7, $t4			# copy $t4
		la		$t6, starter_board	# Load first array address
		add		$t7, $t7, $t7    	# double the index of row2
		add		$t7, $t7, $t7    	# double the index again (now 4x)
		add		$t6, $t6, $t7		# $t6 = address of cell2
		lw		$t7, 0($t6)			# $t7 = value of cell2
		
		# Set board[cell1] to board[cell2]
		sw		$t7, 0($t1)
		
		# Set board[cell2] to board[cell1]
		sw		$t5, 0($t6)
		
		# Increment cell indices.
		addi	$t3, $t3, 1
		addi	$t4, $t4, 1

		b		row_switch_loop


#####
#		Switches two entire columns, but only within the same column of squares.
#####	
	
switch_cols:
	# Generate two random numbers to determine which rows to switch
	# First number is 1-9
	addi	$sp, $sp, -8	
	sw		$a0, 0($sp)
	sw		$ra, 4($sp)
	jal		RandomNumberGenerator
	lw		$ra, 4($sp)
	lw		$a0, 0($sp)	
	addi	$sp, $sp, 8
	move	$t3, $t8		# $t3 holds random number
	
	# Second number is 1-2, as rows must be in the same square
	addi	$sp, $sp, -8	
	sw		$a0, 0($sp)
	sw		$ra, 4($sp)
	jal		RandomNumberGenerator
	lw		$ra, 4($sp)
	lw		$a0, 0($sp)	
	addi	$sp, $sp, 8
	move	$t4, $t8		# $t4 holds random number
	li		$t5, 5			# for comparison
	sub		$t4, $t4, $t5
	blez	$t4, t4_1_col	# if $t4 <= 5, set to 1
	li		$t4, 2			# else set to 2
	b		square_one_col

t4_1_col:
	li		$t4, 1
	b		square_one_col

	# Ensure columns are within the same square (square_one, square_two, or square_three)
	square_one_col:
		li		$t2, 3			# Used for comparisons.
		sub		$t2, $t3, $t2
		bgtz	$t2, square_two_col	# if column1 > 3 (not in square 1)
		add		$t4, $t4, $t3		# column2 += column1
		li		$t2, 3
		sub		$t2, $t4, $t2
		blez	$t2, column_switch	# if column2 <= 3, proceed to switch
		addi	$t4, $t4, -3		# column2 -= 3
		b		column_switch

	square_two_col:
		li		$t2, 6
		sub		$t2, $t3, $t2
		bgtz	$t2, square_three_col	# if column1 > 6 (not in square 1 or 2)
		add		$t4, $t4, $t3			# column2 += column1
		li		$t2, 6
		sub		$t2, $t4, $t2
		blez	$t2, column_switch		# if column2 <= 6, proceed to switch
		addi	$t4, $t4, -3			# column2 -= 3
		b		column_switch
		
	square_three_col:
		add		$t4, $t4, $t3		# column2 += column1
		li		$t2, 9
		sub		$t2, $t4, $t2
		blez	$t2, column_switch	# if column2 <= 9, proceed to switch
		addi	$t4, $t4, -3		# column2 -= 3
		
	# Perform column switch.
	column_switch:
	
		# Calculate indices of the first cell in each column, store them back in their registers.
		li		$t2, 9
		addi	$t3, $t3, -1	# Index of cell1 = column1 - 1
		addi	$t4, $t4, -1	# Index of cell2 = column2 - 1
		
	
	column_switch_loop:
		# Loops through 9 times
		beqz	$t2, switch_loop	
		addi	$t2, $t2, -1

		# Get address and value of cell1.
		move	$t5, $t3			# copy $t3
		la		$t1, starter_board	# Load first array address
		add		$t5, $t5, $t5    	# double the index of row1
		add		$t5, $t5, $t5    	# double the index again (now 4x)
		add		$t1, $t1, $t5		# $t1 = address of cell1
		lw		$t5, 0($t1)			# $t5 = value of cell1
		
		# Get address and value of cell2.
		move	$t7, $t4			# copy $t4
		la		$t6, starter_board	# Load first array address
		add		$t7, $t7, $t7    	# double the index of row2
		add		$t7, $t7, $t7    	# double the index again (now 4x)
		add		$t6, $t6, $t7		# $t6 = address of cell2
		lw		$t7, 0($t6)			# $t7 = value of cell2
		
		# Set board[cell1] to board[cell2]
		sw		$t7, 0($t1)
		
		# Set board[cell2] to board[cell1]
		sw		$t5, 0($t6)
		
		# Increment cell indices.
		addi	$t3, $t3, 9
		addi	$t4, $t4, 9

		b column_switch_loop

	
#####
#		Switches two numbers in every cell in which they appear.
#####
	
switch_cells:

	# Generate two random numbers to determine which rows to switch
	# Both numbers are 1-9
	addi	$sp, $sp, -8	
	sw		$a0, 0($sp)
	sw		$ra, 4($sp)
	jal		RandomNumberGenerator
	lw		$ra, 4($sp)
	lw		$a0, 0($sp)	
	addi	$sp, $sp, 8
	move	$t3, $t8		# $t3 holds random number
	
	# Second number is 1-2, as rows must be in the same square
	addi	$sp, $sp, -8	
	sw		$a0, 0($sp)
	sw		$ra, 4($sp)
	jal		RandomNumberGenerator
	lw		$ra, 4($sp)
	lw		$a0, 0($sp)	
	addi	$sp, $sp, 8
	move	$t4, $t8		# $t4 holds random number

	li		$t2, 81			# Loop counter
	
	cell_switch_loop:	
		beqz	$t2, switch_loop
		addi	$t2, $t2, -1
	
		# Get value of cell
		move	$t6, $t2			# copy $t2
		la		$t1, starter_board	# Load first array address
		add		$t6, $t6, $t6    	# double the index of counter
		add		$t6, $t6, $t6    	# double the index again (now 4x)
		add		$t1, $t1, $t6		# $t1 = address of cell
		lw		$t5, 0($t1)			# $t5 = value of cell
		
		# Check if cell has value that should be switched
		beq		$t5, $t3, switch_cell_1
		beq		$t5, $t4, switch_cell_2
		b		cell_switch_loop
		
	switch_cell_1:		
		sw		$t4, 0($t1)	
		b		cell_switch_loop
	
	switch_cell_2:
		sw		$t3, 0($t1)
		b		cell_switch_loop


####################################
## Function RandomNumberGenerator
##	
## So, the way this method works is that it multiplies a by Xn, adds c to that, and gets the remainder of that mess all divided by m.
## Then I come along and divide the remainder by 10000 to get it within the range we want.
## The final random number generated will be found in t8.  Note that t8 can be overwritten as soon as you have the number you want; just don't store anything in there you want to keep.
##
####################################

RandomNumberGenerator:
		
	#beq 	$t7, $zero, WriteZeroes	# Once we have completely generated the puzzle, then go through and write zeroes to appropriate locations.
	mul 	$s7, $s7, $s4
	add 	$s7, $s7, $s5
	div 	$s7, $s6 
	mfhi	$s7
	add 	$t8, $s7, $zero
	div 	$t8, $t8, $t9
	mflo 	$t8
	addi	$t8, $t8, 1
	jr 		$ra	
	
	##################################################
	# here, determine what switches need to be done, #
	# and whether they are rows, cells, etc.	 #
	##################################################
	
	
	
# generate a random number.  If that number is under the selected difficulty, write a zero to that location and move to the next number.  Otherwise, just move to the next number
WriteZeroes:
	beq $t0, 81, Done
	mul $s7, $s7, $s4
	add $s7, $s7, $s5
	div $s7, $s6 
	mfhi $s7
	add $t8, $s7, $zero
	div $t8, $t9
	mflo $t8
	addi $t8, $t8, 1

	addi $t0, $t0, 1	# increment t0
	
	bgt $t8, $s0, DoNothing
	j WriteAZero
	
DoNothing:
	addi $t1, $t1, 4
	j WriteZeroes

WriteAZero:
	sw $zero, 0($t1)
	addi $t1, $t1, 4
	j WriteZeroes
	
Done:
	jal		printboard
	la		$a0, Continue
	li		$v0, 4
	syscall
	li		$v0, 5
	syscall
	j		solve
	

####################################


solve:

##########  SOLVING STARTS HERE  ###########

#####################################
##	Function populate_output_array
##	Basically this just sets $s0 (the output array) equal to $s1 (the input array) in every index.
##	
##	Registers:
##	$t0:  Pointer to current position in input  ($s1)
##	$t1:  Pointer to current position in output ($s0)
##	$t2:  Pointer to the stopping point
##	$t3:  Temporary value used to pass values between the arrays
######################################

	li		$v0, 9		# 9 is the syscall to allocate heap memory for an array.  Specify how many bytes to allocate in $a0.
	li		$a0, 324	# Allocate 324 bytes (81 words)
	syscall
	move	$s0, $v0	# So $s0 is the base address of the output array.
	
	la		$a0, Populating
	li		$v0, 4
	syscall
	
	li 		$t2, 324
	add 	$t2, $t2, $s1	# $t2 is the index of input[81], so the first nonexistant one.
	move 	$t0, $s1		# $t0 is the index of input
	move	$t1, $s0		# $t1 is the index of output
	
populate_output_array:
	la		$a0, Dot
	li		$v0, 4
	syscall
	
	lw 		$t3, 0($t0)		
	sw 		$t3, 0($t1)		# Copy from the input array to the output array
	
	addi 	$t0, $t0, 4
	addi 	$t1, $t1, 4		# Increment both pointers to the next address
	
	bne 	$t0, $t2, populate_output_array		# If the pointers are at the end of their arrays, continue.  Otherwise, loop.
	
	la		$a0, NewLine
	li		$v0, 4
	syscall
	
	move 	$t0, $s1			# Make $t0 the pointer to the beginning of the input array again.
	
	la		$a0, Solving
	li		$v0, 4
	syscall
	
	li		$s4, 0
	
###########  FUNCTION CALL:  Backtrack(0, 0)  ##########################

	li 		$a0, 0
	li 		$a1, 0
	
	addi 	$sp, $sp, -8
	
	sw 		$a0, 4($sp)
	sw 		$a1, 0($sp)
	
	jal 	backtrack
	
	lw 		$a1, 0($sp)
	lw 		$a0, 4($sp)
	
	addi 	$sp, $sp, 8
	
##########################################################################
	
	# Backtrack(0, 0) will return 0 if there is no solution to the sudoku puzzle.
	# In this case, we just tell the user that there is no solution.	
	beq 	$v0, $zero, print_no_soln
	
	#Otherwise, the array is solved.
	#So print the solved array.
	move	$s2, $s0
	jal		printboard
	j		end

# If there is no solution, then just tell the user and then end the program.
print_no_soln:
	la 		$a0, NoSolution
	li 		$v0, 4
	syscall
	j 		end


#####################################
##	Function backtrack
##	Backtrack takes two indices, x and y, as input parameters that specify the index of the array to use.
##	If this index has a value, then either backtrack recursively on the next cell or, if it is the last cell, return 1.
##  If the recursive backtrack works, return 1.
##	If this index is 0 (has no value), then, for each possible value 1 through 9,
##	Call input_value on the cell and the value, to see if it can go in that cell.
##	If it can not for any of the values, then return 0 and, if the input and output array differ on it, make the output value 0.
##	If it can for one of the values, then make it that value and do the same as you would do if the index had a value.
##	Registers:  
##	$a0:  Input x
##	$a1:  Input y
##	$a2:  Used as i in the loop
##	$t2:  Temporary value used as a pointer in various places
##	$t5:  Used as as temporary value for checking the loop condition
##	$t6:  Holds x briefly when $a0 is needed for a syscall
##	$t7:  Constant value of 8
##	$t8:  Constant value of 9
##	$t9:  Constant value of 10
##	$s4:  Used to generate dots every now and then.
##	$v0:  Often a return value from input_value, sometimes used for syscalls (the two uses are disjoint)
######################################


backtrack:

	#Load constants
	li		$t7, 8
	li		$t8, 9
	li		$t9, 10
	
	mult 	$a0, $t8
	mflo 	$t2 
	add 	$t2, $t2, $a1
	sll 	$t2, $t2, 2
	add 	$t2, $s0, $t2 
	lw 		$t2, 0($t2)		# $t2 is output[x][y]
	
	bne 	$t2, $zero, arr_not_zero 	# skip to the else statement if(outputArray[x][y] == 0)
	
	
	move 	$a2, $zero 	# $a2 is i and i = 0.  It increments at the beginning of the loop, which goes from 1 to 9.


i_loop:

	addi 	$a2, $a2, 1
	
	slt 	$t5, $a2, $t9 			# $t9 is 10, so if i < 10, $t5 is set to 1
	beq 	$t5, $zero, end_i_loop	# if $t5 is 0, then i = 10, and the loop is over.

###############   FUNCTION CALL:  input_value(x, y, i) #########################
	
	addi 	$sp, $sp, -56
	
	sw		$a2, 52($sp)
	sw		$a1, 48($sp)
	sw		$a0, 44($sp)
	sw 		$ra, 40($sp)
	sw 		$t9, 36($sp)
	sw 		$t8, 32($sp)
	sw		$t7, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)
	
	jal 	input_value
	
	lw	 	$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$t7, 28($sp)
	lw 		$t8, 32($sp)
	lw 		$t9, 36($sp)
	lw 		$ra, 40($sp)
	lw		$a0, 44($sp)
	lw		$a1, 48($sp)
	lw		$a2, 52($sp)
	
	addi 	$sp, $sp, 56
	
#################################################################
	
	move 	$t0, $v0 			# input_value returns 0 if the i can not be inserted into output[x][y], and i if it can.
	
	slt 	$t1, $zero, $t0 	# If we can insert i into output[x][y], then $t1 = 1.	
	beq 	$t1, $zero, i_loop	# If we can not, then go back to the beginning of the i loop.
	
	# If we can insert i into output[x][y], then do so.
	mult 	$a0, $t8
	mflo 	$t2 
	add 	$t2, $t2, $a1 
	sll 	$t2, $t2, 2 
	add 	$t2, $s0, $t2 
	sw 		$t0, 0($t2) 	# output[x][y] = $t0
	
	
	addi	$s4, $s4, 1
	bne		$s4, 100, nodot
	# Output a dot to let the user know that something is happening.
	move	$t6, $a0
	la		$a0, Dot
	li		$v0, 4
	syscall
	move	$a0, $t6
	li		$s4, 0
nodot:
	
	# If (x = 8 && y = 8) return 1, otherwise go to the different else cases to continue to the next cell.
	# We use De Morgans Law to check the equality condition.  $t7 is 8.
	bne 	$a0, $t7, output_zero_else		# If x != 8, then increment x.
	bne 	$a1, $t7, output_zero_else_if 	# If x = 8, but y != 8, then increment y and set x to 0.
	
	jr 		$ra		# This is technically the end of the backtrack function.  If !(x != 8 || y != 8) then (x = 8 && y = 8)


output_zero_else_if:

###########  FUNCTION CALL:  Backtrack(0, y + 1)  ##########################

	addi 	$sp, $sp, -56
	
	sw		$a2, 52($sp)
	sw		$a1, 48($sp)
	sw		$a0, 44($sp)
	sw 		$ra, 40($sp)
	sw 		$t9, 36($sp)
	sw 		$t8, 32($sp)
	sw		$t7, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)
	
	move 	$a0, $zero
	addi 	$a1, $a1, 1 
	
	jal 	backtrack
	
	lw	 	$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$t7, 28($sp)
	lw 		$t8, 32($sp)
	lw 		$t9, 36($sp)
	lw 		$ra, 40($sp)
	lw		$a0, 44($sp)
	lw		$a1, 48($sp)
	lw		$a2, 52($sp)
	
	addi 	$sp, $sp, 56
	
##################################################################

	# If backtrack(0, y + 1) != 0, then we return 1.
	# Otherwise, go back to the start of the i loop.
	beq 	$v0, $zero, i_loop
	jr 		$ra 


output_zero_else:

###########  FUNCTION CALL:  Backtrack(x + 1, y)  ##########################
	
	addi 	$sp, $sp, -56
	
	sw		$a2, 52($sp)
	sw		$a1, 48($sp)
	sw		$a0, 44($sp)
	sw 		$ra, 40($sp)
	sw 		$t9, 36($sp)
	sw 		$t8, 32($sp)
	sw		$t7, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)
	
	addi 	$a0, $a0, 1 
	
	jal backtrack
	
	lw	 	$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$t7, 28($sp)
	lw 		$t8, 32($sp)
	lw 		$t9, 36($sp)
	lw 		$ra, 40($sp)
	lw		$a0, 44($sp)
	lw		$a1, 48($sp)
	lw		$a2, 52($sp)
	
	addi 	$sp, $sp, 56
	
#########################################################################
	
	# If backtrack(x + 1, y) != 0, then we return 1.
	# Otherwise, go back to the start of the i loop.
	beq 	$v0, $zero, i_loop
	jr 		$ra


end_i_loop:
	mult 	$a0, $t8		# $t8 is 9
	mflo 	$t2 
	add 	$t2, $t2, $a1
	sll 	$t2, $t2, 2
	add 	$t2, $s0, $t2 
	lw 		$t5, 0($t2)		# $t5 = output[x][y]
	
	mflo 	$t1 			# LO still has the product of $a0 and $t8, so we dont need to multiply again.
	add 	$t1, $t1, $a1
	sll 	$t1, $t1, 2
	add 	$t1, $s1, $t1 	
	lw 		$t1, 0($t1)		# $t1 = input[x][y]
	
	beq 	$t1, $t5, arrays_match
	sw 		$zero, 0($t2) 	# output[x][y] = 0 if the input and output dont match

# Either way, return 0.
arrays_match:

	move $v0, $zero
	jr $ra


arr_not_zero:

	# This is what happens if we backtrack to a cell that already has a value in it.
	# If x and y are both 8, then we are at the end, and return 1.  Otherwise, backtrack the next cell.  $t7 is 8.

	bne 	$a0, $t7, output_not_zero_else 		
	bne 	$a1, $t7, output_not_zero_else_if 
	
	# If both branches above fail, then both x and y are 8, so return 1.
	li 		$v0, 1
	jr 		$ra

output_not_zero_else_if:

###########  FUNCTION CALL:  Backtrack(0, y + 1)  ##########################
	
	addi 	$sp, $sp, -56
	
	sw		$a2, 52($sp)
	sw		$a1, 48($sp)
	sw		$a0, 44($sp)
	sw 		$ra, 40($sp)
	sw 		$t9, 36($sp)
	sw 		$t8, 32($sp)
	sw		$t7, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)
	
	move 	$a0, $zero
	addi 	$a1, $a1, 1
	
	jal		backtrack
	
	lw	 	$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$t7, 28($sp)
	lw 		$t8, 32($sp)
	lw 		$t9, 36($sp)
	lw 		$ra, 40($sp)
	lw		$a0, 44($sp)
	lw		$a1, 48($sp)
	lw		$a2, 52($sp)
	
	addi 	$sp, $sp, 56
	
#################################################################
	
	jr 		$ra 
	# if $v0 == 0, I think we need to return 0, based on what I read at http://stackoverflow.com/questions/1610030/why-can-you-return-from-a-non-void-function-without-returning-a-value-without-pr

output_not_zero_else:

###########  FUNCTION CALL:  Backtrack(x + 1, y)  ##########################

	addi 	$sp, $sp, -56
	
	sw		$a2, 52($sp)
	sw		$a1, 48($sp)
	sw		$a0, 44($sp)
	sw 		$ra, 40($sp)
	sw 		$t9, 36($sp)
	sw 		$t8, 32($sp)
	sw		$t7, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)
	
	addi $a0, $a0, 1
	
	jal backtrack
	
	lw	 	$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$t7, 28($sp)
	lw 		$t8, 32($sp)
	lw 		$t9, 36($sp)
	lw 		$ra, 40($sp)
	lw		$a0, 44($sp)
	lw		$a1, 48($sp)
	lw		$a2, 52($sp)
	
	addi 	$sp, $sp, 56
	
##################################################

	jr $ra



#####################################
##	Function input_value
##	Takes x, y, and a value as parameters.
##	Checks the row, column, and box of cell (x, y) to see if the value is valid.
##	If it is, then return the value.  If it is not, return 0.
##	Registers:  
##	$t0:  Constant value of first 9 and then 3
##	$t4:  Constant value of 6
##	$t5:  Constant value of 9
##	$t1:  Used as i
##	$t2:  Used as j
##	$t3:  Used as a pointer in various places
##	$a0:  x
##	$a1:  y
##	$a2:  The value passed in to check
##	$ra:  The return address
##	$v0:  The value to return
######################################

input_value:

# $a2 is the value passed in.
	li 		$t0, 9
	li 		$t4, 6
	
	# First, scan horizantally and vertically, to see if the value is unique for its row or column.
	
	move 	$t1, $zero 	# i = 0

horiz_and_vert:
	mult 	$t1, $t0
	
	mflo 	$t2 
	add 	$t2, $t2, $a1 
	sll 	$t2, $t2, 2 
	add 	$t2, $s0, $t2 
	lw 		$t2, 0($t2)				# $t2 = output[i][y]
	
	beq 	$a2, $t2, set_to_zero 	# checking whether value == outputArray[i][y]
	
	mult 	$a0, $t0
	mflo 	$t2 
	add 	$t2, $t2, $t1 
	sll 	$t2, $t2, 2 
	add 	$t2, $s0, $t2
	lw 		$t2, 0($t2)				# $t2 = output[x][i]
	
	beq 	$a2, $t2, set_to_zero 	# checking whether value == outputArray[x][i]
	
	addi 	$t1, $t1, 1				# i++ and loop.
	bne 	$t1, $t0, horiz_and_vert
	
	# Now the annoying part... scanning it own square.  
	# We have to figure out what the square is, and then have a different case for each square.
	# This is long and repetitive.

	li 		$t0, 3
	slt 	$t1, $a0, $t0
	li 		$t5, 9
	beq 	$t1, $zero, x_3_to_5
	slt 	$t1, $a1, $t0
	beq 	$t1, $zero, x_less_3_y_3_to_5
	move 	$t1, $zero 						# i = 0

i_x_less_3_y_less_3:
	move 	$t2, $zero # j = 0

j_x_less_3_y_less_3:
	mult 	$t1, $t5
	mflo 	$t3 							# $t3 = i*9
	add 	$t3, $t3, $t2 					# $t3 = i*9 + j
	sll 	$t3, $t3, 2 					# $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3 					# now $t3 contains address of outputArray[i][j]
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t0, j_x_less_3_y_less_3
	addi 	$t1, $t1, 1
	bne 	$t1, $t0, i_x_less_3_y_less_3
	move 	$v0, $a2 						# want to return value
	jr 		$ra

x_less_3_y_3_to_5:
	slt 	$t1, $a1, $t4 					# if y < 6, $t1 is set to 1
	beq 	$t1, $zero, x_less_3_y_6_to_8
	move 	$t1, $zero 						# i = 0

i_x_less_3_y_3_to_5:
	move 	$t2, $t0 						# j = 3

j_x_less_3_y_3_to_5:
	mult 	$t1, $t5
	mflo 	$t3 							# $t3 = i*9
	add 	$t3, $t3, $t2 					# $t3 = i*9 + j
	sll 	$t3, $t3, 2 					# $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t4, j_x_less_3_y_3_to_5
	addi 	$t1, $t1, 1
	bne 	$t1, $t0, i_x_less_3_y_3_to_5
	move 	$v0, $a2 						# want to return value
	jr 		$ra

x_less_3_y_6_to_8:
	move 	$t1, $zero 						# i = 0

i_x_less_3_y_6_to_8:
	move 	$t2, $t4 # j = 6

j_x_less_3_y_6_to_8:
	mult 	$t1, $t5
	mflo 	$t3 							# $t3 = i*9
	add 	$t3, $t3, $t2 					# $t3 = i*9 + j
	sll 	$t3, $t3, 2 					# $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t5, j_x_less_3_y_6_to_8
	addi 	$t1, $t1, 1
	bne 	$t1, $t0, i_x_less_3_y_6_to_8
	move 	$v0, $a2 						# want to return value
	jr 		$ra

x_3_to_5:
	slt 	$t1, $a0, $t4 					# else if x < 6, $t1 is set to 1
	beq 	$t1, $zero, x_6_to_8
	slt 	$t1, $a1, $t0 					# if y < 3, $t1 is set to 1
	beq 	$t1, $zero, x_3_to_5_y_3_to_5
	move	$t1, $t0 						# i = 3

i_x_3_to_5_y_less_3:
	move 	$t2, $zero 						# j = 0

j_x_3_to_5_y_less_3:
	mult 	$t1, $t5
	mflo 	$t3 							# $t3 = i*9
	add 	$t3, $t3, $t2 					# $t3 = i*9 + j
	sll 	$t3, $t3, 2 					# $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3 					# now $t3 contains address of outputArray[i][j]
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t0, j_x_3_to_5_y_less_3
	addi 	$t1, $t1, 1
	bne 	$t1, $t4, i_x_3_to_5_y_less_3
	move 	$v0, $a2 						# want to return value
	jr 		$ra

x_3_to_5_y_3_to_5:
	slt 	$t1, $a1, $t4 					# if y < 6, $t1 is set to 1
	beq 	$t1, $zero, x_3_to_5_y_6_to_8
	move 	$t1, $t0 						# i = 3

i_x_3_to_5_y_3_to_5:
	move 	$t2, $t0 						# j = 3

j_x_3_to_5_y_3_to_5:
	mult 	$t1, $t5
	mflo 	$t3 							# $t3 = i*9
	add 	$t3, $t3, $t2 					# $t3 = i*9 + j
	sll 	$t3, $t3, 2 					# $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t4, j_x_3_to_5_y_3_to_5
	addi 	$t1, $t1, 1
	bne 	$t1, $t4, i_x_3_to_5_y_3_to_5
	move 	$v0, $a2 						# want to return value
	jr 		$ra

x_3_to_5_y_6_to_8:
	move 	$t1, $t0 						# i = 3

i_x_3_to_5_y_6_to_8:
	move 	$t2, $t4 						# j = 6

j_x_3_to_5_y_6_to_8:
	mult 	$t1, $t5
	mflo 	$t3 							# $t3 = i*9
	add 	$t3, $t3, $t2 					# $t3 = i*9 + j
	sll 	$t3, $t3, 2 					# $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t5, j_x_3_to_5_y_6_to_8
	addi 	$t1, $t1, 1
	bne 	$t1, $t4, i_x_3_to_5_y_6_to_8
	move 	$v0, $a2 						# want to return value
	jr 		$ra

x_6_to_8:
	slt 	$t1, $a1, $t0 					# if y < 3, $t1 is set to 1
	beq 	$t1, $zero, x_6_to_8_y_3_to_5
	move 	$t1, $t4 						# i = 6

i_x_6_to_8_y_less_3:
	move 	$t2, $zero 						# j = 0

j_x_6_to_8_y_less_3:
	mult 	$t1, $t5
	mflo 	$t3 							# $t3 = i*9
	add 	$t3, $t3, $t2 					# $t3 = i*9 + j
	sll 	$t3, $t3, 2 					# $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3 					# now $t3 contains address of outputArray[i][j]
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t0, j_x_6_to_8_y_less_3
	addi 	$t1, $t1, 1
	bne 	$t1, $t5, i_x_6_to_8_y_less_3
	move 	$v0, $a2 						# want to return value
	jr 		$ra

x_6_to_8_y_3_to_5:
	slt 	$t1, $a1, $t4 					# if y < 6, $t1 is set to 1
	beq 	$t1, $zero, x_6_to_8_y_6_to_8
	move 	$t1, $t4 						# i = 6

i_x_6_to_8_y_3_to_5:
	move 	$t2, $t0 						# j = 3

j_x_6_to_8_y_3_to_5:
	mult 	$t1, $t5
	mflo 	$t3 							# $t3 = i*9
	add 	$t3, $t3, $t2 					# $t3 = i*9 + j
	sll 	$t3, $t3, 2 					# $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t4, j_x_6_to_8_y_3_to_5
	addi 	$t1, $t1, 1
	bne 	$t1, $t5, i_x_6_to_8_y_3_to_5
	move 	$v0, $a2 						# want to return value
	jr 		$ra

x_6_to_8_y_6_to_8:
	move 	$t1, $t4 						# i = 6

i_x_6_to_8_y_6_to_8:
	move 	$t2, $t4 						# j = 6

j_x_6_to_8_y_6_to_8:
	mult 	$t1, $t5
	mflo 	$t3 							# $t3 = i*9
	add 	$t3, $t3, $t2 					# $t3 = i*9 + j
	sll 	$t3, $t3, 2 					# $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t5, j_x_6_to_8_y_6_to_8
	addi 	$t1, $t1, 1
	bne 	$t1, $t5, i_x_6_to_8_y_6_to_8
	move 	$v0, $a2 						# want to return value
	jr 		$ra

set_to_zero:
	move 	$v0, $zero 						# return 0
	jr 		$ra
	
end:
	la		$a0, ProgramDone
	li		$v0, 4
	syscall
	
	li		$v0, 10
	syscall
		
		
		
.data
Welcome:	.asciiz "\tSudoku Puzzle Generator/Solver\n\tBy Gregory Fowler, Andrew Latham, Patrick Melvin, and Caley Shem-Crumrine\n\tEECS 314 Final Project, Spring Semester 2012\n\n\n"
Populating:	.asciiz "Populating output array"
Dot:		.asciiz "."
NoSolution:	.asciiz "This sudoku puzzle is unsolvable."
PromptNo:	.asciiz "\nEnter the value (0 for blank) to go in cell "
Semicolon:	.asciiz ": "
NewLine:	.asciiz "\n"
Space:		.asciiz " "
Invalid:	.asciiz "Invalid Input"
Underscore:	.asciiz "_"
Solving:	.asciiz "Solving"
Generating:	.asciiz "Generating"
ProgramDone:.asciiz "\nDone"
First:		.asciiz "\nPlease choose an option:\n1:  Solve a Sudoku Puzzle\n2:  Generate a Sudoku Puzzle\nEnter choice: "
starter_board:	
	.word	1, 2, 3, 4, 5, 6, 7, 8, 9, 4, 5, 6, 7, 8, 9, 1, 2, 3, 7, 8, 9, 1, 2, 3, 4, 5, 6, 2, 3, 4, 5, 6, 7, 8, 9, 1, 5, 6, 7, 8, 9, 1, 2, 3, 4, 8, 9, 1, 2, 3, 4, 5, 6, 7, 3, 4, 5, 6, 7, 8, 9, 1, 2, 6, 7, 8, 9, 1, 2, 3, 4, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8
FirstPuzzle: 
	.word 1, 2, 3, 4, 5, 6, 7, 8, 9, 4, 5, 6, 7, 8, 9, 1, 2, 3, 7, 8, 9, 1, 2, 3, 4, 5, 6, 2, 3, 4, 5, 6, 7, 8, 9, 1, 5, 6, 7, 8, 9, 1, 2, 3, 4, 8, 9, 1, 2, 3, 4, 5, 6, 7, 3, 4, 5, 6, 7, 8, 9, 1, 2, 6, 7, 8, 9, 1, 2, 3, 4, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8
	.data
AskFirstValue:
	.asciiz "Enter a random value between 1000 and 99999\n"
AskSecondValue:
	.asciiz "Enter another number between 1000 and 99999.  These will be used to seed the random number generator, so try not to enter the same two numbers you did prior.\n"
AskDifficulty:
	.asciiz "Enter a value between 1 and 8.  This will determine how hard the final puzzle is.  Enter 9 for a blank board.\n"
Continue:	.asciiz  "\nPress Enter to solve this puzzle"
LuggageCode:
	.asciiz "Is that the combination on your luggage?\n"
NotLeet:
	.asciiz "If you have to proclaim your 1337ness, how 1337 are you really?\n"
