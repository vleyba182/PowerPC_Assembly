#*****************************************************************************************
#
#       EECE 344L - Microprocessors - Fall 2011
#
#       Name: Vicente Leyba
#
#       Laboratory Number: Lab5 All Parts              Due Date: 11-15-11
#
#       Lab Group: Worked Individually
#
#*****************************************************************************************
#
#       Purpose:
#
#       Create a interrupt shystem with several simultaneous interrupts
#       
#
#******************************************************************************************


.set GIE,0x11C       		# Global Interrupt En Reg (GPIO)
.set IPIER,0x128     		# IP Int Enbl Reg (GPIO)
.set IPISR,0x120     		# IP Int Status Reg (GPIO)
.set IER,8          		# Int Enbl Reg (INTC)
.set IAR,0x0C        		# Int Ack Reg (INTC)
.set MER,0x1C        		# Master Enbl Reg (INTC)

.set TCSR0,0         		# timer0 control/status reg
.set TLR0,0x04       		# timer0 load reg.
.set TCR0,0x08       		# timer0 count reg.
.set TCSR1,0x0c      		# timer1 control/status
.set TLR1,0x14   			# timer1 load reg.
.set TCR1,0x18   			# timer1 count reg.
.set EVPR,982    			# EVPR
.set timer1, 0x83c0 			# base address of timer1
.set LDLY, 0X7000			# long delay

.org 0x0500					# Base Addresses of Components with offsets
.long 0x84000000			# UART		
.long 0x83C00000 			# Timer 1	
.long 0x83C20000			# Timer 2	
.long 0x81400000 			# Push Buttons	
.long 0x81450000			# LCD		
.long 0x81440000			# CARD EDGE LEDS	
.long 0x81420000			# POSITION LEDS	
.long 0x81460000 			# LEDS A		
.long 0x81480000 			# LEDS B		
.long 0x81800000 			# INTERUPT CTRLR	


	.org 0x0700				# Strings used for UART
	.ascii "0123456789 "
        .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ  "
	.ascii "abcdefghijklmnopqrstuvwxyz     "
	.ascii "!@#$%^&*()_+"
	.long 0x0A0D0000


	.org 0x1000
	li r0, 0x100			# Address of flags
	li r1, 0x500			# pointer to locations
	li r3, 0				# Constant 0
	li r7, 0x0700			# base address of strings
	li r8, 0				# offset initialize

	lis r15, LDLY@h			# Long Delay
	ori r15, r15, LDLY@l	# Or second half of long delay

#4 LED Card Edge INITIALIZATION 
	lwz r2, 20(r1)			# Load base address of card edge 
	li r31, 0				# Used to Set LEDs as outputs
	stw r31, 4(r2)			# Set TRI register with zero make outputs
	li r31, 0xF				# Bit pattern 1111
	stw r31, 0(r2)			# Turn first LED on
	li r14, 0				# count for LED on/off time

# 32 LED A INITIALIZATION
	lwz r2, 28(r1)			# Load 32 "A" LED's base address
	li r11, 0				# constant 0
	stw r11, 4(r2)			# make 32 Bit A LED's output
	lis r11, 0				# pattern for LED's
	stw r11, 44(r0)

# 32 LED B INITIALIZATION
	lwz r2, 32(r1)			# Load 32 "B" LED's base address
	li r16, 0				# constant 0
	stw r16, 4(r2)			# make outputs
	li r16, 1				# initilize first LED on
	stw r16, 0(r2)			# output to LED
	stw r16, 40(r0)
  
# Timer1 Intialization
        lis r2,timer1      	#base address of Timer1
        li r31,0x9c4        #gives 25us period 0xCEC
        stw r31,TLR0(r2)    #put value in time load register
        li r12,0x339        #initialize 15% duty cycle
        stw r12,TLR1(r2)   	#put value in time load for duty cycle
# LOAD TCSR registers
        li r31,0x3D6        #set bits for timer control register 0x3D6
        stw r31,TCSR0(r2)   #send values to timer control register
        li r31,0x296        #set bit for timer control register
        stw r31,TCSR1(r2)   #send values to timer control register

