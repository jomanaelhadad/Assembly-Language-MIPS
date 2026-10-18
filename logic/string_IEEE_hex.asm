
.data 
	str2float: .float 0 
	fraction: .word 0 
	divisor: .float 1000.0
	separator: .asciiz"|"
	hexValue: .space 20 
	prompt: .asciiz"Enter in a real number [xxx.yyy]: "
	result: .asciiz"Your hex representation: "
	inputStr: .space 20 
	
.globl main 
.text 
main: 
	# printing prompt
	li $v0, 4
	la $a0, prompt
	syscall 

	# reading user input as a string 
	li $v0, 8
	la $a0, inputStr # -> a0[address of inputStr] 
	li $a1, 20       # -> space allocated for inputStr 
	move $t0, $a0 
	syscall 
	
	# t0 = inputStr
	# locating the decimal point in the string 
	li $t1, 46 # loading t3 = 46 ( ascii for '.' ) 
	li $s0, 0 # sign flag
	# loading '-' to check for negative number
	
	# integer accumlator 
	li $t5, 0
	convertingInt:
		lb $t2, 0($t0) # byte inside t0 
		
		beq $t2, 45, negativeNum 
		
		# checking decimal point 
		beq $t2, $t1, decimalPoint 
		
		# robust check for newline and \0 terminator 
		li $t4, 10 
		beq $t2, $t4, inputStrEnd 
		beq $t2, $zero, inputStrEnd
 
		
		# converting the integer part from ascii to int 
		addi $t2, $t2, -48 
		
		# multiply the accumlator by 10 
		mul $t5, $t5, 10 
		add $t5, $t5, $t2 
		
		addi $t0, $t0, 1
		
		j convertingInt
	negativeNum:
		li $s0, 1
		addi $t0, $t0, 1
		j convertingInt 
		
	decimalPoint: 
		# initialise the counter 
		li $t2, 0 
		
		# move to the next character ( increment to the next byte ) 
		# move the pointer by 1, so now 1 offset 
		addi $t0, $t0, 1
		
		fractionLoop:
		 	# read the current character 
		 	lb $t3, 0($t0) 
		 	
			# check for a newline 
			li $t4, 10 
			
			# check for newline or null terminator 
			beq $t3, $t4, inputStrEnd 
			beq $t3, $zero, inputStrEnd 
			
			# convert ascii to integer 
			addi $t3, $t3, -48 
			
			# 0 x 10 + 3 = 3
			# 3 x 10 + 4 = 34 
			# 34 x 10 + 7 = 347 
			mul $t2, $t2, 10 
			add $t2, $t2, $t3 
			# this means t2 has the fully convert fraction part 
			
			# advance the pointer 
			addi $t0, $t0, 1 
			
			# jump back to thefractionLoop 
			j fractionLoop 
		
	inputStrEnd: 
	
	# calculating the float 
	# divide fraction part by 1000 ( t2 /1000 )
	# add result to t5 ( int + faction / 1000 ) 
	# save result in t3 as an intermediate register
	
	# convert t5 to float
	mtc1 $t5, $f0 
	cvt.s.w $f0, $f0
	# f0 = int into float 
	
	# f3 = 1000.0 
	l.s $f3, divisor
	
	# convert fraction to float 
	# f1 = fraction into float 
	mtc1 $t2, $f1
	cvt.s.w $f1, $f1
	
	div.s $f1, $f1, $f3 
	
	# f2 = int(float) + fraction(float) 
	add.s $f2, $f0, $f1
	li $t9, 1 
	beq $s0, $t9, negateFloat
	j storeFloat
	
	negateFloat:
		neg.s $f2, $f2
	
	# store f2 into str2float 
	storeFloat: 
		s.s $f2, str2float
	
	
	# convert the whole number part 
	# same as fraction 
	
	# NEXT PART 
	# CONVERTING TO IEEE 754 
	# Sign : 1bit 
	# Expo : 8 bits 
	# Fraction : 23 bits 
	# str2float ( f2) has the float number 
	
	# loading the raw bits 
	
	la $t1, str2float
	lw $t2, 0($t1) 
	
	# extract the sign bit 
	# t3 = sign bit 
	srl $t3, $t2, 31 
	
	# extract the exponent bit ( 8 bitd ) 
	# t4 = expo bits ( 8 bits )
	srl $t4, $t2, 23 
	andi $t4, $t4, 0xFF 
	
	# using 0x7FFFFF mask 
	# t5 = fraction bit
	li $t6, 0x7FFFFF
	and $t5, $t2, $t6
	
	
	# Print the IEEE in hex 
	
	# convert the sign bit to itS ascii character 
	la $t7, hexValue 
	addi $t3, $t3, 48 
	
	# Store the sign character 
	sb $t3, 0($t7) 
	addi $t7, $t7, 1 
	
	# sparator 
	li $t1, 124 
	sb $t1, 0($t7) 
	addi $t7, $t7, 1 
	
	
	# convert expo from hex to ascii character 
	move $t3, $t4 
	andi $t6, $t3, 0xF
	srl $t3, $t4, 4
	
	# convert the first digit of the expo to ascii 
	move $a0, $t3 
	jal printHex 
	sb $v0, 0($t7) 
	addi $t7, $t7, 1 
	
	# convert the second digit of the expo to ascii 
	move $a0, $t6
	jal printHex 
	sb $v0, 0($t7) 
	addi $t7, $t7, 1 
	
		
	# sparator 
	li $t1, 124 
	sb $t1, 0($t7) 
	addi $t7, $t7, 1 
	
	
	# convert fraction from hex to ascii character 
	# t5 = fraction bits 
	# first hex fraction -- extract 3 bits 
	# t8 contains the 3 most significant bits 
	srl $t8, $t5, 20 
	andi $t8, $t8, 7 
	
	# convert t8 to ascii 
	addi $t8, $t8, 48 
	
	# store the byte 
	sb $t8, 0($t7) 
	
	# increment the pointer 
	addi $t7, $t7, 1 
	
	# converting remaining 20 bits
	# counter  
	 li $t0, 0 
	 li $t9, 16 
	 
	fractionHex:
	
		srlv $t1, $t5, $t9 
		andi $t2, $t1, 0xF 
		
		move $a0, $t2
		jal printHex 
		sb $v0, 0($t7) 
		addi $t7, $t7, 1 
		
		addi $t0, $t0, 1 
		addi $t9, $t9, -4
			
		beq $t0, 5, endHex 
			
		j fractionHex 
		
		endHex: 
			sb $zero, 0($t7) 
			
			j printingResult
			
	# printing your result is: 
	printingResult:
		li $v0, 4
		la $a0, result 
		syscall 
	
		# printing 
		li $v0, 4
		la $a0, hexValue
		syscall 
		
	end: 
		li $v0, 10
		syscall 
	
	
	
	# proecedure for printing hex 
	printHex:
		blt $a0, 10, add48 
		addi $a0, $a0, 55
		j returnHex
		
		add48:	
			addi $a0, $a0, 48 
			
		returnHex:
			move $v0, $a0 
			jr $ra
		
