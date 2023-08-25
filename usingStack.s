.global start

start:
    MOV R0,#10
    MOV R1,#8
    PUSH {R0,R1}
    BL sum
    POP {R0,R1}
    B finish

sum:
    MOV R0,#10
    MOV R1,#8
    ADDS R3,R1,R2
    BX lr

finish:
    SWI 0