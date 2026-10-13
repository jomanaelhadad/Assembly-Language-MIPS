# 2. program taking in user input
# 3. memory address and registers ( arrays ) 


# program that asks the user for their name and age 
.data 
	prompt: .asciiz"What is your name?\n"
	input: .space 20 
	age: .asciiz"What is your age?\n"
	message: .asciiz"Your name is " 
	ageMessage: .asciiz"Your age is "
.text 
	# rint the prompt ( name ) 
	li $v0, 4 
	la $a0, prompt
	syscall 
	
	# user input for a string 
	li $v0, 8
	la $a0, input # address 
	li $a1, 20  # used to tell how much space is available 
	syscall 
	
	# stroe the name inside a temporary register 
	move $t0, $a0
	
	# printing age prompt 
	li $v0, 4 
	la $a0, age 
	syscall 
	
	# getting user age input ( integer )
	li $v0, 5
	syscall 
	
	# storing the age into a temporary register 
	move $t1, $v0  # t1 = 18
	
	# printin back to the user 
	li $v0, 4 
	la $a0, message 
	syscall 
	
	# printing back the name to the user 
	li $v0, 4 
	move $a0, $t0 
	syscall

	# printing the age message to the user 
	li $v0, 4
	la $a0, ageMessage
	syscall 
	
	# printing back the age to the user 
	li $v0, 1 
	move $a0, $t1 
	syscall 
	

	# exist 
	li $v0, 10 
	syscall