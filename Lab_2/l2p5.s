#*************************************************************
#
#	EECE 344L - Microprocessors - Fall 2011
#
#	Name:Vicenate Leyba
#
#
#	Laboratory Number: Lab 2 Part 5	       Due Date:9/27/2011
#
#
#
#	Lab Group: Worked Individually 
#
#
#
#***************************************************************
#
#	Purpose:For this laboratory exercise,  the special purpose register
#	counter and a loop construct were used to create a table of  
#	numbers that is factorial divided by sum
#
#
#
#***************************************************************

	.org 0x1000

	li r1, 0x2000           #values 1-12
	li r2, 0x3000           #table for sumation values
	li r3, 0x4000           #pointer for factorial values 
	li r4, 0x5000			#pointer for final values
	li r5, 1				#initial value for table
	li r6, 1				#inital value for sumation
	li r7, 1				#initial value for factorial
	li r8, 1				#initial value of factorial divided by sum
	li r9, 12               #used to store value in counter
	mtctr r9                # move counter in Creg

while:  

	stw r5, 0(r1)          	#store value for index in memory
	stw r6, 0(r2)			#store summation value in memory
	stw r7, 0(r3)			#store factorial value in memory
	stw r8, 0(r4)			#store final value
	addi r5, r5, 1			#add 1 to gpr r5 for next value in table index
	add  r6, r5, r6			#calculates sumation of next value and stores this in gpr r6
	mullw r7, r5, r7		#calculates next value for factorial and stores this in gpr r7
	divw r8, r7, r6			#calculates factorial divided by sum and stores this in gpr r8
	addi r1, r1, 4			#increment memory for table index by 4
	addi r2, r2, 4			#increment memory for sumation values by
	addi r3, r3, 4			#increment memory for factorial values by 4
	addi r4, r4, 4			#increment memory for factorial divided by sumation by 4
	bdnz while				#branch back to beginning of loop if counter is !=0
	nop						#nop
	ori 0,0,0				#nop

here: b here
		
	
