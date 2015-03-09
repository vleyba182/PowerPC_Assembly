#*************************************************************
#
#	EECE 344L - Microprocessors - Fall 2011
#
#	Name: Vicente Leyba	
#
#
#	Laboratory Number: Lab 2 Part1		Due Date: 9/27/2011
#
#
#
#	Lab Group: Worked Individually 
#
#
#
#***************************************************************
#
#	Purpose:
#
#
#	Devise and test instruction sequences to implement the IF syntax as it appears in the C language:
#	if ( Z is true )
#		W = X – Y;
#	else
#		W = X + Y;
#
#
#***************************************************************

	.org 0x1000         #program starting memory

	li r1, 0x2000		#pointer in memory @r1
	
	lwz r2, 0(r1)		#load value from memory to gpr r2 A
	lwz r3, 4(r1)		#load value from memory to gpr r3 B
	lwz r4, 8(r1)		#load value from memory to gpr r4 X
	lwz r5, 12(r1)		#load value from memory to gpr r5 Y

	cmp 0, r2, r3       #compare and check if Z is true A > B
	bt 1, true          #branch to true if statement is true
	add r6, r4, r5		#add gpr's r5 and r5 if condition is false
	b endif			

true:
	sub r6, r4, r5		#subtract gpr r4 and r5 if condition is true
endif:
	stw r6, 16(r1)
	nop                 #no operation
	nop                 #no operation

here: b here			#breakpoint
