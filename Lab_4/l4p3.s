#*************************************************************
#
#            EECE 344L - Microprocessors - Fall 2011
#
#      Name: Vicente Leyba
#
#
#      Laboratory Number:Lab 4-4  Due Date: October 27, 2011 
#
#
#
#      Lab Group: Not Applicable
#
#
#
#*************************************************************
#
#      Purpose:
#         Using Interupts make a rotating pattern on board
#         edge LEDs.  Pattern rotates twice at half second
#         per LED, and five times at one second per LED.
#
#	 Now pulse width modulation will occur using  
#	 interrupts. Cycle between 50% and 25% duty cycle 
#	 each 25us
#
#*************************************************************



#***************************************************************************
#
#Exception Vector Prefix Register was set to a value of 0, meaning the
#external interrupt for this exercise would be located at memory address 0x500.
#***************************************************************************

	.org 0x500			# external interrupt
	
	cmpi 0, r3, 0x3e8		# checks if at 50% duty
	bt 2, skip50
   	li r3, 0x3e8			# loads 50% duty
  	stw r3, 20(r8)    		# timer is at 50% duty
	b skip15

skip50:
	addi r7, r7, 1	
	li r3, 0x1F4			# loads 25% duty
	stw r3, 20(r8)			# timer at 25% duty
skip15:
	li r1, 0x2b6			# bit pattern to load timer
	stw r1, 16(r8)			# TCSR1 is configured
	li r1, 0x296			# bit pattern to load timer
	stw r1, 16(r8)			# TCSR1 is configured
	li r1, 0x3d6			# bit pattern to clear period
	stw r1, 0(r8)			# period cleared
	li r1, 0x2			# to clear interupt
	stw r1, 12(r9)			# interrupt cleared
	rfi

	.org 0x1000

	bl led4				# routine rotates leds						
	mttsr r5			# reset counter for half second
	rfi				# return from interupts
