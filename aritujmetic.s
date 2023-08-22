.global _start

_start:
   
    ldr R0, = list
    ldr R1, [R0]
    ldr R2, [R0,#4]
    ADDS R3,R2,R1  //ADD with CPSR on
    ADC R3,R11      //ADD cary too
    mov R7,#1
    swi 0


.data 
list:
    .word 9,2,3,4,5