# Making a program that check whether a number is even or odd 
.data 
	num1: .asciiz"Enter in a number: "
	num2: .asciiz"Enter in a second number"
	oddResult: .asciiz"The result is odd"
	evenResult: .asciiz"The number is even"
.text 
	# reading the first number prompt 
	li $v0, 4
	la $a0, num1
	syscall 
	
	# taking user input for the first number 
	li $v0, 5 
	syscall 
	
	# moving the result to another register ( t0 ) 
	move $t0, $v0 
	
	# checking is answer is even of odd
		# if number % 2  == 0 branch to even 
		# if number % 2 != 0 branch to odd 
	# finding the reminder of the result 
	li $t1, 2
	rem $t2, $t0, $t1 
	beq $t2, $zero, even 
	bne $t2, $zero, odd
	
	even:
		# printing the label 
		li $v0, 4
		la $a0, evenResult
		syscall 
		
		b end 
        
	odd:
		li $v0, 4
		la $a0, oddResult
		syscall 
	
	end:
	