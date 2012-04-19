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
	li		$v0, 9		#9 is the syscall to allocate heap memory for an array.  Specify how many bytes to allocate in $a0.
	li		$a0, 324	#Allocate 324 bytes (81 words)
	syscall
	move	$s0, $v0	#So $s0 is the base address of the output array.
	
	li		$v0, 9
	li		$a0, 324
	syscall
	move	$s1, $v0	#So $s1 is the base address of the input array.
	
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
	
	#If the user did not put either 1 or 2, then what they put is invalid.  Ask them again.
	li		$v0, 4
	la		$a0, Invalid
	syscall
	j		first_choice
	
generate_puzzle:			#NULL, HERE FOR TESTING ONLY

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
##	
##	Registers:
##	$t0:  i, which is the index of the input array that is currently being modified.
##	$t1:  A pointer to the index of the input array currently being modified. 
##	$a0:  Used for constants in a variety of places.
######################################

define_puzzle:
	move	$t1, $s1	#$t1 loops through the input array in initialization.
	
	li		$t0, 0		#$t0 is i
	
	#Initialize all of $s1 to zero
allzerosstart:
	beq		$t0, 81, allzerosstop
	sw		$zero, ($t1)
	addi	$t0, 1
	addi	$t1, 4
	j allzerosstart
	
allzerosstop:				#Continue, now that everything is 0.
	
	li		$t0, 0
	move	$t1, $s0
	
	move	$s2, $s0
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
	
	move	$s2, $s0
	jal		printboard					#Print the board
	j 		initstart					#Loop back
	
invalidinput:
	li		$v0, 4						#Tell the user their input is invalid.
	la		$a0, Invalid
	syscall
	sw		$zero, ($t1)
	j initstart
	
initend:
	move	$s2, $s0
	jal		printboard
	j 		end							#THIS IS A PLACEHOLDER, IT SHOULD SOLVE THE PUZZLE NOW.
	
#####################################


#####################################
##	Function printboard
##	This takes $s2 as an argument.  $s2 must be a pointer to the puzzle to be printed.
##	The puzzle is output to the console.
##	To call this function, use the following syntax:
##		move	$s2, PointerToArray
##		jal		printboard
##	$t3 and $t4 are used.  They are usually constants.
##	Their constant values are returned to normal at the end of operation, so it is alright.
##	
##	Registers:
##	$s2:  A pointer to the start of the array.  Passed as an argument.
##	$t3:  i, which is the current index in the array.  Starts at 0, but it considers 
##				the array indices to be 1 through 81 for modular convenience.
##	$t4:  A pointer to various indices within the array.
##	$ra:  A pointer to the memory address of the point of execution before printboard was called.
######################################

printboard:
	li		$t3, 0					#$t3 is i
	move	$t4, $s2				#$t4 is the index of the array ($s2[i])
	
printstart:
	beq		$t3, 81, printend		#while (i < 81)
	
	lw		$a0, ($t4)				#Get $s2[i] ($t4 holds the index in memory that the value will be at)
	beq		$a0, $zero, printspace	#If it is 0 print a space, if it is not then just continue and print it.
	li		$v0, 1
	syscall
	j 		notzero					#Skip all the printing-a-space stuff since it is not a space.

printspace:
	li		$v0, 4
	la		$a0, Underscore
	syscall							#Print the space

notzero:	
	addi	$t3, $t3, 1				#i++
	addi	$t4, $t4, 4				#Increment the array pointer
	
	li		$v0, 4
	la		$a0, Space
	syscall							#Output a space (between the numbers)
	
	li		$a0, 3					#This checks if i = 0 mod 3, and if it is then it outputs another space.
	div		$t3, $a0				#This way there is a bigger space between the blocks of the table.
	mfhi	$a0
	bne		$a0, $zero, stopspaces	#If i != 0 mod 3, it will be != 0 mod 9 and 0 mod 27 as well, so skip the next few steps.
	li		$v0, 4
	la		$a0, Space
	syscall
	
	li		$a0, 9					#This checks if i = 0 mod 9, and if it is, then it outputs a new line.
	div		$t3, $a0				
	mfhi	$a0
	bne		$a0, $zero, stopspaces
	li		$v0, 4
	la		$a0, NewLine
	syscall
	
	li		$a0, 27					#This checks if i = 0 mod 27, and if it is, then it outputs another new line.
	div		$t3, $a0				#This way, there is a blank line between sets of blocks (vertically).
	mfhi	$a0
	bne		$a0, $zero, stopspaces
	li		$v0, 4
	la		$a0, NewLine
	syscall
	
