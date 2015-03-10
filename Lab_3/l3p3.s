#***************************************************************************
#
#	ECE 344L - Microprocessors - Fall 2011
#
#	Name: Vicente Leyba
#
#	Laboratory Number: Lab 3 Part3
#
#	Lab Group: Individual Lab	Due Date: 10/11/2011
#
#
#***************************************************************************
#
#
#    Purpose: Print a string to the UART with your name and
#	 the given date format.#	
#***************************************************************************

	.set TXFIFO,0x04   	 		#offset of 4
	.set STATREG,0x08	  		#offset of 8	

	.org 0x1000	     	 	  	#starting point of program 
	
	lis r15, 0x8400		  		#points at UART	
	li r3, 0x1fff	    	 	#pointer to string
	bl getst	          		#branches to rountine that gets string

done:
	
	lwz r12, STATREG(r15)		#status reg to r12 
	andi. r12, r12,4      		#AND r12 with 4   
	bt 2, done		 			#checks if ready to write
	li r5, 0x0d		 			#carriage return 
	stw r5, TXFIFO(R15)
   	li r5, 0x0a		 			#new line
	stw r5, TXFIFO(R15)  	 	#store word 

end:	
		b end 

getst:	
	mflr r1        			 	#stores return address

get:	
	lbzu r5, 1(r3)		 		#r5 gets value of string
	cmpi 0,r5,0 		 		#checks for null character
	bt 2, doneg    		 		#program terminates
	bl print
	b get		

doneg:	
	mtlr r1						#resets link resgister
	blr            				#branches back to start

print:	       
	lwz r12, STATREG(r15) 		#status reg to r12 
	andi. r12, r12,4      		#AND r12 with 4   
	bt 2, print
	stw r5, TXFIFO(R15)     	#outputs word in r12	
	blr		
	.org 0x2000
	.asciz "Vicente Leyba 10-October-2011"