# TIMER2 INITIALIZATION
        lwz r2, 8(r1)       #load base address of timer2
        stw r15,TLR0(r2)    #put value in time load register
        li r31,0x3D6        #set bits for timer control register
        stw r31,TCSR0(r2)   #send values to timer control register
	li r20, 0				#make sure it gets into interrupt
	
	.set LDLY, 100000		#long delay

#PIT and FIT INITIALIZATION 
	lis r31, 0x06C0	   		#TCR Initialization enable PIT/FIT interrupts
	mtspr 0x3da, r31		#move to TCR
	lis r31, 0x0800			#TSR 
	mtspr 0x3d8, r31		#intialize PIS bit
	li r31, 30000			#Value for PIT
	mtspr 0x3db, r31		#move to load register
	lis r31, 0x0C00			#value for TSR
	mtspr 0x3d8, r31		#TSR

#Interrupt Controller INITIALIZATION
	lwz r2, 36(r1)			#Load base address of INTC
	li r31, 0b1111			#bit pattern 1000
	stw r31, 8(r2)			#Send to IER
	li r31, 3				#set up 0011 pattern
	stw r31, 0x1C(r2)		#send to MER
	
	lis r31, 1				#interrupt base = 0x10000
	mtevpr r31				#set as first legal value

#5 POSITION LEDS INITIALIZATION
	lwz r2, 24(r1)    	 	#load base address of 5 Position LED's
        li r31,0            #constant 0
        stw r31,4(r2)       #make LED DDR to outputs	

#Push Button Initialization 
	lwz r2, 12(r1)
        li r31,0x1F          #00011111 to R13
        stw r31,4(r2)        #make button lines inputs
        lis r31,0x8000       #set MSB to 1 and
        stw r31,GIE(r2)      #send to GIE (enable interrupt)
        li r31,0x01          #set LSB to 1 and
        stw r31,IPIER(r2)    #and send to IP IER

#UART Interrupt INITIALIZATION
	lwz r2, 0(r1)			#base address of UART
	li r31, 0x10			#get bit to enable UART
	stw r31, 0x0c(r2)		#send to control reg
	lbzx r31, r7, r8		#load first value of string
	stw r31, 0x04(r2)       #move string to UART        
	addi r8, r8, 1			#increment offset

	wrteei 1				#Set EE in MSR


	lis r30,0x8145      	 # point r30 at the LCD GPIO
        li r29,0             # set up to make the lines
        stw r29,4(r30)       # outputs (0 to DDR)
        li r29,0x02          # set rs=0 and write command set fn
        stw r29,0(r30)       # (20h) to reg of LCD
        bl wait100           # wait 100 ns (more actually)
        li r29,0x42          # set enable=1 writing 1 in bit 0
        stw r29,0(r30)       # of the register of the LCD
        bl wait300           # wait 300 ns
        li r29,0x02          # set the enable to 0
        stw r29,0(r30)       # and send to port
        bl wait60us          # wait 60 us (note that 39 us is min
                             # time execution for ins function set
        #bl wait60us         # throw in another wait

# display on/off control
# set 0x0f
#
        li r17,0x0f       	# pass 0x0f to the
        bl putcmd         	# command routine

#
# display clear...
#
        li r17,0x01     	# this pattern clears display
        bl putcmd         	# call the command routine
        bl wait2ms        	# an even longer wait
#
# entry mode set
#
        li r17,0x06        # 
        bl putcmd

#
# function set= use 2 lines
#
        li r17,0x29
        bl putcmd

	li r17, 0xc
	bl putcmd



main_loop:
	cmpwi 0, r3, 0x7		#Check for UART interrupt flag
	bf 2, check2			#if no UART branch to second check

	lbzx r31, r7, r8		#load r31 with character offset 0
	lwz r2, 0(r1)			#base address of UART			
	stw r31, 0x04(r2)		#load TX FIFO of UART	
	cmpwi 1, r31, 0			#check for 0 which is at end of string
	addi r8, r8, 1			#increment offset of character
	lis r31, 0xffff			#used to clear flag
	ori r31, r31, 0xfff0	#OR second half
	and r3, r3, r31			#clear UART flag
	bf 6, check2			#branch to second check
	li r8, 0				#reset offset to 0

check2:	
	cmpwi 0, r3, 0			#Check for PWM flag here
	bt 2, check3			#all work done in interrupt

