.global fxn

fxn:
    mov R0,#2
    mov R1,#-5
    bal fxn2
    adds r0,r1,R0
   

fxn2:
    swi 0