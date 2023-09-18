.global _start
_start:
    MOV R0, #5
    MOV R2,R0
    MOV R1,#3
    MOV R3,#0
    B divide
    SWI 0


divide:
    CMP R2,R1
    BLT greater
    SUB R2,R2,R1
    ADD R3,R3,#1
    BAL divide

greater:
    BX lr

