#  Write a program that uses a string syscall and converts it to int 
# The user enters a number as a string and the program coverts it to integer 
# remember ascii to int have a difference of 48
    # for example, if a user enters 4 it gets interpreted as 52. 
    # 52 - 48 = 4 

.data 
    prompt: .asciiz"Enter in a number: "
    input: .space 10 
    result: .asciiz"Your result is: "
.text
main:
    # printing the prompt 
    li $v0, 4 
    la $a0, prompt
    syscall 

    # taking in user input using string syscall 
    li $v0, 8
    la $a0, input 
    li $a1, 10 
    syscall 

    # notes: a0 -> has the memory address of where the user input is. 
    # a1 -> allocates the amount of byte the user can use. 
    # to load the values inside a0, we need to access the memory itself. 
    # to access the memory, we need to use load byte ( lw ) which is a pseudo instruction 
   
    # accessing the memory 
    # now t0 = value stored inside a0 + 0 offset ( first digit ) 
    lb $t0, 0($a0) 

    # we also need to access the second digit
    # remember that each digit has 1 byte difference, so the second digit is at offset 1, third digit at offset 2 and so on
    lb $t1, 1($a0) 

    # t0 = first digit 
    # t1 = second digit 

    # now lets convert the numbers to ascii. Remember ascii has a difference of 48 since 0 in ascii is 48 
    addi $t0, $t0, -48 

    # convert the second number 
    addi $t1, $t1, -48 

    # now multiply 10 to only the first digit to get 10's unit 
    # for example 56 this is 50 + 6 
    mul $t0, $t0, 10 

    # add the the 2 digits together 
    add $t2 , $t0, $t1 

    # printing the message to the screen 
    li $v0, 4
    la $a0, result 
    syscall 

    # move the result to the syscall register for printing an integer 
    move $a0, $t2 

    # printing back the integer to the screen using int syscall 
    li $v0, 1
    syscall 

    # exit the program 
    li $v0, 10
    syscall 