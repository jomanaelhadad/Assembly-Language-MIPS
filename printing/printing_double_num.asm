.data 
	myDouble: .double 7.202 # we dont have dollar sign 0 in double 
	zeroDouble: .double 0.0
.text 
main:
	ldc1 $f2, myDouble  # load double co-processor 1 , we need 2 registers to hold a double , stored in f2 and f3
	ldc1 $f0, zeroDouble # zero double will be stored in f0 and f1 
	
	li $v0, 3 # syscall for printing double 
	add.d $f12, $f2, $f0 # passing the value as argument f12 for doubles and floats 
	syscall 

	# exit the program 
	li $v0, 10
	syscal 
	