check3:	
	cmpwi 0, r20, 0x01		#check for 4 LED Card Edge Flag
	bf 2, check4			#if flag not high branch to check4
	
	li r20, 0x0				#reset interrupt flag low
	lwz r2, 20(r1)			#load base address of 4 LED Card Edge
	lwz r31, 0(r2)			#load values from LED
	cmpwi 0, r14, 2200		#check for 600 interrupts (.6 Sec)
	bt 0, on				#once .6 reached turn LED's on
	b off					#if not keep them off
	
on:	cmpwi 0, r31, 0			#Check to see if LED's are off
	bf 2, no_reset			#if not off branch to no_reset
	lwz r2, 20(r1)			#load base address of 4 LED Card Edge
	li r31, 0xf				#vaue to turn on all 4 LED's
	stw r31, 0(r2)			#turn LED's on
	b no_reset				#branch to no_reset

off:	cmpwi 0, r31, 0		#check to see if LED's are off 
	bt 2, here				#if off branch to here
	lwz r2, 20(r1)			#load base address of 4 LED Card Edge
	li r31, 0x0				#value to turn off all 4 LED's
	stw r31, 0(r2)			#turn LED's off
	b here					#branch here

here:	cmpwi 0, r14, 3300	#check for total number of iterations
	bt 0, no_reset			#if reached branch to no_reset
	li r14, 0				#reset total count
        
no_reset:
	lwz r2, 8(r1) 			#load base address of timer2
	stw r15,TLR0(r2)     	#put long delay in time load register	

check4:	andi. r31, r3, 0x7000	#Check for Push Button flag
	bt 2, check5			#if not high branch to fifth check
		
	lwz r2, 12(r1)			#load base address of Push Buttons
	lwz r31,0(r2)          	#read buttons
	cmpwi 0, r31, 0			#check to see if buttons pushed
	bt 2, store1			#if not branch to store1
	xori r31, r31, 0x1f		#XOR to pull value of buttons pushed
store1:	lwz r2, 24(r1)		#base address of 5 Postional LED's
	stw r31,0(r2)          	#turn on 
	lis r31, 0xffff			#used to clear flag
	ori r31, r31, 0x0fff	#used to clear flag
	and r3, r3, r31			#clear Push Button flag

check5:	cmpwi 0, r21, 1		#check for FIT flag
	bf 2, check6			#if not high branch to sixth flag
	li r21,0				#clear flag
	lwz r31, 40(r0)
	addi r31, r31, 1		#increment counter
	lwz r2, 32(r1)			#Load base address of 32 "B" LED's
	stw r31, 0(r2)			#output count to to LED's
	stw r31, 40(r0)
	
check6:	lis r31, 0x00f0		#load r31 for AND in next instruction
	and. r31, r31, r3		#AND to check for PIT flag
	bt 2, check7			#if not PIT flag branch to check7

	lis r31, 0xff0f			#used to clear PIT flag	
	ori r31, r31, 0xffff	#used to clear PIT flag
	and r3, r3, r31			#clear PIT flag

	lwz r2, 28(r1)          #load 32 "A" base address
	lwz r31, 44(r0)
	stw r31, 0(r2)	       	#turn on LED's 
	addi r31, r31, 1		#increment counter
	stw r31, 44(r0)

	li r24, 0x5000			#base addr for char string
	li r23, 0				#offset for character string
	li r16, 10

	lwz r31, 44(r0)
	mr r19, r31
	lis r31, 0xffff
	ori r31, r31, 0xf000
	and r19, r19, r31
	lwz r31, 48(r0)
	cmp 0, r19, r31
	bt 2, same
	mr r31, r19
	stw r31, 48(r0)
	srwi r19, r19, 12
	bl hex_2_ascii
	li r17, 0x03
	bl putcmd

same:

check7:	cmpwi 0, r3, 0		#check for LCD flag
	bt 2, main_done			#branch to main_done

main_done:b main_loop		#branch back to top of main program


hex_2_ascii:	mflr r31
		li r23, 0			#set offset to 0
		divw. r5, r19, r22	#divide number by X
		bf 2, number		#branch if nonzero	
		divw. r22, r22, r16	#divide X by 10
		bt 2, zero			#branch if X is 0
		b hex_2_ascii		#branch to hex_2_ascii

