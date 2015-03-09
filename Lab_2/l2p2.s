#*************************************************************
#
#	EECE 344L - Microprocessors - Fall 2011
#
#	Name: Vicente Leyba	
#
#
#	Laboratory Number: Lab 2 Part2		Due Date: 9/27/2011
#
#
#
#	Lab Group:Worked Individually 
#
#
#
#***************************************************************
#
#	Purpose:
#
#	D Devise and test instruction sequences for the following loop construct:
#     do {
#       W = W + 100;
#       Y = Y + Y/9;
#	  } while (W > Y)
#
#
#***************************************************************

	.org 0x1000         #program starting memory

	li r1, 0x2000       #pointer in memory

	li r2, 0            #counter to determine number of times loop executes
	li r3, 150          #load 150 into gpr r3. W value
	li r4, 20           #load 20 into gpr r4. Y value
	li r5, 9            #load 9 into gpr r5. Will be used for division in dowhile loop

dowhile:
	
	addi r3, r3, 100	#add r3 + 100 into r3
	divw r6, r4, r5		#divide gpr r4 by r5 (Y/9)
	add  r4, r4, r6		# add gpr r5 and r5. (Y = Y+Y/9)
	addi r2, r2, 1		#increment counter
	cmp  1, r3, r4		#check condition by comparing W and Y
	bt 5, dowhile		#if loop conditions are met branch back to loop

	stw r2, 0(r1)		#store number of iterations
	stw r3, 4(r1)		#store final value of W into memory
	stw r4, 8(r1)		#store final calue of Y into memory

here: b here

nop 
nop