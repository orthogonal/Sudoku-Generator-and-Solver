#################################################################
#	sudoku.asm
#	Gregory Fowler, Andrew Latham, Patrick Melvin, Caley Shem-Crumrine
#	EECS 314 Final Project
#	Gives the user the option to either generate a solvable Sudoku puzzle or use an engine to solve a user-specified puzzle.
#	Registers used:
#	$s0:  Base address of the output Sudoku puzzle
#	$s1:  Base address of the input Sudoku puzzle
#################################################################

# $t0 = temp, $t1 = result of temp calculation (orig. j, but that is not used), $t2 = bunch of stuff in forming outputArray[x][y]
# $t3 = 9, $t4 = 1, $t5 = 8, $t6 = 10
# $a0 = x, $a1 = y, $a2 = i
# $t7 = temporarily used to store value of x upon function call, $t8 = temporarily used to store value of y upon function call

	.text	
main:
	li		$v0, 9		# 9 is the syscall to allocate heap memory for an array.  Specify how many bytes to allocate in $a0.
	li		$a0, 324	# Allocate 324 bytes (81 words)
	syscall
	move	$s0, $v0	# So $s0 is the base address of the output array.
	
	li		$v0, 9
	li		$a0, 324
	syscall
	move	$s1, $v0	# So $s1 is the base address of the input array.
	
	j		generate_puzzle
	
#####
#	OK, the two arrays (input and output) are now initialized.  First, the user decides what he/she wants to do.
#####

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


	la $t0, FirstPuzzle
	li $t1, 0
		
####### These are all constants.

	# ********* NOTE: The following declarations should probably be moved into the main method, or else the program will load them into memory every time this method is called ********** #
	li $t2, 10000 	# the remainder will be divided by 10000 to get a number between 0 and 8
	li $t3, 50000	# the current instance of the method, Xn, will be kept in s7
	li $t4, 61	# store a in s4
	li $t5, 3571	# store c in s5
	li $t6, 90000	# store m in s6
	# ********** OK, you can stop moving things into the main method now.  Thats all I needed. ********** #
	
########
	
# generate a random number.  If that number is under 5, write a zero to that location and move to the next number.  Otherwise, just move to the next number
RandomGeneration:
	beq $t1, 81, PrintArray
	mul $t3, $t3, $t4
	add $t3, $t3, $t5
	div $t3, $t6 
	mfhi $t3
	add $t8, $t3, $zero
	div $t8, $t8, $t2
	mflo $t8
	addi $t8, $t8, 1

	addi $t1, $t1, 1	# increment t1
	
	move $a0, $t8
	li $v0, 1
	syscall
	
	bgt $t8, 4, DoNothing
	j WriteZero
	
DoNothing:
	addi $t0, $t0, 4
	j RandomGeneration

WriteZero:
	sw $zero, ($t0)
	addi $t0, $t0, 4
	j RandomGeneration

PrintArray:
	li $v0, 10
	syscall
	
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
	
	#Initialize all of $s1 to zero
allzerosstart:
	beq		$t0, 81, allzerosstop
	sw		$zero, ($t1)
	addi	$t0, 1
	addi	$t1, 4
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
	move	$s2, $s1
	jal		printboard
	
	#TESTING STUFF
	li		$a0, 0
	li		$a1, 0
	jal		backtrack
	#
	
	j 		end							#THIS IS A PLACEHOLDER, IT SHOULD SOLVE THE PUZZLE NOW.
	
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


generate_puzzle:
	li $t0, 9
	sw $t0, 16($s1)
	sw $t0, 100($s1)
	sw $t0, 168($s1)
	sw $t0, 228($s1)
	sw $t0, 288($s1)
	li $t0, 7
	sw $t0, 24($s1)
	sw $t0, 176($s1)
	sw $t0, 200($s1)
	sw $t0, 220($s1)
	sw $t0, 280($s1)
	sw $t0, 304($s1)
	li $t0, 5
	sw $t0, 32($s1)
	sw $t0, 92($s1)
	sw $t0, 172($s1)
	sw $t0, 224($s1)
	sw $t0, 268($s1)
	li $t0, 6
	sw $t0, 40($s1)
	sw $t0, 88($s1)
	sw $t0, 132($s1)
	sw $t0, 164($s1)
	sw $t0, 188($s1)
	li $t0, 3
	sw $t0, 52($s1)
	sw $t0, 96($s1)
	sw $t0, 120($s1)
	sw $t0, 144($s1)
	sw $t0, 236($s1)
	sw $t0, 256($s1)
	li $t0, 2
	sw $t0, 64($s1)
	sw $t0, 156($s1)
	sw $t0, 232($s1)
	li $t0, 4
	sw $t0, 76($s1)
	sw $t0, 244($s1)
	sw $t0, 296($s1)
	li $t0, 1
	sw $t0, 152($s1)
	sw $t0, 196($s1)
	li $t0, 8
	sw $t0, 84($s1)
	sw $t0, 124($s1)
	sw $t0, 148($s1)


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

	move	$s2, $s0
	jal		printboard		# Start by printing the input array (this may be redundant)
	
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

##	Registers:

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

