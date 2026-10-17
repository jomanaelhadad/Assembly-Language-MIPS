# Algorithm for the program 
# .data: 
    # prompt asking use for number 
    # result message 
    
# 1. Initialize the counter to 0 
# loop1:
    # 	1. mask the bits 
    # 	2. allocate stack space 
    # 	3. store the bit inside allocated space 
    # 	4. increment the counter to count the bit we pushed into the stack 
    # 	5. shift the integer 
    # 	6. branch if integer is not zero back to the loop 


# print the result message before the second loop so the result message is only printed once. 

# loop2:
    # 	1. load the word from the stack 
    # 	2. copy value from the loaded word into a0 to print integer for the syscall 
    # 	3. decrement the counter to count the bit we popped from the stack ( lw )
    # 	4. release the stack 
    # 	5. branch back to loop2 until the counter is not equal to 0 

.data
	prompt: .asciiz"Enter an integer: "
	result: .asciiz"Your result is: "
.text 
	# print prompt 
	li $v0, 4
	la $a0, prompt 
	syscall 
	# read user input using int syscall 
	li $v0, 5
	syscall 
	# store user input in t0 
	move $t0, $v0
	
	# initialize the counter 
	li $t1, 0 
	
	# loop1 for extracting the right most bit
	extractingBit:
		# using a mask to extract the right most bit 
		andi $t2, $t0, 1 
		
		# allocating space in stack 
		addi $sp, $sp, -4 
		
		# storing the extracted bit inside the stack 
		sw $t2, 0($sp)
		
		# incrementing the counter to count the stored bit in the stack 
		addi $t1, $t1, 1 
		
		# shifting the integer user input 1 bit to the right 
		srl $t0, $t0, 1 
		
		# branching if the user input is not equal to zero 
		bne $t0, $zero,extractingBit 

	# printing the ressult message to the screen 
	li $v0, 4
	la $a0, result
	syscall 
		
	# second loop for popping the extracted bit out of the stack and printing it to the user 
	printingBit:
		# load the word stored inside the stack
		lw $t2, 0($sp)
		
		# copy the value from the stack to a0 for the integer print syscall 
		move $a0, $t2 
		
		# printing the integer 
		li $v0, 1
		syscall 
		
		# use the counter to decrement the count of the bit inside the stack 
		addi $t1, $t1, -1
		
		#release the stack 
		addi $sp, $sp, 4
		
		# branch back to printBit is counter is not equal to 0
		bne $t1, $zero, printingBit 
		
	end:
		# exit the program 
		li $v0, 10
		syscall

