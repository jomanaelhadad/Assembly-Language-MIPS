# Write a program that adds three elements in an array together 
.data 
	array: .word 5, 10, 15 # initial numbers in my word ( 4 bytes ) 
.text 
main:
	# loading the address of array into a register 
	la $t4 , array 
	
	# loading the memory addresses of each value into different registers 
	lw $t0, 0($t4) # this means, t4 memory address + offset = new memory address, then take value inside and put it inside t0 register 
	lw $t1, 4($t4) # adding by 4 offset to point to the next memory address ( t1 = 10) 
	lw $t2, 8($t4) # adding by 4 offset to point to the next memory address ( t2 = 15 )
	
	# add the numbers in the array  
	add $t3, $t0, $t1 # adding the first 2 elements 
	add $t3, $t3, $t2 # overwrite $t3 and add in the last element t3 = 30 
	
	# printing integer so we need the a0 register 
	move $a0, $t3 
	li $v0, 1 
	syscall 
	
	# exist the program 
	li $v0, 10 
	syscall 