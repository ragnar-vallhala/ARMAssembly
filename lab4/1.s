.global _start

.data 
    list: .space 12

_start:
    ldr R0, =list
    mov R2,#0
    BL looper
    mov R7, #1
    swi 0

looper:
    cmp R5,#4
    beq save
    cmp R2,#3
    bge terminate
    add R2,#1
    mov R4,#0
    mov R5,#0
    left: 
        add R1,#1
        add R5,#1
        lsl R4,#8
        orr R4,R1
        cmp R5,#4
        blt left
        bal looper

save:
    mov R5,#0
    str R4,[R0],#4
    BAL looper

terminate:
    bx lr
        
