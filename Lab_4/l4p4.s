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
	li r1, 0x2				# to clear interupt
	stw r1, 12(r9)			# interrupt cleared
	rfi

	.org 0x1000

	bl led4					# routine rotates leds						
	mttsr r5				# reset counter for half second
	rfi						# return from interupts

#***************************************************************************
# Following section of code set up interupts for the timer and also 
# sets up the period needed for this part of the lab etc..
#***************************************************************************

	.org 0x3000				# starting point of program

	li r2, 0x0				# will initialize EVPR
	mtevpr r2				# EVPR initialized!
	lis r4, 0x0440			# sets bit 5 and 9 or the TCR
	mttcr r4				# bit 5 and 9 now set
	lis r5, 0x0800			# used to reset timer
	mttsr r5				# timer reset/initialized
	lis r12, 0x5f5			# sets timer to half second
	ori r12, r12, 0xe100	# timer is now half second
	mtpit r12				# timer is set

	lis r8, 0x83c0			# base address of timer 1
	li r1, 0x9C4			# 25 us period
	stw r1, 4(r8)			# store in TLR0
	li r1, 0x2f6			# bit pattern to configure TCSRO
	stw r1, 0(r8)			# timer 0 is configured
	li r1, 0x2d6			# bit pattern to enable TCSR0
	stw r1, 0(r8)			# timer 0 enabled
	li r3, 0x3e8			# 50% duty cycle
	stw r3, 20(r8)			# duty cycle in TLR1
	li r1, 0x2b6			# bit pattern to configure TCSR1
	stw r1, 16(r8)			# configure TCSR1
	li r1, 0x296			# enable timer 1
	stw r1, 16(r8)			# timer 1 enabled

	lis r9, 0x8180			# interrupt control
	li r1, 0x02				# enable timer 1 to interupt
	stw r1, 8(r9)			# timer interupts are on
	li r1, 0x3				# for master interupts
	stw r1, 28(r9)			# enable master interupt
	
	lis r11, 0x8142			# pointer to 4bit led
	li r6, 0x1				# for four leds
	li r0, 0x0				# used to initialize leds
	stw r0, 4(r11) 			# initialize leds
	li r10, 0x1				# used for flag
	li r13, 0x0				# counter
	wrteei 1				# interrupts on

start:

	cmpi 0, r10, 0x1		# check if flag is set
   	bf 2, start	
	stw r6, 0(r11)			# writes word to leds
	li r10, 0x0				# resets flag
	b start

#***************************************************************************
#THis section handles the patern on the LEDS, reused from part 3 of the lab
#***************************************************************************

led4:	
				
	addi r13, r13, 0x1		# increment counter
	cmpi 0, r13, 17			# checks if counter is 17
	bf 2, skip
	li r13, 0x1				# reset counter to 1
skip:

	cmpi 0, r13, 27			# checks if counter < 27
	bf 0, shiftled
	andi. r2, r13, 0x1		# checks if counter is even
	bt 2, shiftled

	blr

shiftled:
	
	li r10, 0x1				# flag is set
	slwi r6, r6, 0x1		# rolls bit pattern
	cmpi 0, r6, 0x10		# resets bit pattern
	bt 2, resetct
	blr
					
resetct:

   	li r6, 0x1				# reset leds
	blr
