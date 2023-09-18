.global _start

.data 
    list: .space 12

_start:
    mov R1,#82
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
    mov R8,#8
    left: 
        add R1,#1
        add R5,#1
        mov R7,R5
        add R7,#-1
        mul R7,R8
        mov R6,R1
        lsl R6,R7
        orr R4,R6
        cmp R5,#4
        blt left
        bal looper

save:
    mov R5,#0
    str R4,[R0],#4
    BAL looper

terminate:
    bx lr
        