stopspaces:
	j 		printstart				#Loop back around.

printend:
	li		$t3, 9
	li		$t4, 1
	jr		$ra						#Return (this is a void function).
	
########################################
	
#	int backtrack(int x, int y) {
#	int temp,i,j;
#	if (outputArray[x][y] == 0) {
#		for (i = 1; i < 10; i++) {
#			temp = input_value(x,y,i);
#			if (temp > 0) {
#				outputArray[x][y] = temp;
#				if (x == 8 && y == 8) {
#					return 1;
#				} else if (x == 8) {
#					if (backtrack(0,y+1)) return 1;
#				} else {
#					if (backtrack(x+1,y)) return 1 ;
#				}
#			}
#		}
#		if (i == 10) {
#			if (outputArray[x][y] != array[x][y]) outputArray[x][y] = 0;
#			return 0;
#		}
#	} else {
#		if (x == 8 && y == 8) {
#			return 1;
#		} else if (x == 8) {
#			if (backtrack(0,y+1)) return 1;
#		} else {
#			if (backtrack(x+1,y)) return 1;
#		}
#	}
#}


################
##   Function backtrack
##   Takes two integers, x and y, as parameters.  They represent a box on the sudoku puzzle, from (0, 0) to (8, 8).
##   Returns an integer.
##   First, there are three temporary variables.
##
##	 If (x, y) in the output array is 0, then do the following:
##	 input_value is a function that checks to see if "i" is valid in box (x, y).  
##	 If it is valid, then "i" is returned.
##	 If it is invalid, then 0 is returned.
##	 If "i" is a valid value for box (x, y), then it is set to that value in the output array.
##	 If (x, y) = (8, 8), that is, if it is the last box in the array, then return 1.
##	 Otherwise, check the next square in order by recursively calling backtrack.
##	 If it exhausts all possible values of "i" to go in that square (that is, if i = 10), then it sets the outputArray to 0 and returns 0.
##	 
##	 Otherwise:
##	 If it is the last box in the array, return 1.
##   Otherwise, recursively call the next backtrack, and then return 1.
#####
##	 $t3, $t4, $t5, and $t6 are constants.
##	 $a0 is x
##	 $a1 is y

backtrack:

#We need some constants, so define all of these.
	li		$t3, 9
	li		$t4, 1
	li		$t5, 8
	li		$t6, 10
	
#Get outputArray[x][y]
	mult	$a0, $t3
	mflo	$t2				#$t2 = 9 * x
	add		$t2, $t2, $a1	#$t2 = 9x + y
	sll		$t2, $t2, 2		#$t2 = 4 * (9x + y)
	add		$t2, $s0, $t2	#$t2 now contains the address of outputArray[x][y]
	
	lw		$t2, 0($t2)		#Get the value outputArray[x][y]

#If (outputArray[x][y] = 0)	
	bne		$t2, $zero, arr_not_zero
	addi	$a2, $zero, 1				#i = 1
	
