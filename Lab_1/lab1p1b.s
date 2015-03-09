##       EECE 344L - Microprocessors - Fall 2011##       Name: Vicente Leyba##       Laboratory Number: Lab 1 Part 1.2              Due Date: 9-11-11##       Lab Group: Done Individually## *****************************************************************************************##       Purpose: ##       Store 8 memory locations by halfword with increasing order starting at 0x01020304 and#       ending at 0x08090A0B.## ********************************************************************************************	.org 0x1000	#start this at 1000	li  r8, 0x1200	#set r8 as pointer	lis r0, 0x0102		#01020000 to r0	lis r1, 0x0203		#02030000 to r1		lis r2, 0x0304		#03040000 to r2	lis r3, 0x0405		#04050000 to r3	lis r4, 0x0506		#05060000 to r4	lis r5, 0x0607		#06070000 to r5	lis r6, 0x0708		#07080000 to r6	lis r7, 0x0809		#08090000 to r7		ori r0,r0, 0x0304	#r0 should be 01020304	ori r1,r1, 0x0405	#r1 should be 02030405	ori r2,r2, 0x0506	#r2 should be 03040506	ori r3,r3, 0x0607	#r3 should be 04050607	ori r4,r4, 0x0708	#r4 should be 05060708	ori r5,r5, 0x0809	#r5 should be 06070809	ori r6,r6, 0x090A	#r6 should be 0708090A		ori r7,r7, 0x0A0B	#r7 should be 08090A0B		sth r0, 0(r9)		# Store halfword r0 to memory r9	sth r1, 2(r9)		# Store halfWord r1 to memory r9	sth r2, 4(r9)		# Store halfWord r2 to memory r9	sth r3, 6(r9)		# Store halfword r3 to memory r9	sth r4, 8(r9)		# Store halfword r4 to memory r9	sth r5, 10(r9)		# Store halfword r5 to memory r9	sth r6, 12(r9)		# Store halfword r6 to memory r9	sth r7, 14(r9)		# Store halfword r7 to memory r9		nop					# No Operation	ori 0,0,0,			# No Operationhere: b here