number:		addi r5, r5, 0x30	#add number to 0x30
		bl store				#send char to UART
		subi r5, r5, 0x30
		mullw r11, r5, r22	#multiply x*number
		subf r19, r11, r19	#subtract from number
		divw. r22, r22, r16	#divide X/10
		bt 2, done			#branch if X = 0
		divw r5, r19, r22	#divide number/X
		b number			#branch to number

zero:		li r5, 0x30		#load with 0
		bl store			#send to UART
done:
		lis r22, 0x3b9a		#load top 4 hex for 100000000(X)
		ori r22, r22, 0xca00	#load bottom 4 hex for 100000000(X)
		mtlr r31
		blr
	

store:		mflr r18
		stwx r5, r24, r23	#store the count
		mr r17, r5
		bl putc
		mr r17, r18
		addi r23, r23, 4	#increment offset
		mtlr r18
		blr

#
# entry mode set
#
        li r4,0x06        # 
        bl putcmd
#
# function set= use 2 lines
#
        li r4,0x29
        bl putcmd
#
#
        nop
        nop
        li r4,0x39        # 9 = 0x48
        bl putc
        li r4,0x3a        # : = 0x65
        bl putc
        li r4,0x30        # 0 = 0x6C
        bl putc
        li r4,0x30        # 0 = 0x6C
        bl putc
        li r4,0x20        # Space = 0x6F
        bl putc
        li r4,0x41        # A
        bl putc
        li r4,0x4d        # M
        bl putc


wait100:
        li r29,2          # use r29 to send val
        mtctr r29         # to counter reg
w100a:  bdz w100b         # branch out when done
        b w100a           # not done - try again
w100b:  blr               # get out when done


wait300:
        li r29,12         # use r29 to send val
        mtctr r29         # to counter reg
w300a:  bdz w300b         # branch out when done
        b w300a           # not done - try again
w300b:  blr               # get out when done


wait1500:
        li r29,20          # use r29 to send val
        mtctr r29         # to counter reg
w1500a: bdz w1500b         # branch out when done
        b w1500a           # not done - try again
w1500b: blr               # get out when done


wait60us:
        li r29,2667       # use r29 to send val
        mtctr r29         # to counter reg
w60ua:  bdz w60ub         # branch out when done
        b w60ua           # not done - try again
w60ub:  blr               # get out when done


wait2ms:
        lis r29,0x0001    # use r29 to send val
        ori r29,r29,0x9000#
        mtctr r29         # to counter reg
w2msa:  bdz w2msb         # branch out when done
        b w2msa           # not done - try again
w2msb:  blr               # get out when done



putcmd: mflr r28          # save the value of the LR in r28.
        lis r30,0x8145    # point R30 at the LCD GPIO
        andi. r27,r17,0xf  # store in r27 the least significant bits of r17 
        srwi r26,r17,4     # shift r17 4 bits to the right and store in r26
        andi. r26,r26,0xf # now, zero everything but 4 LSBs
        stw r26,0(r30)    # send to LCD GPIO data lines
        bl wait100        # wait for 100 ns
        addi r26,r26,0x40 # when 0x40 is added to the LCD register
        stw r26,0(r30)    # the enable bit is set to '1'
        bl wait300        # wait for 300 ns
        subi r26,r26,0x40 # when 0x40 is subtracted from the LCD register
        stw r26,0(r30)    # the enable bit is set to '0'
        bl wait1500       # wait 1.5us     
        addi r26,r27,0    # load the value of r27 to r26
        stw r26,0(r30)    # store the value of the r26 in the LCD register    
        bl wait100        # wait 100ns
        addi r26,r26,0x40 # when 0x40 is added to the LCD register
        stw r26,0(r30)    # the enable bit is set to '1'
        bl wait300        # wait for 300ns
        subi r26,r26,0x40 # when 0x40 is subtracted from the LCD register
        stw r26,0(r30)    # the enable bit is set to '0'
        bl wait60us       # wait 60us (we only need 39us )
        mtlr r28          # write the value of r30 in LR
        blr



