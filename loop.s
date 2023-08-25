// .global start

// start:
//     MOV R0,#0

// loop:
//     CMP R0,#0x20
//     BEQ default
//     ADD R0,R0,#2
//     BAL loop
// default:
//     MOV R7,#0xff
//     SWI 0



//ADDS Number from a list
.global start
//.equ  num , #0x81818181     //Constant
start:
    LDR R0,=list
    MOV R1,#0
    MOV R3,#0

loop:
    
    LDR R2,[R0,R5]
    ADD R5,R5,#4
    ADD R4, R2,R1
    MOV R1,R4
    ADD R3,R3,#1
    CMP R3,#10
    BLT loop
    BAL end


list:
    .word 1,2,3,4,5,6,7,8,9,10

end:
    swi 0



/*
Conditional statement

ADDLT add if less than
MOVGE
etc

*/