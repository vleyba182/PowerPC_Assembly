#*************************************************************
#
#	EECE 344L - Microprocessors - Fall 2011
#
#	Name:Vicente Leyba
#
#
#	Laboratory Number: Lab 2 Part 5	       Due Date:10/11/2011
#
#
#
#	Lab Group: Worked Individually 
#
#
#
#***************************************************************
#
#	Purpose: Write a routine to rotate the LEDS on the board
#	
#	
#
#***************************************************************

	.set LED4BIT, 0x8140			#points to 4 bit led
	.set LEDPOSITION, 0x8142		#points to position	
	.set LED32A, 0x8146				#points to 32 a leds
	.set LED32B, 0x8148				#points to 32 b leds

	.org 0x1000						#start of program

	lis r3, LED4BIT					#pointer to 4bit led
	lis r4, LEDPOSITION				#pointer to position led
	lis r5, LED32A					#points to led 32a
	lis R6, LED32B					#points to led 32b
	lis r10, 0x100					#used for counter
	lis r15, 0x10					#used for position reg
	lis r26, 0x80		  		    #bit in 24 spot
	li r27, 1			       	 	#constant one
	lis r28, 0x8000					#bit in 32 spot
	li r0, 0						#zero reg
	li r1, 0xff						#for a leds
	li r2, 0x00						#for b leds
	li r7, 0x1						#for four leds
	li r8, 0x1						#for pos leds

	stw r0, 4(r3) 					# initialize leds
	stw r0, 4(r4) 					# initialize leds
	stw r0, 4(r5) 					# initialize leds
	stw r0, 4(r6) 					# initialize leds

start:
	bl led32
	nop
	bl frled
	nop
	bl posled
	mtctr r10
nlp:
	nop
	bdnz nlp
	b start
#
led32:
	stw r1, 0(r5)					#stores value into a leds
	stw r2, 0(r6)					#stores value into b leds
	and r31,r1,r28    				#checks if most sig bit is 1
	cmp 0, r31, r28   				# chicsk if sig bit is one

bt 2, case1							# branches if sig
	and r31,r2, r27					# if led b at end
	cmp 0,r31,r27					# checks if b at end
	bt 2, case2						#branches
	slw r1, r1,r27					#shifts a leds left
	srw r2, r2,r27 					#shift b to the right
	blr
case1:
	slw r1, r1,r27					#shifts a leds left
	srw r2, r2,r27 					#shift b to the right
	add r2, r2,r28 					#pushes bits out of b
	blr	

case2:
	srw r2, r2, r27					#shifts b leds right one
	slw r1, r1, r27					#shifts a leds to left
	add r1, r1, r27					#pushes bits out in b
	blr

frled:								#produces bit pattern of four leds
	stw r7, 0(r3)					#writes word to leds
	slw r7, r7, r27					#rolls bit pattern
	cmpi 0, r7, 0x10				#resets bit pattern
	bt 2, reset1
	blr		
			
reset1:
   li r7, 0x1
	blr
#
posled:
	stw r8, 0(r4)					#writes word to leds
	slw r8, r8, r27					#rolls	 bit pattern
	cmpi 0, r8, 0x20				#resets bit pattern
	bt 2, reset2
	blr					
reset2:
   li r8, 0x1
   blr
