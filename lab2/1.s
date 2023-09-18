.global _start

.data
    list:
        .word 
    

lop:
    STR R2,[R0],#4
    ADD R2,#1
    CMP R2,#10
    BLE lop
    BX lr


_start:
    LDR R0,=list
    MOV R2,#0
    BL lop
    MOV R7, #1
    SWI 0
    