putc:   mflr r28          # save the value of the LR in r28.
        lis r30,0x8145    # point R30 at the LCD GPIO
        andi. r27,r17,0xf  # store 4 LSB in R27
        srwi r26,r17,4     # shirt r17 (input) right 4 bits; put in R26
        andi. r26,r26,0xf # zero everything but 4 LSBs
        li r25,0x20       # 0x20 corresponds to 1 in RS bit position
        add r26,r26,r25   # R26 now has RS bit 1, 4 MSBs of data
        stw r26,0(r30)    # store to LCD GPIO reg
        bl wait100        # and wait...
        addi r26,r26,0x40 # now add 1 in E bit position
        stw r26,0(r30)    # and store it out
        bl wait300        # and wait...
        subi r26,r26,0x40 # this removes bit from E position
        stw r26,0(r30)    # and stor it out
        bl wait1500       # and wait...
        li r25,0x20       # again, 0x20 has 1 in RS bit position
        add r26,r25,r27   # so, add this to other half - stored in R27
        stw r26,0(r30)    # and send out to LCD GPIO reg
        bl wait100        # and wait...
        addi r26,r26,0x40 # add 1 in E bit position
        stw r26,0(r30)    # and send to LCD
        bl wait300        # and wait...
        subi r26,r26,0x40 # now, remove bit from E position
        stw r26,0(r30)    # and send it out
        bl wait60us       # and wait...
        mtlr r28          # copy the value of r28 to LR
        blr               # and return

#
#
#
#
################ just added for lcd ####################
chkctrl: addi r6,r25,0       # copy data to R6
        andi. r27,r25,0x7F   # get just the char bits
        cmplwi 0,r27,0x01    # compare to 0x01 - Ctrl-A
        bf 2,chk02           # if not 0x01, check 0x02
        li r4,0x01           # this pattern clears display
        bl putcmd            # call the command routine
        li r7,0x1111         #debug stuff
        b goout              # boggie on out
chk02:  cmplwi 0,r27,0x02    # compare to 0x02 - Ctrl-B
        bf 2,chk03           # if not 0x02, go check 0x03
        li r4,0x03           # pattern: cursor to load point
        bl putcmd            # call the command routine
        li r7,0x2222         #debug stuff
        b goout              # boggie on out
chk03:  cmplwi 0,r27,0x03    # compare to 0x03 - Ctrl-C
        bf 2,chk04           # if not 0x03, go check 0x04
        li r4,0x04           # pattern: set direction r-to-l
        bl putcmd            # call the command routine
        li r7,0x3333         #debug stuff
        b goout              # boggie on out
chk04:  cmplwi 0,r27,0x04    # compare to 0x04 - Ctrl-D
        bf 2,chk05           # if not 0x04, go check 0x05
        li r4,0x06           # pattern: set direction l-to-r
        bl putcmd            # call the command routine
        li r7,0x4444         #debug stuff
        b goout              # boggie on out
chk05:  cmplwi 0,r27,0x05    # compare to 0x05 - Ctrl-E
        bf 2,chk06           # if not 0x05, go check 0x06
        li r4,0x08           # pattern: turn off display
        bl putcmd            # call the command routine
        li r7,0x5555         #debug stuff
        b goout              # boggie on out
chk06:  cmplwi 0,r27,0x06    # compare to 0x06 - Ctrl-F
        bf 2,chk07           # if not 0x06, go check 0x07
        li r4,0x0F           # pattern: turn on display
        bl putcmd            # call the command routine
        li r7,0x6666         #debug stuff
        b goout              # boggie on out
chk07:  cmplwi 0,r27,0x07    # compare to 0x07 - Ctrl-G
        bf 2,chk08           # if not 0x07, go check 0x08
        li r4,0xC0           # pattern: position cursor BL
        bl putcmd            # call the command routine
        li r7,0x7777         #debug stuff
        b goout              # boggie on out
chk08:  cmplwi 0,r27,0x08    # compare to 0x08 - Ctrl-H
        bf 2,chk09           # if not 0x08, go check 0x09
        li r4,0x80           # pattern: position cursor TL
        bl putcmd            # call the command routine
        li r7,0x0888         #debug stuff
        b goout              # boggie on out
