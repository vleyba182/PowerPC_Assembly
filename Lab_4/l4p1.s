#***************************************************************************
#
#            EECE 344L - Microprocessors - Fall 2011
#
#      Name: Vicente Leyba
#
#
#      Laboratory Number: 4-1		   Due Date: 10/27/2011
#
#
#
#      Lab Group: Worked Individually 
#
#
#
#***************************************************************************
#
#      Purpose:  Modify the echo routine from the previous laboratory 
#       to function by using interrupts, with the UART. Also have  
#		Leds show rotation pattern   
#    
#***************************************************************************

	.org 0x500	  			# starting point of ISR

	lwz r15, 8(r10)	  		# loads UART status reg
	andi. r15, r15, 0x1		# checks if RXFIFO empty
	bt 2, setup				# branch to setup if conditions are true
	lwz r9, 0(r10)			# stores value from UART in mailbox
	li r13, 0x1				# sets flag so main will print

#***************************************************************************
# Next section of code lines (37-73)set up address and loads values 
# into the required locations to set up and enable interupts, leds, uart, etc
#***************************************************************************

setup:

	nop
	nop						#nop
	li r12, 0x8				#load  to gpr r12
	stw r12, 12(r11)		#acknowledges interrupt dealt with
	rfi						#return from interupt 
	
	.org 0x1000				#starting point of main

	li r0, 0				#load 0 into gpr r0
	lis r1, 0x8146			#load address of led 32a into gpr r1
	lis r2, 0x8148			#load address of led 32b into gpr r2
	lis r3, 0x30			#used for counter
	lis r4, 0x80			#bit in 24 spot
	li r5, 1				#constant one
	lis r6, 0x8000			#bit in 32 spot

	li r7, 0xff				#for a leds
	li r8, 0x00				#for b leds

	stw r0, 4(r1) 			#initialize leds
	stw r0, 4(r2) 	 		#initialize leds

	li r13, 0x0				#mailbox flag	
	li r9, 0x0				#used for mailbox value
	lis r10, 0x8400 		#base address of UART 
	lis r11, 0x8180  		#base address of interrupt controler

	li r12, 0x8				#used to set intr cont 
	stw r12, 8(r11)			#sets intr for UART
	li r12, 0x10			#used to set UART to send intr
	stw r12, 12(r10)     	#enables UART to send intr
	li r12, 0x3				#used to set master intr reg
	stw r12, 28(r11)		#enable master intr
	li r12, 0				#used to set EVPR
	mtevpr r12				#base address of EVPR is 0x0
	wrteei 1				#interrupts are on!
	nop
	nop

start:	
	cmpi 0, r13, 0x1		#checks if flag is set
	btl 2, printchar		#if set, goes to print routine
	bl led32				#rotate LEDs
	nop						#no operation	
	mtctr r3				#resets counter for nop loop

pause:
	nop						# nop
	bdnz pause				# loops nops to create pause
	b start					# process starts all over

printchar:	
	stw r9, 4(r10)			#echoes character to UART
	li r13, 0x0				#resets flag to zero
	li r9, 0x0				#clears echoed character
	blr						#branch to link register


#***************************************************************************
# Next section of code lines (102-125) handles the functionality of the 
# LEDS and correctly outputting the desired pattern of rotating LEDS as done
# in the previous lab
#***************************************************************************

led32: 

	stw r7, 0(r1)			#stores value into a leds
	stw r8, 0(r2)			#stores value into b leds
	and r14,r7,r6   		#checks if most sig bit is 1
	cmp 0, r14, r6	 		#chicsk if sig bit is one
	bt 2, case1				#branches if sig
	and r14,r8, r5			#if led b at end
	cmp 0,r14,r5			#checks if b at end
	bt 2, case2				#branches
	slw r7, r7,r5			#shifts a leds left
	srw r8, r8,r5 			#shift b to the right
	blr
case1:
	slw r7, r7,r5			#shifts a leds left
	srw r8, r8,r5 			#shift b to the right
	add r8, r8,r6 			#pushes bits out of b
	blr
#
case2: 
	srw r8, r8, r5			#shifts b leds right one
	slw r7, r7, r5			#shifts a leds to left
	add r7, r7, r5			#pushes bits out in b
	blr

