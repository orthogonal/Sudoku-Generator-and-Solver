.data
space:	.asciiz	" "
newline:	.asciiz	"\n"
no_soln:	.asciiz "No Soln"

.text
.globl main

main:
li $a0, 324 # allocate 81 words (9x9 array), so 324 bytes
li $v0, 9
syscall
move $s0, $v0 # $s0 is base address of outputArray
li $a0, 324
li $v0, 9
syscall
move $s1, $v0 # $s1 is base address of array
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
move $t0, $s1
move $t1, $s0
li $t2, 324
add $t2, $t2, $s1
populate_output_array:
lw $t3, 0($t0)
sw $t3, 0($t1)
addi $t0, $t0, 4
addi $t1, $t1, 4
bne $t0, $t2, populate_output_array
move $t0, $s1
li $t4, 36
li $t5, 0
print_orig_array:
lw $a0, 0($t0)
li $v0, 1
syscall
la $a0, space
li $v0, 4
syscall
addi $t0, $t0, 4
addi $t5, $t5, 4
div $t5, $t4
mfhi $t6
bne $t6, $zero, test_print_orig
la $a0, newline
li $v0, 4
syscall
test_print_orig:
bne $t0, $t2, print_orig_array
li $a0, 0 # preparing to call backtrack(0,0)
li $a1, 0 # see previous line
addi $sp, $sp, -8
sw $a0, 4($sp)
sw $a1, 0($sp)
jal backtrack
lw $a1, 0($sp)
lw $a0, 4($sp)
addi $sp, $sp, 8
beq $v0, $zero, print_no_soln
la $a0, newline
li $v0, 4
syscall
move $t0, $s0
move $t9, $zero
li $t4, 36
li $t2, 324
print_solved_array:
lw $a0, 0($t0)
li $v0, 1
syscall
la $a0, space
li $v0, 4
syscall
addi $t0, $t0, 4
addi $t9, $t9, 4
div $t9, $t4
mfhi $t5
bne $t5, $zero, no_print_newline
la $a0, newline
li $v0, 4
syscall
no_print_newline:
bne $t9, $t2, print_solved_array
j end
print_no_soln:
la $a0, no_soln
li $v0, 4
syscall
j end

# $t0 = temp, $t1 = result of temp calculation (orig. j, but that's not used), $t2 = bunch of stuff in forming outputArray[x][y]
# $t3 = 9, $t4 = 1, $t5 = 8, $t9 = 10 (changed $t6 to use for something else below)
# $a0 = x, $a1 = y, $a2 = i
# $t7 = temporarily used to store value of x upon function call, $t8 = temporarily used to store value of y upon function call
backtrack:
li $t3, 9
li $t4, 1
li $t5, 8
li $t7, 10
mult $a0, $t3
mflo $t2 # $t2 = x*9
add $t2, $t2, $a1 # $t2 = x*9 + y
sll $t2, $t2, 2 # $t2 = (x*9 + y)*4
add $t2, $s0, $t2 # now $t2 contains address of outputArray[x][y]
lw $t2, 0($t2)
bne $t2, $zero, arr_not_zero # skip to else after if(outputArray[x][y] == 0)
move $a2, $zero # i = 0 (will be changed to 1, which is its actual initial value, right after entering i_loop)
li $t9, 10
i_loop:
addi $a2, $a2, 1
slt $s5, $a2, $t9 # if i < 10, $s5 is set to 1
beq $s5, $zero, end_i_loop
addi $sp, $sp, -44
sw $ra, 40($sp)
sw $a2, 36($sp)
sw $a1, 32($sp)
sw $a0, 28($sp)
sw $t6, 24($sp)
sw $t5, 20($sp)
sw $t4, 16($sp)
sw $t3, 12($sp)
sw $t2, 8($sp)
sw $t1, 4($sp)
sw $t0, 0($sp)
jal input_value
lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
lw $t5, 20($sp)
lw $t6, 24($sp)
lw $a0, 28($sp)
lw $a1, 32($sp)
lw $a2, 36($sp)
lw $ra, 40($sp)
addi $sp, $sp, 44
move $t0, $v0 # move value returned from input_value to temp
slt $t1, $zero, $t0 # if 0 < temp (i.e., temp > 0), $t1 = 1; otherwise, $t1 = 0
beq $t1, $zero, i_loop
mult $a0, $t3
mflo $t2 # $t2 = x*9
add $t2, $t2, $a1 # $t2 = x*9 + y
sll $t2, $t2, 2 # $t2 = (x*9 + y)*4
add $t2, $s0, $t2 # now $t2 contains address of outputArray[x][y]
sw $t0, 0($t2) # store temp in outputArray[x][y] (outputArray[x][y] = temp)

