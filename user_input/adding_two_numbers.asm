# Propmt the user to ask for 2 numbers 
.data
	prompt1: .asciiz "Enter the first digit\n:"
	input: .space 5
	output: .asciiz"Your digit is: "
	inputSize: .word 4
	result: .word 0 
	
.text 

.global main 
	# printing prompt1 to the screen
	li $v0, 4      # print()
	la $a0, prompt1 
	syscall 
	
	# reading the string 
	li $v0, 8 # syscall for reading and printing an string the string
	la $a0, input 
	lw $a1, inputSize 
	syscall 
	
	# output the string 
	li $v0, 4
	la $a0, output 
	syscall
	
	# Convet ASCII to integer 
	lb $t0, input 
	addi $t0, $t0, -48
	
	# second digit 
	lb $t1, input+1 
	addi $t1, $t1, -48 
	
	# combine the digits 
	li $t2, 10
	mul $t0, $t0, $t2 
	add $t0, $t0, $t1
	
	# store the result 
	sw $t0, result 
	
	# output the number
	li $v0, 1
	move $a0, $t0
	syscall 
	
	# exist the program 
	li $v0, 10
	syscall
	
	