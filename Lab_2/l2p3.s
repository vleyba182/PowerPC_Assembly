#
#	ECE 344L - Microprocessors - Fall 2011
#
#	Name: Vicente Leyba
#
#	Labratory Number: Lab 2 Part3
#
#	Lab Group: Individial Lab	Due Date: 9/27/2011
#
#
#***************************************************************************
#
#
#	Purpose: Implement the following loop construct
#	while (M < N) do {
#       P = P + Q;
#       N = N – N/17;
#	}
#	
#***************************************************************************

	.org 0x1000             	       # Program start point

       li  r1, 0x2000          	       # pointer to mem location

       li  r2, 450                     # load r3 with val(M)= 450
       lis r3, 0x0134                  # load r4 with val(N)= 20,000,000
       ori r3, r3, 0x910C
       li  r4, 3443                    # load r5 with val(P)= 3456
       li  r5, 71                      # load r6 with val(Q)= 77
       li  r6, 17                      # load r7 with const 17 used
       li  r8, 0                       # count register for number of

check:
       cmpw 0, r2, r3                  # compairs M and N
       bt 0, dowhile                   # if M < N branch to loop
       bt 1, end                       # in M > N branch to finish

dowhile:

       add  r4, r4, r5                 # P= P+Q or r5 <= r5+r6
       divw r7, r3, r6                 # (N/17) stored into r8 forr
       subf r3, r7, r3                 # N= N-(N/17) or r4 <= r4-r8
       addi r8, r8, 1                  # counts iterations
       nop
       nop
       b check

end:
       stw r2, 0(r1)                   # stores post loop value of M into mem.
       stw r3, 4(r1)                   # stores post loop value of N into mem.
       stw r4, 8(r1)                   # stores post loop value of P into mem.
       stw r5, 12(r1)                  # stores post loop value of Q into mem.
       nop

here:   b here

