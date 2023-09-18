.global _start

_start:

	ldr r0,=list
	ldr r1,[r0]
	add r1,#1
	str r1,[r0,#4]
	add r1,#1
	str r1,[r0,#8]
	add r1,#1
	str r1,[r0,#12]
	add r1,#1
	str r1,[r0,#16]
	add r1,#1
	str r1,[r0,#20]
	add r1,#1
	str r1,[r0,#24]
	add r1,#1  
	str r1,[r0,#28]
	add r1,#1
	str r1,[r0,#32]
	add r1,#1
	str r1,[r0,#36]
	

.data
list:
	.word 103