move $t7, $a0
move $t8, $a1
bne $a0, $t5, output_zero_else # if x != 8, can't be true that x == 8 && y == 8 (also don't need to test it twice)
bne $a1, $t5, output_zero_else_if # same for y != 8; using deMorgan's law b/c !(x == 8 && y == 8) is same as x != 8 || y != 8
li $v0, 1
jr $ra
output_zero_else_if:
# call function
addi $sp, $sp, -44
sw $ra, 40($sp)
sw $a2, 36($sp)
sw $a1, 32($sp)
sw $a0, 28($sp)
sw $t6, 24($sp)
sw $t5, 20($sp)
sw $t4, 16($sp)
sw $t3, 12($sp)
sw $t2, 8($sp)
sw $t1, 4($sp)
sw $t0, 0($sp)
move $a0, $zero # x = 0 for function call (not really changing x in this call, which is why this is placed after $a0 is still in memory)
addi $a1, $a1, 1 # y = y+1 for function call (see above)
jal backtrack
lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
lw $t5, 20($sp)
lw $t6, 24($sp)
lw $a0, 28($sp)
lw $a1, 32($sp)
lw $a2, 36($sp)
lw $ra, 40($sp)
addi $sp, $sp, 44
beq $v0, $zero, i_loop
jr $ra # if $v0 != 0, then it's 1 so it already contains what we need to return
output_zero_else:
# call function
addi $sp, $sp, -44
sw $ra, 40($sp)
sw $a2, 36($sp)
sw $a1, 32($sp)
sw $a0, 28($sp)
sw $t6, 24($sp)
sw $t5, 20($sp)
sw $t4, 16($sp)
sw $t3, 12($sp)
sw $t2, 8($sp)
sw $t1, 4($sp)
sw $t0, 0($sp)
addi $a0, $a0, 1 # x = x+1 for function call (again, not actually changing x)
jal backtrack
lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
lw $t5, 20($sp)
lw $t6, 24($sp)
lw $a0, 28($sp)
lw $a1, 32($sp)
lw $a2, 36($sp)
lw $ra, 40($sp)
addi $sp, $sp, 44
beq $v0, $zero, i_loop
jr $ra
move $a0, $t7 # can put these two instructions here b/c if we don't reach this point, we're exiting method so they're not needed
move $a1, $t8
# don't see why it would be necessary to test if i == 10, as that seems evident at this point

end_i_loop:
mult $a0, $t3
mflo $t2 # $t2 = x*9
add $t2, $t2, $a1 # $t2 = x*9 + y
sll $t2, $t2, 2 # $t2 = (x*9 + y)*4
add $t2, $s0, $t2 # now $t2 contains address of outputArray[x][y]
lw $s3, 0($t2)
mflo $t1 # still using product of $a0 and $t3, so don't need to multiply again
add $t1, $t1, $a1
sll $t1, $t1, 2
add $t1, $s1, $t1 # now $t1 contains address of array[x][y]
lw $t1, 0($t1)
beq $t1, $s3, arrays_match
sw $zero, 0($t2) # outputArray[x][y] = 0
arrays_match:
move $v0, $zero
jr $ra

