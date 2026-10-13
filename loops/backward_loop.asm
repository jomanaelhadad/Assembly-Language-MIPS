# printing a loop backwards 
.data 
	newline: .asciiz"\n"
.text 
	li $t0, 10 
	li $t1, 0 

loop:
	blt $t0, $t1, end 
	
	li $v0, 1
	move $a0, $t0
	syscall 
	
	li $v0, 4
	la $a0, newline 
	syscall 
	
	addi $t0, $t0, -1
	
	b loop 

end:
	li $v0, 10
	syscall 