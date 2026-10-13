.data
    message: .asciiz"Something"
.text 
    li $v0, 4
    la $a0, message 
    syscall 