#####################################
##	Function i_loop
##	Loops through i from 1 to 9.
##	
##	Registers:

######################################

i_loop:

	addi 	$a2, $a2, 1
	
	slt 	$s5, $a2, $t9 			# $t9 is 10, so if i < 10, $s5 is set to 1
	beq 	$s5, $zero, end_i_loop	# if $s5 is 0, then i = 10, and the loop is over.

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
	
	move	$t6, $a0
	la		$a0, Dot
	li		$v0, 4
	syscall
	move	$a0, $t6

	#move 	$t7, $a0
	#move 	$t8, $a1
	
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
	
	####!!! WHAT IS THIS?? ####
	# move 	$a0, $t7 # can put these two instructions here b/c if we dont reach this point, were exiting method so theyre not needed
	# move 	$a1, $t8
	#######	
	# dont see why it would be necessary to test if i == 10, as that seems evident at this point


end_i_loop:
	mult 	$a0, $t8		# $t8 is 9
	mflo 	$t2 
	add 	$t2, $t2, $a1
	sll 	$t2, $t2, 2
	add 	$t2, $s0, $t2 
	lw 		$s3, 0($t2)		# $s3 = output[x][y]
	
	mflo 	$t1 			# LO still has the product of $a0 and $t3, so we dont need to multiply again.
	add 	$t1, $t1, $a1
	sll 	$t1, $t1, 2
	add 	$t1, $s1, $t1 	
	lw 		$t1, 0($t1)		# $t1 = input[x][y]
	
	beq 	$t1, $s3, arrays_match
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
	#### !!!  WHATEVER HAPPENED TO RETURN 1?? ####
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
	#### !!!  WHATEVER HAPPENED TO RETURN 1?? ####


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
	move 	$t1, $zero # i = 0

i_x_less_3_y_less_3:
	move 	$t2, $zero # j = 0

j_x_less_3_y_less_3:
	mult 	$t1, $t5
	mflo 	$t3 # $t3 = i*9
	add 	$t3, $t3, $t2 # $t3 = i*9 + j
	sll 	$t3, $t3, 2 # $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3 # now $t3 contains address of outputArray[i][j]
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t0, j_x_less_3_y_less_3
	addi 	$t1, $t1, 1
	bne 	$t1, $t0, i_x_less_3_y_less_3
	move 	$v0, $a2 # want to return value
	jr 		$ra

x_less_3_y_3_to_5:
	slt 	$t1, $a1, $t4 # if y < 6, $t1 is set to 1
	beq 	$t1, $zero, x_less_3_y_6_to_8
	move 	$t1, $zero # i = 0

i_x_less_3_y_3_to_5:
	move 	$t2, $t0 # j = 3

j_x_less_3_y_3_to_5:
	mult 	$t1, $t5
	mflo 	$t3 # $t3 = i*9
	add 	$t3, $t3, $t2 # $t3 = i*9 + j
	sll 	$t3, $t3, 2 # $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t4, j_x_less_3_y_3_to_5
	addi 	$t1, $t1, 1
	bne 	$t1, $t0, i_x_less_3_y_3_to_5
	move 	$v0, $a2 # want to return value
	jr 		$ra

x_less_3_y_6_to_8:
	move 	$t1, $zero # i = 0

i_x_less_3_y_6_to_8:
	move 	$t2, $t4 # j = 6

j_x_less_3_y_6_to_8:
	mult 	$t1, $t5
	mflo 	$t3 # $t3 = i*9
	add 	$t3, $t3, $t2 # $t3 = i*9 + j
	sll 	$t3, $t3, 2 # $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t5, j_x_less_3_y_6_to_8
	addi 	$t1, $t1, 1
	bne 	$t1, $t0, i_x_less_3_y_6_to_8
	move 	$v0, $a2 # want to return value
	jr 		$ra

x_3_to_5:
	slt 	$t1, $a0, $t4 # else if x < 6, $t1 is set to 1
	beq 	$t1, $zero, x_6_to_8
	slt 	$t1, $a1, $t0 # if y < 3, $t1 is set to 1
	beq 	$t1, $zero, x_3_to_5_y_3_to_5
	move	$t1, $t0 # i = 3

i_x_3_to_5_y_less_3:
	move 	$t2, $zero # j = 0

j_x_3_to_5_y_less_3:
	mult 	$t1, $t5
	mflo 	$t3 # $t3 = i*9
	add 	$t3, $t3, $t2 # $t3 = i*9 + j
	sll 	$t3, $t3, 2 # $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3 # now $t3 contains address of outputArray[i][j]
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t0, j_x_3_to_5_y_less_3
	addi 	$t1, $t1, 1
	bne 	$t1, $t4, i_x_3_to_5_y_less_3
	move 	$v0, $a2 # want to return value
	jr 		$ra

x_3_to_5_y_3_to_5:
	slt 	$t1, $a1, $t4 # if y < 6, $t1 is set to 1
	beq 	$t1, $zero, x_3_to_5_y_6_to_8
	move 	$t1, $t0 # i = 3

i_x_3_to_5_y_3_to_5:
	move 	$t2, $t0 # j = 3

