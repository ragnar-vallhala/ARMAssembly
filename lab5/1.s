.global _start
.data


_start:
    mov R2,#0xff
    add R1,R2,#0xff
    movcs r2,#5
    mov r7,#1
    swi 0
