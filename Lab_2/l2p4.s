 #*************************************************************
#
#	EECE 344L - Microprocessors - Fall 2011
#
#	Name:Vicente Leyba
#
#
#	Laboratory Number: Lab 2 Part 4	       Due Date:9/27/2011
#
#
#
#	Lab Group: Worked Individually 
#
#
#
#***************************************************************
#
#	Purpose: Devise an instruction sequence that will implement
#     for (i=0;i<250;i++) {
#       A = A + B * 3;
#       C = C – D / 27;
#       B = B + 2;
#       D = D + B; 
#		}
#
#***************************************************************       
		
		
		.org 0x1000
		
        li r1, 0x2000           #use as value for pointer in memory
        li r2, 88               #load 88 into gpr r2 A =88
        li r3, 60               #load 60 into grp r3 B=60
        li r4, 8080             #load 8080 into gpr r4 C=8080
        li r5, 13               #load 13 into gpr r5 D = 13
        li r6, 250              #load 250 into gpr r6. 
        mtctr r6                #move value of r6 to mtctr
        li r7, 3                #load 3 into gpr r7
        li r8, 27               #load 27 into gpr r8
        li r11, 0               #load 0 into grp r11 used for counting number of iterations
        
while:
        mulli r9, r3, 3         #multiply B*3
        add r2, r2, r9          #add A+(B*3)
        divw r10, r5, r8        #divide D/27
        sub r4, r4, r10         #C=C-(D/27)
        addi r3, r3, 2          #B=B+2
        add r5, r5, r3          #D=D+B
        cmpi 1, r4, 0           #compare C to 0
        bt 5, ct                #if c > 0 branch to count loop
        b endif                 #continue in while loop
ct:
        addi r11, r11, 1        #increment number of counts for C > 0
        b endif                 #continue in while loop
endif:
        bdnz while              #decrement counter
        
        stw r2, 0(r1)           #store A
        stw r3, 4(r1)           #store B
        stw r4, 8(r1)           #store c
        stw r5, 12(r1)          #store D
        stw r11, 16(r1)         #store number of counts for C < 0
                
here: b here
