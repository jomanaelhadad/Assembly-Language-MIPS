# making a program that iterate over a string 
.data 
	string: .asciiz"Hello"
	newline: .asciiz"\n"
.text 
	# loading the string 
	la $t0, string 
	
	loop: 
	
		# load byte ( letter  inside t1 ) 
		lb $t1, 0($t0)
		
		# branch if value in t1 is equal to 0 ( termination character and terminate the loop ) 
		beq $t1, $zero, end 
		
		# printing the letter 
		move $a0, $t1
		
		li $v0, 11 
		syscall 
		
		# new line 
		li $v0, 4
		la $a0, newline 
		syscall 
		
		# incremeting loop 
		addi $t0, $t0, 1 
		b loop 
	end: 
		li $v0, 10
		syscall 
