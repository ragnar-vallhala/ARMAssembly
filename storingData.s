.global _start

_start:
    ldr R0, =list
    ldr R1,[R0]
    ldr R2, [R0],#4
    ldr R3, [R0],#4
    
.data   
list:
    .word 4,5,9,-8,10,78