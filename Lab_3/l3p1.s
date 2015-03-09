#************************************************************************************************
#
#	ECE 344L - Microprocessors - Fall 2011
#
#	Name: Vicente Leyba	
#
#
#	Laboratory Number: Lab 3 Part1		Due Date: 10/1/2011
#
#
#
#	Lab Group: Worked Individually 
#
#
#
#************************************************************************************************
#
#	Purpose:
#
#
#	Write a routine that will echo characters typed on the terminal.  The tricky activity required in this part of the laboratory is to not only echo the characters, but also keep a copy the last line of characters (characters since the last EOL).  Then, when EOL occurs, add another copy of that line, reversing the case of the letters.
#
#************************************************************************************************

	  .set UARTLITE, 0x84000000                 # address for URARTLITE
        .set RXFIFO, 0x0                        # address offset for RXFIFO Receive
        .set TXFIFO, 0x4                        # address offset for TXFIFO Transmit
        .set STATREG, 0x8                       # address offset for status register
        .set CTRLREG, 0xC                       # address for control register

        .org 0x1000                             # program origin
		
        li r1, 0x2000                           # pointer to mem.
        li r2, 0                                # initial value of reg. to keep count of how many  chars are stored in mem.
		
begin:  
		
		lis r8, UARTLITE@h                      # load pointer to uart (upper 16 bits)

over:   

        lwz r9, STATREG(r8)                     # get contents of status to r9
        andi. r9,r9, 1                          # is LSB = 1? stick the result of the compare in the  condition register.
        bt 2, over                              # If no character try again
                                                # If character is in UARTLITE then continue loop
        lwz r10, RXFIFO(r8)                     # go get char out of RXFIFO and stick in r10
        cmpi 2, r10, 13                         # look for carriage return in RXFIFO
        bt 10, out                              # if line Carriage return branch to loop to output
        stw r10, TXFIFO(r8)                     # send it out to terminal
        stw r10, 0(r1)                          # stores word for char in to mem location
        addi r1, r1,4                           # increments pointer mem location for next word
        addi r2,r2,1                            # increments r2 to keep count of # of chars. typed
        b over

out:

        li r25, 0xd                             # set r25 with carriage return
        bl check                                # branch and link to check
        li r25, 0xa                             # set r25 with new line feed

bl check                                        # branch and link to check
        mr r4,r2                                # initialize counter
        mtctr r4                                # set counter to r2 value
        li r1, 0x2000                           # resets the pointer

out1:
        lwz r25, 0(r1)                          # moves value in mem location to r25
        bl check                                # branch and link to check
        addi r1,r1,4                            # shifts mem. location by one word length
        bdnz out1                               # decrement counter and loop
        li r25, 0xd                             # set r25 with carriage return
        bl check                                # branch and link to check
        li r25, 0xa                             # set r25 with new line feed
        bl check                                # branch and link to check
        li r2, 0                                # resets counter
        li r1, 0x2000                           # resets pointer mem location                                           
        b over                                  # return to top look for next sequence of chars                          
        
check:
        lwz r9, STATREG(r8)                     # get contents status to r9
        andi. r9,r9, 8                          # Check to see if TXFIFO is full
        bf 2, check                             # If yes branch to a wait       i
        cmpi 1, r25, 64                         #check if calue is a letter 
        bt 5, print                             #go to print if calue is any letter
        stw r25, TXFIFO(r8)                     # send out previous value to terminal if not a letter
        blr                                     # return from link

print:
        cmpi 1, r25, 96                                 
        bt 5, print1                            #an upper case letter to to print1
        addi r25, r25, 32                       #convert to uppercase leter
        stw r25, TXFIFO(r8)                     #send out value to terminal
        blr                                     #return from link

print1: 
        subi r25, r25, 32                       #convert to lowercase letter
        stw r25, TXFIFO(r8)                     #send out value to terminal
        blr                                     #return from link
        
here: b here