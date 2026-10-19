# Plan of my implementation 
# 1. I made the program organised in sections to keep track of my code 
# Below is a rough plan of the logic / thought processes behind my implementaion of the assignment 

# Phase 1: Getting user input and parsing the string 
	#1. prompt user 
	#2. read user input as a string ( syscall 8 ) at label inputStr 
	#3. copy the register holding the address of inputStr from a0 to t0 
	#4. have s0 initialised to 0 for determining the negative bit ( used to negate the floating point result later on )
	#5. have an accumlator for keeping track of the integer 
	#6. ParseString: 
		# load byte of offset 0 + address of t0 into t2 -> t2 has the first byte 
		# move t2 into argument register for procedure of inputSrtEnd 
		# check whether the end character of the string is found 
		# branch to endParsing 
		# else: 
			# if the first byte in t2 is equal to a minus ( ascii 45 ) branch to negativeNum
			# if a the first byte ( later on going to loop ) is equal to a decimal, branch to decimalPoint 
			# converting the first byte from ascii to integer using string2int procedure 
			# jump back to parseString to start a loop 
		# negativeNum:
			# assign s0 to 1 
			# increment the pointer to the next byte in t0 
			# jump to parseString 
		# decimalPoint:
			# initialise a fraction counter 
			# increment the pointer to the next byte in t0 
			# fractionLoop:
				# load byte of 0 offset + address of t0 into t3 -> t3 has first byte 
				# move t3 to a0 for argument 
				# call inputStrEnd procedure again 
				# branch if a end character in the string is found to endParsing 
				# convert the string to ascii 
		#e endParsing:
			# using floating point operands ( dealing with co-procssor 1 ) 
			# move to co-procssor 1 value inside t5 -> whole number part to f0 
			# convert into float 
			# load value of 1000.0 into f3 
			# convert fraction part ( t2 ) into float in f1 
			# divide f1 / f3 ( f1 / 1000.0 )  or ( fraction / 1000.0 ) 
			# add the divided fraction and converted integer to f2 
			# using another register check is value inside s0 is 1 
			# if it is 1, negate the result of the float 
			# else:
				# store the float 
				# jump to singleForm 
# Phase 2: Converting the float to IEEE Form ( hardest part ) 
# singleForm:
	# load address str2float into t1
	# load word offset 0 + address of t1 into t2  ( t2 has value inside address t2 ) 
	# extract the sign but ( 1 or 0 )
	# shift to the right 31 ( MSB ) 
	# extract the exponent bits ( 8 bits ) 
	# 31 - 8 = 23: therefore we will shift 23 bits 
	# use a mask of 1111 1111 or 0xFF to extract the expo bits 
	# mask the result of the 23 bits by masking 0x7FFFFF or 23 binary 1's 
	# issue: 
		# immediate instructions can only hold 16 bits for constants 
		# to solve the issue we load 0x7FFFFF into a register 
		# we and both registers 
# converHex:
	# load the address of hexValue into t7
	# convert sign bit to ascii ( from hex to ascii )
	# store value of t3 into t7 offset 0 ( first byte in t7 is the sign bit) 
	# increment pointer 
	# use printSeparator procedure to print '|' 
	# increment pointer
	# convert exponent to ascii 
	# use 1111 mask and shift by 4 bits ( hex ) 
	# convert the first digit of hex to ascii ( 0-9 , add 48, 10 -15 add 55) 
	# using procedure of printHex to convert 
	# convert both digits 
	# print a separator 
	# jump to convertFraction 
# convertFraction:
	# shift 20 bits to the right
	# mask by 7 ( 111 ) - extracting the first 3 bits 
	# store it into t7
	# increment pointer 
	# convert the 20 bits into ascii 
# fractionHex:
	# shift right logical variable 16 
	# mask by 1111 
	# convert to ascii using printHex procedure 
	# check if the number of hex reached 5 ( fraction part in hex -> 5 hex digits ) 
	# if it does, print the result and store a null 0 into t7
	# else jump back to fractionHex
# Phase3: Procedures 
# printResult:
	# print result 
	# print hexValue 
	# terminate the program 
# inputStrEnd:
	# load \n ( ascii 10 ) 
	# compare a0 with 10 
	# compare 10  with zero ( \0) 
	# if return value is 0 an end character was found 
	# if return value is 1 no end character was found 
# string2Int:
	# subtract 48 from argument 
	# multiply accumlator arguemnt by 10 ( place digit value )
	# add both arguments 
	# return address 
# printSeparator:
	# load ascii separator number ( 124 )
	# arguement of a0 and a1 here a0 is the register with byte and a0 is the destination register 
# printHex:
	# compare if a0 ( first agrument) is less than 10 
	# if true:
		# jump to add 48 
	# else:
		# add 55
	# return the hex in return register of v0 
	

