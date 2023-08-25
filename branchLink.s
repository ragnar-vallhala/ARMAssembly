.global start

start:
    MOV R0,#5
    MOV R1,#4
    BL add              //Branch LINK, Stores the address of the next instruction in the LR
    MOV R3,R2
    MOV R7,#1
    SWI 0
add:
    ADDS R2,R0,R1
    BX lr               //Branch Back to the LINK Register