i_loop:
	addi	$a2, $a2, 1					#i++

	#===================================
	#==  function call:  input_value  ==
	#===================================
		
	addi	$sp, $sp, -44
	
	sw 		$ra, 40($sp)
	sw 		$a2, 36($sp)
	sw 		$a1, 32($sp)
	sw 		$a0, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)

	jal 	input_value

	lw 		$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$a0, 28($sp)
	lw 		$a1, 32($sp)
	lw 		$a2, 36($sp)
	lw 		$ra, 40($sp)
	
	addi	$sp, $sp, 44
	
	#=======================================
	
	move	$t0, $v0				#input_value returns to $v0, so move that to $t0
	slt		$t1, $zero, $t0			#if the return value is zero, then go back to i_loop and set $t1 = 1.  Otherwise, $t1 = 0.
	beq		$t1, $zero, i_loop
	
	mflo	$t2						#The low register should still have 9x in it, so $t2 = 9x.
	add		$t2, $t2, $a1			#$t2 = 9x + y
	sll		$t2, $t2, 2				#$t2 = 4 * (9x + y)
	add		$t2, $s0, $t2			#$t2 has the address of outputArray[x][y]
	
	sw		$t0, 0($t2)				#outputArray[x][y] = the return from input_value.
	
	move	$t7, $a0
	move	$t8, $a1
	
	bne		$a0, $t5, output_zero_else		# $t5 is 8.  If x != 8, then (x == 8 && y == 8) can not be true, from De Morgans Law.
	bne		$a1, $t5, output_zero_else_if	# Same as above.  
	
	li		$v0, 1
	jr		$ra
	
	
output_zero_else_if:
	move	$a0, $zero		#x = 0
	addi	$a1, $a1, 1		#y = y + 1
	
	#===================================
	#==  function call:  backtrack    ==
	#===================================
	
	addi 	$sp, $sp, -44
	
	sw 		$ra, 40($sp)
	sw 		$a2, 36($sp)
	sw 		$a1, 32($sp)
	sw 		$a0, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)
	
	jal 	backtrack
	
	lw 		$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$a0, 28($sp)
	lw 		$a1, 32($sp)
	lw 		$a2, 36($sp)
	lw 		$ra, 40($sp)
	
	addi 	$sp, $sp, 44
	
	#=======================================
	
	beq		$v0, $zero, i_loop
	jr		$ra
	
	
output_zero_else:
	addi $a0, $a0, 1 # x = x+1 for function call
	
	#===================================
	#==  function call:  backtrack    ==
	#===================================

	addi 	$sp, $sp, -44

	sw 		$ra, 40($sp)
	sw 		$a2, 36($sp)
	sw 		$a1, 32($sp)
	sw 		$a0, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)

	jal 	backtrack

	lw 		$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$a0, 28($sp)
	lw 		$a1, 32($sp)
	lw 		$a2, 36($sp)
	lw 		$ra, 40($sp)
	
	addi 	$sp, $sp, 44
	
	#====================================

	beq 	$v0, $zero, i_loop
	jr 		$ra
	
	move	$a0, $t7			#If this point is reached, the method is exiting.
	move	$a1, $t8
	bne		$a2, $t6, i_loop
	
	lw		$t2, 0($t2)				#$t2 is still the address of outputArray[x][y], so now $t2 is the value there.
	
	mult	$a0, $t3
	mflo	$t1
	add		$t1, $t1, $a1
	sll		$t1, $t1, 2
	add		$t1, $s1, $t1			#So now $t1 is the address of inputArray[x][y]	
	lw		$t1, 0($t1)				#And now it is the value at that address.
	
	beq		$t1, $t2, arrays_match
	sw		$zero, 0($t2)			#outputArray[x][y] = 0
	

arrays_match:
	move	$v0, $zero
	jr		$ra
	

arr_not_zero:
	bne 	$a0, $t5, output_not_zero_else 		# Using DeMorgans Law, these two lines test if !(x == 8 && y == 8)
	bne 	$a1, $t5, output_not_zero_else_if 	
	
	li 		$v0, 1
	jr 		$ra
	
output_not_zero_else_if:
	move 	$a0, $zero 		# x = 0 for function call
	addi 	$a1, $a1, 1 		# y = y+1 for function call

	#===================================
	#==  function call:  backtrack    ==
	#===================================

	addi 	$sp, $sp, -44

	sw 		$ra, 40($sp)
	sw 		$a2, 36($sp)
	sw 		$a1, 32($sp)
	sw 		$a0, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)

	jal 	backtrack

	lw 		$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$a0, 28($sp)
	lw 		$a1, 32($sp)
	lw 		$a2, 36($sp)
	lw 		$ra, 40($sp)

	addi 	$sp, $sp, 44
	
	#====================================
	
	jr 		$ra 		# if $v0 == 0, I think we need to return 0, based on what I read at http://stackoverflow.com/questions/1610030/why-can-you-return-from-a-non-void-function-without-returning-a-value-without-pr