.data 
	str2float: .float 0 
	fraction: .word 0 
	name: .asciiz"Name: Tuna\nStudent Number: 123456\nDescription: Implementing Core assigment.\n" 
	hexValue: .space 20 
	prompt: .asciiz"Enter in a real number: "
	result: .asciiz"Your HEX representation: "
	inputStr: .space 20 
	
	# divisor 
	one: .float 1.0 
	ten: .float 10.0 
	
	# error checking 
	nonNum: .asciiz"Only enter a number"
	numBig: .asciiz"Number is too big!"
	numSmall: .asciiz"Number too small!"
	invalidChar: .asciiz"Invalid input (too many characters)"
.globl main 
.text 
main:
	# Printing name
	li $v0, 4
	la $a0, name 
	syscall 
	
	# Prompting user message 
	li $v0, 4
	la $a0, prompt
	syscall 
	
	# reading user input as a string 
	li $v0, 8
	la $a0, inputStr # -> a0[address of inputStr] 
	li $a1, 20       # -> space allocated for inputStr 
	move $t0, $a0 
	syscall 
	
	
	li $s0, 0 # sign register 
	li $t5, 0 # integer accumulator 
	
	# initialise divisor 
	l.s  $f3, one # load 1.0 int f3 	
	l.s $f4,ten  # load 10.0 into f4 
	parseString:
		# load byte from inputStr into t2 
		lb $t2, 0($t0)
		move $a0, $t2
		jal inputStrEnd # check end string 
		
		# if return value is equal to 1 jump to end ( end character found) 
		li $t1, 1
		beq $v0, $t1, intEnd 

		beq $t2, 45, negativeNum   # branch if t2 is equal to '-' ascii (45) to negativeNum label
		beq $t2, 46, decimalPoint  # branch if t2 is equal to ascii '.' (46) to decimalPoint 
				
		# convert string to int 
		move $a0, $t2
		move $a1, $t5 
		jal string2Int 
		move $t5, $v0
		addi $t0, $t0, 1
	
		j parseString
	
	negativeNum:
		# assign s register to 1 ( negative ) 
		li $s0, 1
		# increment pointer to point to the next byte 
		addi $t0, $t0, 1
		# jump back to convertingInt 
		j parseString
	
	
	decimalPoint: 
		li $t4, 0 # divider counter 
		li $t2, 0 # fraction accumulator
		li $t6, 0 # loop divisor counter
		addi $t0, $t0, 1
		
		# loop for converting the fraction part ( string after decimal point ) to int 
		fractionLoop:
		 	lb $t3, 0($t0) 
		 	move $a0, $t3
		
			# check end string
			jal inputStrEnd 
			li $t1, 1 
			beq $v0, $t1, divisorLoop 
			
			# convert to ascii 
			move $a0, $t3
			move $a1, $t2
			jal string2Int 
			move $t2, $v0 
			
			addi $t4, $t4 ,1 
			addi $t0, $t0, 1
	
			# jump back to thefractionLoop 
			j fractionLoop 
		
		
		divisorLoop:
			beq $t6, $t4, divisorDone # if counter and 10.0 are equal, break loop 
			mul.s $f3, $f3, $f4 # multiply 10.0 x 1.0 = 10 
			addi $t6, $t6, 1  # increment counter 
			j divisorLoop 
			 
			
		divisorDone:
			j int2Float
	
	intEnd:
		li $t2, 0
		j int2Float 	
	int2Float: 
		mtc1 $t5, $f0 
		cvt.s.w $f0, $f0
		# f0 = int into float 
	
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
			j singleForm
		
	
	singleForm: 	
		# load address str2floatr ino t1 
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
		
		j convertHex 
		
	convertHex:
		# converting the sign bit from hex to ascii 
		la $t7, hexValue 
		addi $t3, $t3, 48 
	
		# Store the sign character in t7 
		sb $t3, 0($t7) 
		addi $t7, $t7, 1 
		
		# separator
		move $a1, $t7 
		jal printSeparator 
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
		
		# separator
		move $a1, $t7 
		jal printSeparator 
		addi $t7, $t7, 1 
		
		j convertFraction 
		
	convertFraction: 
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
		
			# convert hex to ascii 
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
	
	
	# PROCEDURES 
	inputStrEnd:
		li $t1, 10 # checks for newline (\n) ascii for new line is 10 
		beq $a0, $t1, endStr # checks for null terminator (\t0 
		beq $a0, $zero, endStr
		
		# character is an end character ( \n or \0) 
		li $v0, 0 
		jr $ra
		endStr: 
			# character is not an end character 
			li $v0, 1
			jr $ra 
			
	# fraction conversion procedure 
	string2Int:
		addi $a0, $a0, -48 
		mul $a1, $a1, 10 
		add $v0, $a1, $a0
		jr $ra
			
		
	# separator procedure 
	printSeparator:
		li $a0, 124
		sb $a0, 0($a1)
		jr $ra 	
		
	# procedure for printing hex 
	printHex:
		blt $a0, 10, add48 
		addi $a0, $a0, 55
		j returnHex
		
		add48:	
			addi $a0, $a0, 48 
			
		returnHex:
			move $v0, $a0 
			jr $ra
		