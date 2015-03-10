#***************************************************************************
#
#            EECE 344L - Microprocessors - Fall 2011
#
#      Name: Vicente Leyba
#
#
#      Laboratory Number: Lab 4-2	   Due Date: 10/27/2011
#
#
#
#      Lab Group: Worked Individually 
#
#
#
#***************************************************************************
#
#
#      Purpose:
#         Using Interrupts make a rotating pattern on board
#         edge LEDs.  Pattern rotates twice at half second
#         per LED, and five times at quarter second per LED.
#
#***************************************************************************


#***************************************************************************
#
#Exception Vector Prefix Register was set to a value of 0, meaning the
#external interrupt for this exercise would be located at memory address 0x500.
#***************************************************************************


	.org 0x500

	bl modled					# routine rotates leds
	nop							# no operation
	mttsr r3					# reset counter for half second
	rfi							# return from interupt


#***************************************************************************
# Next section of code lines (37-73)set up address and loads values 
# into the required locations to set up and enable interupts, times, LEDs
# and etc.
#***************************************************************************

	
	.org 0x1000					# starting point of program

	li r0, 0x0					# used to initialize leds	
	li r1, 0x0					# load 0 into gpr r1
	mtevpr r1					# EVPR initialized
	lis r2, 0x0440				# sets bit 5 and 9 on the TCR
	mttcr r2					# bit 5 and 9 now set
	lis r3, 0x0800				# used to reset timer
	mttsr r3					# timer reset/initialized
	lis r4, 0x05f5				# sets timer to half second @200 MHZ
	ori r4, r4, 0xe100			# timer is now half second
	mtpit r4					# timer is set

	lis r5, 0x8142				# pointer to 4bit led
	li r6, 0x1					# for four leds
	stw r0, 4(r5) 				# initialize leds
	li r7, 0x1					# used for flag
	li r8, 0x0					# counter

wrteei 1						# interrupts are on!

start:
	cmpi 0, r7, 0x1				#check if flag is set
  	bf 2, start					#if flag is not set go back to start
	stw r6, 0(r5)				#writes word to leds
	li r7, 0x0					#resets flag
	b start						#branch to start


#***************************************************************************
# Next section of code handles the LED functions, and controls how the leds
# rotate giving the desired pattern 
# 
#***************************************************************************

modled:					
	addi r8, r8, 0x1			# increment counter
	cmpi 0, r8, 17				# checks if counter is 17
	bf 2, skip	
	li r8, 0x1					# reset counter to 1
skip:
	cmpi 0, r8, 17				# checks if counter < 27
	bf 0, shiftled	
	andi. r1, r8, 0x1			# checks if counter is even
	bt 2, shiftled
	blr							#branch to link register

shiftled:	
	li r7, 0x1					# flag is set
	slwi r6, r6, 0x1			# rolls bit pattern
	cmpi 0, r6, 0x10			# resets bit pattern
	bt 2, resetct				# branch if true to resetct
	blr							# branch to link register
resetct:
   
	li r6, 0x1					# reset leds
	blr