j_x_3_to_5_y_3_to_5:
	mult 	$t1, $t5
	mflo 	$t3 # $t3 = i*9
	add 	$t3, $t3, $t2 # $t3 = i*9 + j
	sll 	$t3, $t3, 2 # $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t4, j_x_3_to_5_y_3_to_5
	addi 	$t1, $t1, 1
	bne 	$t1, $t4, i_x_3_to_5_y_3_to_5
	move 	$v0, $a2 # want to return value
	jr 		$ra

x_3_to_5_y_6_to_8:
	move 	$t1, $t0 # i = 3

i_x_3_to_5_y_6_to_8:
	move 	$t2, $t4 # j = 6

j_x_3_to_5_y_6_to_8:
	mult 	$t1, $t5
	mflo 	$t3 # $t3 = i*9
	add 	$t3, $t3, $t2 # $t3 = i*9 + j
	sll 	$t3, $t3, 2 # $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t5, j_x_3_to_5_y_6_to_8
	addi 	$t1, $t1, 1
	bne 	$t1, $t4, i_x_3_to_5_y_6_to_8
	move 	$v0, $a2 # want to return value
	jr 		$ra

x_6_to_8:
	slt 	$t1, $a1, $t0 # if y < 3, $t1 is set to 1
	beq 	$t1, $zero, x_6_to_8_y_3_to_5
	move 	$t1, $t4 # i = 6

i_x_6_to_8_y_less_3:
	move 	$t2, $zero # j = 0

j_x_6_to_8_y_less_3:
	mult 	$t1, $t5
	mflo 	$t3 # $t3 = i*9
	add 	$t3, $t3, $t2 # $t3 = i*9 + j
	sll 	$t3, $t3, 2 # $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3 # now $t3 contains address of outputArray[i][j]
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t0, j_x_6_to_8_y_less_3
	addi 	$t1, $t1, 1
	bne 	$t1, $t5, i_x_6_to_8_y_less_3
	move 	$v0, $a2 # want to return value
	jr 		$ra

x_6_to_8_y_3_to_5:
	slt 	$t1, $a1, $t4 # if y < 6, $t1 is set to 1
	beq 	$t1, $zero, x_6_to_8_y_6_to_8
	move 	$t1, $t4 # i = 6

i_x_6_to_8_y_3_to_5:
	move 	$t2, $t0 # j = 3

j_x_6_to_8_y_3_to_5:
	mult 	$t1, $t5
	mflo 	$t3 # $t3 = i*9
	add 	$t3, $t3, $t2 # $t3 = i*9 + j
	sll 	$t3, $t3, 2 # $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t4, j_x_6_to_8_y_3_to_5
	addi 	$t1, $t1, 1
	bne 	$t1, $t5, i_x_6_to_8_y_3_to_5
	move 	$v0, $a2 # want to return value
	jr 		$ra

x_6_to_8_y_6_to_8:
	move 	$t1, $t4 # i = 6

i_x_6_to_8_y_6_to_8:
	move 	$t2, $t4 # j = 6

j_x_6_to_8_y_6_to_8:
	mult 	$t1, $t5
	mflo 	$t3 # $t3 = i*9
	add 	$t3, $t3, $t2 # $t3 = i*9 + j
	sll 	$t3, $t3, 2 # $t3 = (i*9 + j)*4
	add 	$t3, $s0, $t3
	lw 		$t3, 0($t3)
	beq 	$a2, $t3, set_to_zero
	addi 	$t2, $t2, 1
	bne 	$t2, $t5, j_x_6_to_8_y_6_to_8
	addi 	$t1, $t1, 1
	bne 	$t1, $t5, i_x_6_to_8_y_6_to_8
	move 	$v0, $a2 # want to return value
	jr 		$ra

set_to_zero:
	move 	$v0, $zero # return 0
	jr 		$ra
	
end:
	li		$v0, 10
	syscall
		
		
		
		
.data
Populating:	.asciiz "Populating output array"
Dot:		.asciiz "."
NoSolution:	.asciiz "This sudoku puzzle is unsolvable."
PromptNo:	.asciiz "\nEnter the value (0 for blank) to go in cell "
Semicolon:	.asciiz ": "
NewLine:	.asciiz "\n"
Space:		.asciiz " "
Invalid:	.asciiz "Invalid Input"
Underscore:	.asciiz "_"
First:		.asciiz "\nPlease choose an option:\n1:  Solve a Sudoku Puzzle\n2:  Generate a Sudoku Puzzle\nEnter choice:"
FirstPuzzle: 
	.word 1, 2, 3, 4, 5, 6, 7, 8, 9, 4, 5, 6, 7, 8, 9, 1, 2, 3, 7, 8, 9, 1, 2, 3, 4, 5, 6, 2, 3, 4, 5, 6, 7, 8, 9, 1, 5, 6, 7, 8, 9, 1, 2, 3, 4, 8, 9, 1, 2, 3, 4, 5, 6, 7, 3, 4, 5, 6, 7, 8, 9, 1, 2, 6, 7, 8, 9, 1, 2, 3, 4, 5, 9, 1, 2, 3, 4, 5, 6, 7, 8