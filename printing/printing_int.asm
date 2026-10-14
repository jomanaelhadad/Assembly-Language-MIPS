# Program that prints an integer to the screen 
.data
    num: .word 
.text 
main:
    li $v0, 1
    la $a0, num 
    syscall 
    
# exit the program 
li $v0, 10
syscall 