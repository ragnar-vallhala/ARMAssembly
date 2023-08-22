.global _start
_start:
    MOV R0, #0XFF
    MOV R1, #0XAF
    CMP R0,R1       //COMPARE


// COMMON BRANCHES ARE:
//     BLT      LESS THAN OR EQUAL TO
//     BLE      LESS THAN OR EQUAL TO
//     BGE      GREATER THAN OR EQUAL TO
//     BEQ      EQUAL TO
//     BNQ      NOT EQOAL TO


    BLT greater    //BGT branch greater than
    BAL default     //if condition is false BRANCH ALWAYS
    MOV R2,#4
greater:
    MOV R2,#2

default:

    swi 0