arr_not_zero:
# don't need to save x and y here b/c must return once this else branch is entered
bne $a0, $t5, output_not_zero_else # if x != 8, can't be true that x == 8 && y == 8 (also don't need to test it twice)
bne $a1, $t5, output_not_zero_else_if # same for y != 8; using deMorgan's law b/c !(x == 8 && y == 8) is same as x != 8 || y != 8
li $v0, 1
jr $ra
output_not_zero_else_if:
# call function
addi $sp, $sp, -44
sw $ra, 40($sp)
sw $a2, 36($sp)
sw $a1, 32($sp)
sw $a0, 28($sp)
sw $t6, 24($sp)
sw $t5, 20($sp)
sw $t4, 16($sp)
sw $t3, 12($sp)
sw $t2, 8($sp)
sw $t1, 4($sp)
sw $t0, 0($sp)
move $a0, $zero # x = 0 for function call (not really changing x in this call, which is why this is placed after $a0 is still in memory)
addi $a1, $a1, 1 # y = y+1 for function call (see above)
jal backtrack
lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
lw $t5, 20($sp)
lw $t6, 24($sp)
lw $a0, 28($sp)
lw $a1, 32($sp)
lw $a2, 36($sp)
lw $ra, 40($sp)
addi $sp, $sp, 44
jr $ra # if $v0 == 0, I think we need to return 0, based on what I read at http://stackoverflow.com/questions/1610030/why-can-you-return-from-a-non-void-function-without-returning-a-value-without-pr
output_not_zero_else:
# call function
addi $sp, $sp, -44
sw $ra, 40($sp)
sw $a2, 36($sp)
sw $a1, 32($sp)
sw $a0, 28($sp)
sw $t6, 24($sp)
sw $t5, 20($sp)
sw $t4, 16($sp)
sw $t3, 12($sp)
sw $t2, 8($sp)
sw $t1, 4($sp)
sw $t0, 0($sp)
addi $a0, $a0, 1 # x = x+1 for function call (again, not actually changing x)
jal backtrack
lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $t4, 16($sp)
lw $t5, 20($sp)
lw $t6, 24($sp)
lw $a0, 28($sp)
lw $a1, 32($sp)
lw $a2, 36($sp)
lw $ra, 40($sp)
addi $sp, $sp, 44
jr $ra


input_value:
li $t0, 9
li $t4, 6
move $t1, $zero # i = 0
horiz_and_vert:
mult $t1, $t0
mflo $t2 # $t2 = i*9
add $t2, $t2, $a1 # $t2 = i*9 + y
sll $t2, $t2, 2 # $t2 = (i*9 + y)*4
add $t2, $s0, $t2 # now $t2 contains address of outputArray[i][y]
lw $t2, 0($t2)
beq $a2, $t2, set_to_zero # checking whether value == outputArray[i][y]
mult $a0, $t0
mflo $t2 # $t2 = x*9
add $t2, $t2, $t1 # $t2 = x*9 + i
sll $t2, $t2, 2 # $t2 = (x*9 + i)*4
add $t2, $s0, $t2 # now $t2 contains address of outputArray[x][i]
lw $t2, 0($t2)
beq $a2, $t2, set_to_zero # checking whether value == outputArray[x][i]
addi $t1, $t1, 1
bne $t1, $t0, horiz_and_vert

