# Program that prints hello world to the screen 
.data 
    message: .asciiz"Hello world\n"
.text 
    main:
        # printing to the screen 
        li $v0, 4
        la $a0, message 
        syscall

    # exit the program 
    li $v0, 10
    syscall 