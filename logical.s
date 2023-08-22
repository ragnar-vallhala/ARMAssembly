.global _start

_start:
    MOV R0,#15
    MOV R1,#0XFF
//    AND R2,R0,R1
//    ANDS R3,R0,R1        //Complementry operation to set flag

    // ORR R2, R0,R1           //OR

    //EOR R2,R1,R0              //XOR
 
    //MVN R2,R0                   //NEGATES THE VALUE OF R0 IN R2

    //LSL R0,#1                   //logical left shift
    //mov R2,R0,LSL #2

    MOV R1, R0,ROR #1
    


    MOV R7,#1
    SWI 0