li $t0, 3
slt $t1, $a0, $t0 # if x < 3, $t1 is set to 1
li $t5, 9
beq $t1, $zero, x_3_to_5
slt $t1, $a1, $t0 # if y < 3, $t1 is set to 1
beq $t1, $zero, x_less_3_y_3_to_5
move $t1, $zero # i = 0
i_x_less_3_y_less_3:
move $t2, $zero # j = 0
j_x_less_3_y_less_3:
mult $t1, $t5
mflo $t3 # $t3 = i*9
add $t3, $t3, $t2 # $t3 = i*9 + j
sll $t3, $t3, 2 # $t3 = (i*9 + j)*4
add $t3, $s0, $t3 # now $t3 contains address of outputArray[i][j]
lw $t3, 0($t3)
beq $a2, $t3, set_to_zero
addi $t2, $t2, 1
bne $t2, $t0, j_x_less_3_y_less_3
addi $t1, $t1, 1
bne $t1, $t0, i_x_less_3_y_less_3
move $v0, $a2 # want to return value
jr $ra
x_less_3_y_3_to_5:
slt $t1, $a1, $t4 # if y < 6, $t1 is set to 1
beq $t1, $zero, x_less_3_y_6_to_8
move $t1, $zero # i = 0
i_x_less_3_y_3_to_5:
move $t2, $t0 # j = 3
j_x_less_3_y_3_to_5:
mult $t1, $t5
mflo $t3 # $t3 = i*9
add $t3, $t3, $t2 # $t3 = i*9 + j
sll $t3, $t3, 2 # $t3 = (i*9 + j)*4
add $t3, $s0, $t3
lw $t3, 0($t3)
beq $a2, $t3, set_to_zero
addi $t2, $t2, 1
bne $t2, $t4, j_x_less_3_y_3_to_5
addi $t1, $t1, 1
bne $t1, $t0, i_x_less_3_y_3_to_5
move $v0, $a2 # want to return value
jr $ra
x_less_3_y_6_to_8:
move $t1, $zero # i = 0
i_x_less_3_y_6_to_8:
move $t2, $t4 # j = 6
j_x_less_3_y_6_to_8:
mult $t1, $t5
mflo $t3 # $t3 = i*9
add $t3, $t3, $t2 # $t3 = i*9 + j
sll $t3, $t3, 2 # $t3 = (i*9 + j)*4
add $t3, $s0, $t3
lw $t3, 0($t3)
beq $a2, $t3, set_to_zero
addi $t2, $t2, 1
bne $t2, $t5, j_x_less_3_y_6_to_8
addi $t1, $t1, 1
bne $t1, $t0, i_x_less_3_y_6_to_8
move $v0, $a2 # want to return value
jr $ra
x_3_to_5:
slt $t1, $a0, $t4 # else if x < 6, $t1 is set to 1
beq $t1, $zero, x_6_to_8
slt $t1, $a1, $t0 # if y < 3, $t1 is set to 1
beq $t1, $zero, x_3_to_5_y_3_to_5
move $t1, $t0 # i = 3
i_x_3_to_5_y_less_3:
move $t2, $zero # j = 0
j_x_3_to_5_y_less_3:
mult $t1, $t5
mflo $t3 # $t3 = i*9
add $t3, $t3, $t2 # $t3 = i*9 + j
sll $t3, $t3, 2 # $t3 = (i*9 + j)*4
add $t3, $s0, $t3 # now $t3 contains address of outputArray[i][j]
lw $t3, 0($t3)
beq $a2, $t3, set_to_zero
addi $t2, $t2, 1
bne $t2, $t0, j_x_3_to_5_y_less_3
addi $t1, $t1, 1
bne $t1, $t4, i_x_3_to_5_y_less_3
move $v0, $a2 # want to return value
jr $ra
x_3_to_5_y_3_to_5:
slt $t1, $a1, $t4 # if y < 6, $t1 is set to 1
beq $t1, $zero, x_3_to_5_y_6_to_8
move $t1, $t0 # i = 3
i_x_3_to_5_y_3_to_5:
move $t2, $t0 # j = 3
j_x_3_to_5_y_3_to_5:
mult $t1, $t5
mflo $t3 # $t3 = i*9
add $t3, $t3, $t2 # $t3 = i*9 + j
sll $t3, $t3, 2 # $t3 = (i*9 + j)*4
add $t3, $s0, $t3
lw $t3, 0($t3)
beq $a2, $t3, set_to_zero
addi $t2, $t2, 1
bne $t2, $t4, j_x_3_to_5_y_3_to_5
addi $t1, $t1, 1
bne $t1, $t4, i_x_3_to_5_y_3_to_5
move $v0, $a2 # want to return value
jr $ra
x_3_to_5_y_6_to_8:
move $t1, $t0 # i = 3
i_x_3_to_5_y_6_to_8:
move $t2, $t4 # j = 6
j_x_3_to_5_y_6_to_8:
mult $t1, $t5
mflo $t3 # $t3 = i*9
add $t3, $t3, $t2 # $t3 = i*9 + j
sll $t3, $t3, 2 # $t3 = (i*9 + j)*4
add $t3, $s0, $t3
lw $t3, 0($t3)
beq $a2, $t3, set_to_zero
addi $t2, $t2, 1
bne $t2, $t5, j_x_3_to_5_y_6_to_8
addi $t1, $t1, 1
bne $t1, $t4, i_x_3_to_5_y_6_to_8
move $v0, $a2 # want to return value
jr $ra
x_6_to_8:
slt $t1, $a1, $t0 # if y < 3, $t1 is set to 1
beq $t1, $zero, x_6_to_8_y_3_to_5
move $t1, $t4 # i = 6
i_x_6_to_8_y_less_3:
move $t2, $zero # j = 0
j_x_6_to_8_y_less_3:
mult $t1, $t5
mflo $t3 # $t3 = i*9
add $t3, $t3, $t2 # $t3 = i*9 + j
sll $t3, $t3, 2 # $t3 = (i*9 + j)*4
add $t3, $s0, $t3 # now $t3 contains address of outputArray[i][j]
lw $t3, 0($t3)
beq $a2, $t3, set_to_zero
addi $t2, $t2, 1
bne $t2, $t0, j_x_6_to_8_y_less_3
addi $t1, $t1, 1
bne $t1, $t5, i_x_6_to_8_y_less_3
move $v0, $a2 # want to return value
jr $ra
x_6_to_8_y_3_to_5:
slt $t1, $a1, $t4 # if y < 6, $t1 is set to 1
beq $t1, $zero, x_6_to_8_y_6_to_8
move $t1, $t4 # i = 6
i_x_6_to_8_y_3_to_5:
move $t2, $t0 # j = 3
j_x_6_to_8_y_3_to_5:
mult $t1, $t5
mflo $t3 # $t3 = i*9
add $t3, $t3, $t2 # $t3 = i*9 + j
sll $t3, $t3, 2 # $t3 = (i*9 + j)*4
add $t3, $s0, $t3
lw $t3, 0($t3)
beq $a2, $t3, set_to_zero
addi $t2, $t2, 1
bne $t2, $t4, j_x_6_to_8_y_3_to_5
addi $t1, $t1, 1
bne $t1, $t5, i_x_6_to_8_y_3_to_5
move $v0, $a2 # want to return value
jr $ra
x_6_to_8_y_6_to_8:
move $t1, $t4 # i = 6
i_x_6_to_8_y_6_to_8:
move $t2, $t4 # j = 6
j_x_6_to_8_y_6_to_8:
mult $t1, $t5
mflo $t3 # $t3 = i*9
add $t3, $t3, $t2 # $t3 = i*9 + j
sll $t3, $t3, 2 # $t3 = (i*9 + j)*4
add $t3, $s0, $t3
lw $t3, 0($t3)
beq $a2, $t3, set_to_zero
addi $t2, $t2, 1
bne $t2, $t5, j_x_6_to_8_y_6_to_8
addi $t1, $t1, 1
bne $t1, $t5, i_x_6_to_8_y_6_to_8
move $v0, $a2 # want to return value
jr $ra

set_to_zero:
move $v0, $zero # return 0
jr $ra

end:
la $a0, newline
li $v0, 4
syscall