output_not_zero_else:
	addi 	$a0, $a0, 1 # x = x+1 for function call

	#===================================
	#==  function call:  backtrack    ==
	#===================================
	
	addi 	$sp, $sp, -44

	sw 		$ra, 40($sp)
	sw 		$a2, 36($sp)
	sw 		$a1, 32($sp)
	sw 		$a0, 28($sp)
	sw 		$t6, 24($sp)
	sw 		$t5, 20($sp)
	sw 		$t4, 16($sp)
	sw 		$t3, 12($sp)
	sw 		$t2, 8($sp)
	sw 		$t1, 4($sp)
	sw 		$t0, 0($sp)

	jal		backtrack

	lw 		$t0, 0($sp)
	lw 		$t1, 4($sp)
	lw 		$t2, 8($sp)
	lw 		$t3, 12($sp)
	lw 		$t4, 16($sp)
	lw 		$t5, 20($sp)
	lw 		$t6, 24($sp)
	lw 		$a0, 28($sp)
	lw 		$a1, 32($sp)
	lw 		$a2, 36($sp)
	lw 		$ra, 40($sp)

	addi 	$sp, $sp, 44

	#====================================
	
	jr 		$ra


input_value:
	li 		$t0, 9
	move 	$t1, $zero # i = 0

horiz_and_vert:
	mult 	$t1, $t0
	mflo	$t2 					# $t2 = i*9
	add 	$t2, $t2, $a1 			# $t2 = i*9 + y
	sll 	$t2, $t2, 2 			# $t2 = (i*9 + y)*4
	add 	$t2, $s0, $t2 			# now $t2 contains address of outputArray[i][y]
	lw 		$t2, 0($t2)
	beq 	$a2, $t2, set_to_zero 	# checking whether value == outputArray[i][y]
	mult 	$a0, $t0
	mflo 	$t2 					# $t2 = x*9
	add 	$t2, $t2, $t1 			# $t2 = x*9 + i
	sll 	$t2, $t2, 2 			# $t2 = (x*9 + i)*4
	add 	$t2, $s0, $t2 				# now $t2 contains address of outputArray[x][i]
	lw 		$t2, 0($t2)
	beq 	$a2, $t2, set_to_zero 		# checking whether value == outputArray[x][i]
	addi 	$t1, $t1, 1
	bne 	$t1, $t0, horiz_and_vert

	li 		$t0, 3
	slt 	$t1, $a0, $t0 # if x < 3, $t1 is set to 1
	li 		$t5, 9
	beq 	$t1, $zero, x_3_to_5
	slt 	$t1, $a1, $t0 # if y < 3, $t1 is set to 1
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

x_less_3_y_3_to_5:
	li 		$t4, 6
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
	j 		input_value_ret

x_3_to_5:
	slt 	$t1, $a0, $t4 # else if x < 6, $t1 is set to 1
	beq 	$t1, $zero, x_6_to_8
	slt 	$t1, $a1, $t0 # if y < 3, $t1 is set to 1
	beq 	$t1, $zero, x_3_to_5_y_3_to_5
	move 	$t1, $t0 # i = 3

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
	j 		input_value_ret

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
	bne		$t2, $t4, j_x_6_to_8_y_3_to_5
	addi 	$t1, $t1, 1
	bne 	$t1, $t5, i_x_6_to_8_y_3_to_5

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
	j 	input_value_ret

set_to_zero:
	move 	$v0, $zero # return 0
	jr 		$ra

input_value_ret:
	move 	$v0, $a2 # return value
	jr 		$ra
	
	
end:
	li		$v0, 10
	syscall
		
		
		
		
.data
PromptNo:	.asciiz "\nEnter the value (0 for blank) to go in cell "
Semicolon:	.asciiz ": "
NewLine:	.asciiz "\n"
Space:		.asciiz " "
Invalid:	.asciiz "Invalid Input"
Underscore:	.asciiz "_"
First:		.asciiz "\nPlease choose an option:\n1:  Solve a Sudoku Puzzle\n2:  Generate a Sudoku Puzzle\nEnter choice:"