chk09:  cmplwi 0,r27,0x09    # compare to 0x09 - Ctrl-I
        bf 2,chk10           # if not 0x09, go check 0x0A
        li r4,0x0C           # pattern: display on, cursor off
        bl putcmd            # call the command routine
        li r7,0x0999         #debug stuff
        b goout              # boggie on out
chk10:  cmplwi 0,r27,0x0A    # compare to 0x0A - Ctrl-J
        bf 2,goout           # if not 0x0A, go check
        li r4,0x0E           # pattern: 
        bl putcmd            # call the command routine
        li r7,0x0999         #debug stuff
        b goout              # boggie on out
goout:	rfi 

##############################################################################		
#
#  External critical-interrupt signal
        .org 0x10100
        nop
        nop
herea:  b herea
#
#  External bus error
        .org 0x10200
        nop
        nop
hereb:  b hereb
#
#  Data-access violation
        .org 0x10300
        nop
        nop
herec:  b herec
#
        .org 0x10400
        nop
        nop
hered:  b hered
#
#  External noncritical-interrupt signal
#
        .org 0x10500		
	stmw r22, 0(r0)		#store registers r22 - r31
	lmw r22, 0(r1)		#load array of base addresses to r22 - r31
	li r10, 0			#constant 0
	lwz r9,0(r31)		#load INTC status register
	li r13, 4			#constant 4
	and r9, r9, r13		#checking push button interrupt
	cmpwi 2, r9, 4		#check to see if pushed
	bf 10, around		#branch if no interrupt
	ori r3, r3, 0x7000	#setting the Push Button flag
	li r9,0x01          	#set LSB of r15, then
        stw r9,IPISR(r25)   	#write to IPISR to clear bit
	addi r10, r10, 4	#set bit for IAR

around: lwz r9,0(r31)      	#load INTC status register
	li r13, 8			#used for compare
	and r9, r9, r13		#checking UART interrupt
	cmpwi 3, r9, 8		#checking UART interrupt
	bf 14, around2		#if not UART branch around
	ori r3, r3, 0x0007	#set UART flag high
	addi r10, r10, 8	#set bit for IAR

around2:lwz r9,0(r31)		#load INTC status register
	li r13, 2			#used to check for PWM
	and r9, r9, r13		#checking PWM interrupt
	cmpwi 3, r9, 2		#compare PWN interrupt
	bf 14, around3		#if not branch around3

        li r9,0x07D6         	#clear int bit
        lis r6, timer1       	#pointer for timer1
        stw r9,TCSR0(r6)    	#to timer1 TCSRO
	addi r10, r10, 2	#setting PWM flag high
        li r9,0x9AB     #75% value
	cmp 2, r12, r9		#checking PWM interrupt
	bt 10, sover		#if so branch to sover
        addi r12,r12,0x14A    	#add 10% 
        b go_on 		#branch to go_on
sover:  li r12,0x339          	#25% value
go_on:  lis r6, timer1       	#pointer for timer1
        stw r12,TLR1(r6)     	#putPWM value to timer
around3:lwz r9,0(r31)		#load INTC status register
	li r13, 1			#flag for PWM
	and r9, r9, r13		#checking for flag
	cmpwi 3, r9, 1		#checking for flag
	bf 14, around4		#if not branch around4
	addi r14, r14, 1	#set high

	lwz r6, 8(r1)		#address of TIMER 2
        li r9,0x3D6     	#clear interrupt status 0x3D6
        stw r9,TCSR0(r6) 	#bits for time control/status register

	li r20, 0x01		#set interrupt flag high
	addi r10, r10, 1      	#value for interrupt acknowledge 

around4:
        stw r10,IAR(r31)     	#clear bit in INTC

	lmw r22, 0(r0)		#load array of base addresses to r22 - r31
        rfi                  	#return to main program

#
#
#  Programmable Interval Timer
        .org 0x11000
	oris r3, r3, 0x00F0	#Set PIT flag for main program
	lis r9, 0x0800		#stroke PIS bit
	mtspr 0x3d8, r9		#move to TSR Timer Status Register
	rfi			#return from interrupt
#
#  Fixed-Interval Timer
        .org 0x11010
	li r21, 1		#set FIT flag high
	lis r9, 0x0C00		#stroke FIS bit
	mtspr 0x3d8, r9		#move to Timer Status Register TSR
	rfi			#return from interrupt






