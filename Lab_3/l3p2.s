#*************************************************************
#
#	ECE 344L - Microprocessors - Fall 2011
#
#	Name: Vicente Leyba	
#
#
#	Laboratory Number: Lab 3 Part2		Due Date: 10/11/2011
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
#	Write a program that continuously sends characters to the UART
#
#***************************************************************

	.set RXFIFO, 0x00       #Receive FIFO
	.set TXFIFO, 0x04       #Transmit FIFO
	.set STATREG, 0x08      #Status Register
	.set UART, 0x8400       #UART

	.org 0x1000             #program starting memory

	lis r8, UART            #Point to UART


read:

	lwz r9, STATREG(r8)     #r9 gets UART status
	andi. r0, r9, 1 		#Is UART ready to read?
	cmpi 0, r0, 1
	bf 2, read              #Not ready, skip
	lwz r10, RXFIFO(r8)     #Put character in r10

write:	

	lwz r9, STATREG(r8)     #r9 gets UART status
	andi. r0, r9, 4         #Check if transmit FIFO is empty
	cmpi 0, r0, 4
	bf 2, write             #branches if not ready to read
	stw r10, TXFIFO(r8)     #Send character from r10 to transmit
      lwz r9, STATREG(r8)	#r9 gets UART status
	andi. r0, r9, 1 	    #Is UART ready to read?
	cmpi 0, r0, 1
	bf 2, write             #continues writing
	b read                  #branches back to read
