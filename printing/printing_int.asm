# Program that prints an integer to the screen 
.data
    num: .word 
.text 
    li $v0, 1
    la $a0, num 
    syscall 