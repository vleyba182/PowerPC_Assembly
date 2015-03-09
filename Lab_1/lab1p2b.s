# ##       EECE 344L - Microprocessors - Fall 2011##       Name: Vicente Leyba##       Laboratory Number: Lab1 Part2b              Due Date: 9-15-11##       Lab Group: Done Individually## *******************************************************************************##       Purpose: Similar to Part 1 but halfwords are now stored in memory## ****************************************************************************** 				.org 0x1000     #start this at 1000	li  r8, 0x1100			#Set r8 as pointer	lis r0, 0x0102			#01020000 to r0	lis r1, 0x0203			#02030000 to r1	lis r2, 0x0304			#03040000 to r2	lis r3, 0x0405			#04050000 to r3	lis r4, 0x0506			#05060000 to r4	lis r5, 0x0607			#06070000 to r5	lis r6, 0x0708			#07080000 to r6	lis r7, 0x0809			#08090A0B to r7	ori r0, r0, 0x0304		#01020304 to r0	ori r1, r1, 0x0405		#02030405 to r1	ori r2, r2, 0x0506		#03040506 to r2	ori r3, r3, 0x0607		#04050607 to r3	ori r4, r4, 0x0708		#05060708 to r4	ori r5, r5, 0x0809		#06070809 to r5	ori r6, r6, 0x090A		#0708090A to r6	ori r7, r7, 0x0A0B		#08090A0B to r7	stw r0,0(r8)			#store word to r8	stw r1,4(r8)			#store word to r8	stw r2,8(r8)			#store word to r8	stw r3,12(r8)			#store word to r8	stw r4,16(r8)			#store word to r8	stw r5,20(r8)			#store word to r8	stw r6,24(r8)			#store word to r8	stw r7,28(r8)			#store word to r8			lhz r9,  0(r8)			# Load byte from r9 to memory r8	lhz r10, 2(r8)			# Load bytefrom r10 to memory r8	lhz r11, 4(r8)			# Load byte from r9 to memory r8	lhz r12, 6(r8)			# Load byte from r9 to memory r8	lhz r13, 8(r8)			# Load byte from r9 to memory r8	lhz r14, 10(r8)			# Load byte from r9 to memory r8	lhz r15, 12(r8)			# Load byte from r9 to memory r8	lhz r16, 14(r8)			# Load byte from r9 to memory r8	nop			# No Operation	nop			# No Operationhere: b here