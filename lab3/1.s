.global _start

.data
    list:
        .space 12

loop:
    ADD R3,#1
    STRB R2,[R0],#1
    ADD R2,#1
    CMP R3,#9
    BLE loop
    BX lr


_start:

    LDR R0,=list
    MOV R1,#100
    MOV R2,#110
    MOV R3,#0
    BL loop
    MOV R7, #1
    SWI 0
    

