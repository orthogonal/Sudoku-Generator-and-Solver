main:
li $a0, 324 # allocate 81 words (9x9 array), so 324 bytes
li $v0, 9
syscall
move $s0, $v0 # $s0 is base address of outputArray
li $a0, 324
li $v0, 9
syscall
move $s1, $v0 # $s1 is base address of array

# $t0 = temp, $t1 = result of temp calculation (orig. j, but that's not used), $t2 = bunch of stuff in forming outputArray[x][y]
# $t3 = 9, $t4 = 1, $t5 = 8, $t6 = 10
# $a0 = x, $a1 = y, $a2 = i
# $t7 = temporarily used to store value of x upon function call, $t8 = temporarily used to store value of y upon function call
backtrack:
li $t3, 9
li $t4, 1
li $t5, 8
li $t6, 10
mult $a0, $t3
mflo $t2 # $t2 = x*9
add $t2, $t2, $a1 # $t2 = x*9 + y
sll $t2, $t2, 2 # $t2 = (x*9 + y)*4
add $t2, $s0, $t2 # now $t2 contains address of outputArray[x][y]
lw $t2, 0($t2)
bne $t2, $zero, arr_not_zero # skip to else after if(outputArray[x][y] == 0)
addi $a2, $zero, 1 # i = 1
i_loop:
addi $a2, $a2, 1
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
mflo $t2 # $t2 = x*9 (this should still be in lo register w/o needing another multiply)
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
move $a0, $zero # x = 0 for function call
addi $a1, $a1, 1 # y = y+1 for function call
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
addi $a0, $a0, 1 # x = x+1 for function call
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
bne $a2, $t6, i_loop
# don't see why it would be necessary to test if i == 10, as that seems evident at this point
lw $t2, 0($t2) # $t2 should still be address of outputArray[x][y], so just load it
mult $a0, $t3
mflo $t1
add $t1, $t1, $a1
sll $t1, $t1, 2
add $t1, $s1, $t1 # now $t1 contains address of array[x][y]
lw $t1, 0($t1)
beq $t1, $t2, arrays_match
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
move $a0, $zero # x = 0 for function call
addi $a1, $a1, 1 # y = y+1 for function call
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
addi $a0, $a0, 1 # x = x+1 for function call
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
x_less_3_y_3_to_5:
li $t4, 6
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
j input_value_ret

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
j input_value_ret

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
j input_value_ret

set_to_zero:
move $v0, $zero # return 0
jr $ra

input_value_ret:
move $v0, $a2 # return value
jr $ra