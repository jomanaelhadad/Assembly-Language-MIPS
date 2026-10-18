# Write a program that prompts the user to enter a real number in form of xxx.yyy
# Read the user input as a string using syscall 8
# STAGE 1: 
    # Parse through the user input string and find where the decimal point is and if the first byte is an ascii 45 ( - ) 
    # If the first byte is equal to a minus sign jump to negative label where we will later on negate the float answer 
    # Convert the string from before the decimal point as the whole number part
    # Convert the string after the decimal point as the fraction part
# STAGE 2:
    # Convert both parts into float using co-processor 1 and float conversion 
    # Save both conversion in separate registers 
    # Negate the float answer is needed ( condition ) 
# STAGE 3 
    # Convert the float to IEEE from 
    # Since each word is 32 bits

        # 1 bit for sign ( 1 = negative, 0 = positive ) 
        # 8 bits for exponent 
        # 23 bits for fraction part 
    # Using shifts and masking we can extract those bits 
    # We are interested in the most significant bits ( so we shift from right and take 31 bits ) 
    # We shift 23 for the 8 expo bits 
    # We shift more ( uhh idk its confusing ) 
.data 
	str2float: .float 0 
	fraction: .word 0 
	divisor: .float 1000.0
	separator: .asciiz"|"
	hexValue: .space 20 
	prompt: .asciiz"Enter in a real number [xxx.yyy]: "
	result: .asciiz"Your HEX representation: "
	inputStr: .space 20 
.globl main 
.text 
main:
	# Prompting user message 
	li $v0, 4
	la $a0, prompt
	syscall 
	
	# reading user input as a string 
	li $v0, 8
	la $a0, inputStr 
	li $a1, 20       
	move $t0, $a0 
	syscall 
	
	li $s0, 0 # s0 used to check sign bit 
	li $t5, 0 # accumulator 
	
	parseString:
		lb $t2, 0($t0) # load byte from inputStr into t2 
		move $a0, $t2
		jal inputStrEnd  # check end of string 
		
		# if return value is equal to 1 jump to end (end character found) 
		li $t1, 1
		beq $v0, $t1, endParsing
		
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
		li $s0, 1 	# assign s0 register to 1 ( negative ) 
		addi $t0, $t0, 1 # increment pointer 
		j parseString # jump back to parseString 
	
	
	decimalPoint: 
		li $t2, 0 # initialise the counter 
		# increment pointer to move to the immediate byte after decimal point 
		addi $t0, $t0, 1
		
		# loop for converting the fraction part ( string after decimal point ) to int 
		fractionLoop:
		 	lb $t3, 0($t0) 
		 	move $a0, $t3
		
			jal inputStrEnd  # check end string
			li $t1, 1 
			beq $v0, $t1, endParsing
			
			# convert to string to ascii 
			move $a0, $t3
			move $a1, $t2
			jal string2Int 
			move $t2, $v0 
			addi $t0, $t0, 1 
			
			# jump back to fractionLoop 
			j fractionLoop 
		
	endParsing: 
	# reminder:
		# e.g 5.25
		# t5 -> whole number part ( 5) 
		# t2 -> fraction part ( .25 )
		
		mtc1 $t5, $f0 # move to co-procssor 1 t0 f0 
		cvt.s.w $f0, $f0 # convert single word to float ( t5 -> float ) 

		# f3 = 1000.0 
		l.s $f3, divisor
	
		mtc1 $t2, $f1 # move t2 to co-prossor 1 to f1 
		cvt.s.w $f1, $f1 # convert single word to float ( t2 -> float ) 
	
		div.s $f1, $f1, $f3 # divide the fraction part by 1000.0
	
		# f2 = int part(float) + fraction part(float) 
		add.s $f2, $f0, $f1
		
		li $t9, 1 # use 1 to check if sign bit negative or positive ( check against ) 
		beq $s0, 1, negateFloat
		j storeFloat
	
		negateFloat:
			neg.s $f2, $f2 # negate the float result e.g 5.00 = -5.00 
			
		# store f2 into str2float 
		storeFloat: 
			s.s $f2, str2float # store single into str2float 
			j singleForm
	
	# Converting float into IEEE Single precision 754 form 
	singleForm: 	
		la $t1, str2float # t1 = str2float (address) 
		lw $t2, 0($t1) # first byte inside t1 
	
		# extract the sign bit 
		# t3 = sign bit 
		srl $t3, $t2, 31 # shifting from the msb so from right 31 bits to exract 1 bit 
	
		# extract the exponent bit ( 8 bits ) 
		# t4 = expo bits ( 8 bits )
		srl $t4, $t2, 23 # 
		andi $t4, $t4, 0xFF # hex of 1111 1111 
	
		# using 0x7FFFFF mask 
		# t5 = fraction bit
		li $t6, 0x7FFFFF # hex of 1111 1111 1111 1111 1111 111 ( 23 1's ) 
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
		li $t0, 0 
	 	li $t9, 16 
	 	
	 	fractionHex: 
			srlv $t1, $t5, $t9 # shift right logical variable ( since value inside is over 16 bits ) 
			andi $t2, $t1, 0xF # mask using 1111 or 0xF hex 
		
			# convert hex to ascii 
			move $a0, $t2
			jal printHex 
			sb $v0, 0($t7) 
			addi $t7, $t7, 1 
		
			addi $t0, $t0, 1 
			addi $t9, $t9, -4 # decrement t9 so it goes from 16 ,12, 8, 4, 0 ( 5 hex digits ) 
			
			beq $t0, 5, endHex # if t0 reaches 5, end 
			
			j fractionHex 
			
			endHex: 
				sb $zero, 0($t7) # storing zero at the end
				j printingResult
	 
				
	# printing your result is: 
	printingResult:
		li $v0, 4
		la $a0, result 
		syscall 
		
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
			
		
	# separator procedre 
	printSeparator:
		li $a0, 124
		sb $a0, 0($a1)
		jr $ra 	
		
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