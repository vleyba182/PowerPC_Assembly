#**************************************************************
#
#	EECE 344L - Microprocessors - Fall 2011
#
#	Name:Vicente Leyba
#
#
#	Laboratory Number: Lab 3 Part 4	       Due Date:10/11/2011
#
#
#
#	Lab Group: Worked Individually 
#
#
#
#***************************************************************
#
#	Purpose: Print a number to the UART
#     
#***************************************************************       
		
		
	.set TXFIFO,0x04  		#offset of 4
	.set STATREG,0x08  		#offset of 8	
	
	.org 0x1000

	lis r15, 0x8400 		#points at UART
	li r1, 0x2000			#pointer to integer
	li r2, 0x204f			#pointer to string
	li r3, 0x0a				#pointer to NL (new line)
	li r4, 0x0d				#pointer to CR (carriage return)
	li r10, 10				#constant used for division by 10

	lwz r5, 0(r1)  	        #loads integer
	mr r31, r5	    		#copies original int
	stbu r3, 1(r2)  		#loads new line
	stbu r4, 1(r2)	 		#loads carriage
	cmpi 0, r5, 0 			#tests if negative
	bf 0, loop				#branch to look is false
	neg r5, r5				#if negative make as twos complement number 
loop:
	divw r6, r5, r10		#integer /10
	mr r8, r6				#moves r6 to r8
	mullw r6, r6, r10 		#mullitplies r6 by 10
	subf r6, r6, r5			#r6 needed value
	addi r6, r6, 0x30		#changes to asci
	stbu r6, 1(r2) 			#stores ascii
	cmpi 0, r8, 0			#compares r8 to zero
	mr r5, r8				#compares next number
	bf 2, loop				#branch to loop if false
	cmpi 0, r31, 0			#compare r31 to 0
	bf 0, position			#branch to position if false
	li r6, 0x2d				#adds minus if negative
 	stbu r6, 1(r2) 			#stores ascii value

position:

	bl getstatus			#get status

here: b here

getstatus:
	
	addi r2, r2, 1 			#pointer needs to point one past 
	mflr r1         		#stores return address
