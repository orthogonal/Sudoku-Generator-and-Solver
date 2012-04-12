main:
li $a0, 324 # allocate 81 words (9x9 array), so 324 bytes
li $v0, 9
syscall
move $s0, $v0 # $s0 is base address of outputArray

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