.data 
    num1: .word -2                  @ multiplier
    num2: .word  4                  @ multiplicand
    mul_res: .word 0x0,0x0          @ result of the product   
    args: .space 40, 0x0            @ arguments list to any called function
    nargs: .word 0x0                @ number of arguments to be read by the function
    results: .space 40, 0x0         @ result list of any called function
    nresults: .word 0x0             @ number of result returned by the function
    
    
.global _start

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@                                                                                                                      @
@                                Variable Summary                                                                      @
@                               ------------------                                                                     @
@          Variable                                      Purpose                                                       @
@          --------                                     ---------                                                      @
@          num1                                   first operands - multiplicand                                        @
@          num2                                   second operands - multipliplier                                      @
@          mul_res                                result of multiplication in little endian                            @
@          args                                   list of arguments supplied to any called function - size 40 bytes    @
@          nargs                                  number of arguments provided to the called function                  @
@          results                                list of results returned from a function - size 40 bytes             @
@          nresults                               number of results returned from the function                         @
@                                                                                                                      @
@                                                                                                                      @
@                                                                                                                      @
@                                                                                                                      @
@                                                                                                                      @
@                                                                                                                      @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@





_start:

    bl booth_mul_algo       @ calling the booth multiplication algorithm

    bal terminate


terminate:
    @program ends here
    swi 0





booth_mul_algo:
    push {lr}
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}

    ldr r0,=num1
    ldr r1,[r0]                 @First operand --- Multiplier
    ldr r0,=num2
    ldr r2,[r0]                 @Second operand --- Multiplicand
    mov r3,#0                   @ index of bit in multiplier that is active
    mov r4,#0                   @ start of 1's sequence currently active

    mov r5,#0                   @ less significant part of the result
    mov r6,#0                   @ more significant part of the result

    neg r7,r2                   @ holds negative of the multiplicand

    outer_loop_booth:
        cmp r1,#0
        beq outer_loop_booth_end
        mov r8,#0               @ flag: checks if 1 is found in the upcoming inner loop

        inner_loop_booth:
            mov r9,#1
            and r9,r1
            cmp r9,#0
            beq inner_loop_booth_end
            mov r8,#1
            add r3,#1
            @right shifting multiplier      --- It's only 32 long and right shifting won't need more bits so it's normal lsr
            lsr r1,#1
            bal inner_loop_booth

        inner_loop_booth_end:
            if_inner_loop_booth_end:
                cmp r3,r4
                beq endif_inner_loop_booth_end
                push {r0,r8,r9,r10,r11,r12}         @ spilling registers to create more space

                @getting arguments list
                ldr r0,=args
                str r2,[r0]                         @ putting arguments for left shifting 
                mov r8,#0                           @ putting arguments for left shifting 
                str r8, [r0,#4]                     @ putting arguments for left shifting 
                str r8, [r0,#8]                     @ putting arguments for left shifting 
                str r3, [r0,#12]                    @ putting arguments for left shifting 
                bl looped_shift_left                @ left shift loop called

                ldr r0,=results
                ldr r8,[r0]
                ldr r9,[r0,#4]

                @ getting arguments list
                ldr r0,=args
                str r5,[r0]
                str r6,[r0,#4]
                str r8,[r0,#8]
                str r9,[r0,#12]
                bl summation_64

                @ laoding back results
                ldr r0,=results
                ldr r5,[r0]
                ldr r6,[r0,#4]


                @ not part of the summation
                @ getting arguments list
                ldr r0,=args
                str r7,[r0]                         @ putting arguments for left shifting 
                mov r8,#0                           @ putting arguments for left shifting 
                str r8, [r0,#4]                     @ putting arguments for left shifting 
                str r8, [r0,#8]                     @ putting arguments for left shifting 
                str r4, [r0,#12]                    @ putting arguments for left shifting 
                bl looped_shift_left                @ left shift loop called

                ldr r0,=results
                ldr r8,[r0]
                ldr r9,[r0,#4]

                @ getting arguments list
                ldr r0,=args
                str r5,[r0]
                str r6,[r0,#4]
                str r8,[r0,#8]
                str r9,[r0,#12]
                bl summation_64

                @ laoding back results
                ldr r0,=results
                ldr r5,[r0]
                ldr r6,[r0,#4]

                pop {r0,r8,r9,r10,r11,r12}          @ restoring registers

            endif_inner_loop_booth_end:

            if_inner_loop_booth_end_found_one:
                cmp r8,#0
                bne endif_inner_loop_booth_end_found_one
                add r3,#1 
            endif_inner_loop_booth_end_found_one:
            mov r4,r3
            lsr r1,#1
            bal outer_loop_booth
    outer_loop_booth_end:

    booth_mul_algo_end:
        ldr r0,=mul_res
        str r5,[r0]
        str r6,[r0,#4]
        pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}
        pop {pc}






@--------+++++++++++======================++++++++++----------@
@--------+++++++++++======================++++++++++----------@
@--------+++++++++++======================++++++++++----------@
@                                                             @
@                                                             @
@                   Helper Functions Below                    @
@                                                             @
@                                                             @
@--------+++++++++++======================++++++++++----------@
@--------+++++++++++======================++++++++++----------@
@--------+++++++++++======================++++++++++----------@



pow:
    @expects the base as first argument
    @expects the exponent as second argument
    push {lr}
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}                    @register spilling

    @actual exponentiation code
    ldr r0,=args
    ldr r1,[r0]
    ldr r2,[r0,#4]

    cmp r1,#0
    beq zero_ret                                            @ incase base is zero we return zero 
    mov r3,#1

    exponent_loop:
        cmp r2,#0
        beq exponent_end
        mul r3,r1
        sub r2,#1
        bal exponent_loop
    
    zero_ret:
        ldr r0, =results                                    @ pushing the result to the results array
        str r1,[r0]                                         @ pushing the result to the results array
        mov r1,#1                                           @ pushing the result to the results array
        ldr r0, =nresults                                   @ pushing the result to the results array
        str r1,[r0]                                         @ pushing the result to the results array
        bal exponent_end                                    @ pushing the result to the results array
 
    exponent_end: 
        ldr r0,=results                                     @ pushing the result to the results array
        str r3,[r0]                                         @ pushing the result to the results array
        mov r3,#1                                           @ pushing the result to the results array
        ldr r0,=nresults                                    @ pushing the result to the results array
        str r3,[r0]                                         @ pushing the result to the results array
        pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}                 @ repopulating the registers
        pop {pc}






right_shift_64:
    @ right shift operator for 64 bit integer
    @ it expects two arguments
    @       1. the operand to perform sift on in first two registers
    @       2. whether dropped bit is needed in result   -- it has to be either 0 or 1 
    @ it returns two values conditionally
    @       1. the result in first two register in little endian
    @       2. dropped bit in third register if asked by second argument
    @ 
    @ 
    push {lr}
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}

    bl clear_results                                    @clearing results

    ldr r0,=nargs
    ldr r1,[r0]
    ldr r0,=args
    ldr r2, [r0]
    ldr r3, [r0,#4]
    ldr r1, [r0,#8]

    mov r6,#1                                           @Filling blanks with F or 0    
    lsl r6,#31                                          @Filling blanks with F or 0       
    and r7,r6,r2                                        @Filling blanks with F or 0 
    cmp r7,#0                                           @Filling blanks with F or 0 
    beq zero_fill_right_shift                           @Filling blanks with F or 0 
    cmp r3,#0                                           @Filling blanks with F or 0 
    bne zero_fill_right_shift                           @Filling blanks with F or 0 
    cmp r6,r2                                           @Filling blanks with F or 0
    beq zero_fill_right_shift                           @Filling blanks with F or 0
    mov r3,#-1                                          @Filling blanks with F or 0 

    zero_fill_right_shift:



    mov r4,#1                                               @ number of results to returned
    cmp r1,#1
    beq dropped_bit_needed_right_shift

    calculate_right_shift:

        @returning the number of results
        ldr r0,=nresults
        str r4,[r0]

        @calculating the right shift
        mov r5,#1
        and r5,r3                                           @dropping bit from the significant part
        lsl r5,#31                                          @shfiting to position of msb in second half
        lsr r3,#1       
        lsr r2,#1
        orr r2,r5                                           @adding last bit of r3 to r2

        @pushing results to the result list
        ldr r0,=results
        str r2,[r0]
        str r3,[r0,#4]

        @ending the function
        bal right_shift_64_end


    dropped_bit_needed_right_shift:
        @returning the dropped bit
        and r5,r4,r2
        ldr r0,=results
        str r5,[r0,#8]

        @returning the number of results
        add r4,#1

        @ending the function
        bal calculate_right_shift


    right_shift_64_end:
        pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}
        pop {pc}





left_shift_64:
    @ right shift operator for 64 bit integer
    @ it expects two arguments
    @       1. the operand to perform sift on in first two registers
    @       2. whether dropped bit is needed in result   -- it has to be either 0 or 1 
    @ it returns two values conditionally
    @       1. the result in first two register in little endian
    @       2. dropped bit in third register if asked by second argument
    @ 
    @ 
    push {lr}
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}

    bl clear_results                                    @clearing results

    ldr r0,=nargs
    ldr r1,[r0]
    ldr r0,=args
    ldr r2, [r0]
    ldr r3, [r0,#4]
    ldr r1, [r0,#8]

    mov r6,#1                                           @Filling blanks with F or 0    
    lsl r6,#31                                          @Filling blanks with F or 0       
    and r7,r6,r2                                        @Filling blanks with F or 0 
    cmp r7,#0                                           @Filling blanks with F or 0 
    beq zero_fill_left_shift                            @Filling blanks with F or 0 
    cmp r3,#0                                           @Filling blanks with F or 0 
    bne zero_fill_left_shift                            @Filling blanks with F or 0
    cmp r2,r6                                           @Filling blanks with F or 0 
    beq zero_fill_left_shift                            @Filling blanks with F or 0 
    mov r3,#-1                                          @Filling blanks with F or 0 

    zero_fill_left_shift:


    mov r4,#1                                           @ number of results to returned
    cmp r1,#1
    beq dropped_bit_needed_left_shift

    calculate_left_shift:

        @returning the number of results
        ldr r0,=nresults
        str r4,[r0]

        @calculating the left shift
        mov r5,#1
        lsl r5,#31                                      @bit mask to get msb
        and r5,r2                                       @dropping bit from the significant part
        lsr r5,#31                                      @shfiting to position of msb in second half
        lsl r3,#1       
        lsl r2,#1
        orr r3,r5                                       @adding last bit of r3 to r2

        @pushing results to the result list
        ldr r0,=results
        str r2,[r0]
        str r3,[r0,#4]

        @ending the function
        bal left_shift_64_end


    dropped_bit_needed_left_shift:
        @returning the dropped bit
        mov r5,#1
        lsl r5,#31
        and r5,r3
        lsr r5,#31
        ldr r0,=results
        str r5,[r0,#8]

        @returning the number of results
        add r4,#1

        @ending the function
        bal calculate_left_shift


    left_shift_64_end:
        pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}
        pop {pc}




looped_shift_left:
    @It need three arguments 
    @   1. First two registers need to be the operand to be left shifted in little endian format
    @   2. Next register contains whether drop bit is need 
    @   3. Last register contains the number of shifts performed 
    push {lr}
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}

   
    main_loop_for_left_shift:
        ldr r0,=args
        ldr r1,[r0,#12]
        cmp r1,#0                                   @checking the iterator 
        beq end_left_shift_loop
        sub r1,#1                                   @decreasing the iterator
        str r1,[r0,#12]                             @loading the new value of iterator for next step

        bl left_shift_64                            @performing the shift
        
        @tranfering the results as arguments for next round of shifting
        ldr r0,=results                 
        ldr r1,[r0]
        ldr r2,[r0,#4]
        ldr r0,=args
        str r1,[r0]
        str r2,[r0,#4]

        bal main_loop_for_left_shift
        
    
    end_left_shift_loop:
        pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}
        pop {pc}


looped_shift_right:
    @It need three arguments 
    @   1. First two registers need to be the operand to be right shifted in little endian format
    @   2. Next register contains whether drop bit is need 
    @   3. Last register contains the number of shifts performed 
    push {lr}
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}

   
    main_loop_for_right_shift:
        ldr r0,=args
        ldr r1,[r0,#12]
        cmp r1,#0                                           @checking the iterator 
        beq end_right_shift_loop                    
        sub r1,#1                                           @decreasing the iterator
        str r1,[r0,#12]                                     @loading the new value of iterator for next step

        bl right_shift_64                                   @performing the shift
        
        @tranfering the results as arguments for next round of shifting
        ldr r0,=results                 
        ldr r1,[r0]
        ldr r2,[r0,#4]
        ldr r0,=args
        str r1,[r0]
        str r2,[r0,#4]

        bal main_loop_for_right_shift
        
    
    end_right_shift_loop:
        pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}
        pop {pc}



summation_64:
    @This function adds two 64 bit numbers    
    @It expects three arguments
    @   1. First two registers contains the first operand 
    @   2. Next two registers contains the second operand
    @   3. Whether carry is needed in result   -- value of this argument is to be 0 or 1 
    @The result is has two values if carry is needed
    @   1. First two registers contains the addition result
    @   2. Next register conatin the overflow if asked in the argument
    push {lr}
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}                @spilling registers

    bl clear_results                                    @clearing results

    @loading arguments to registers
    ldr r0,=args
    ldr r1,[r0]
    ldr r2,[r0, #4]
    ldr r3,[r0, #8]
    ldr r4,[r0, #12]
    ldr r5,[r0, #16]

    mov r6,#1                                           @Filling blanks with F or 0    
    lsl r6,#31                                          @Filling blanks with F or 0       
    and r7,r6,r1                                        @Filling blanks with F or 0 
    and r8,r6,r3                                        @Filling blanks with F or 0 
    cmp r7,#0                                           @Filling blanks with F or 0 
    beq zero_fill_first_op                              @Filling blanks with F or 0 
    cmp r2,#0                                           @Filling blanks with F or 0 
    bne zero_fill_first_op                              @Filling blanks with F or 0
    cmp r1,r6                                           @Filling blanks with F or 0 
    beq zero_fill_first_op                              @Filling blanks with F or 0 
    mov r2,#-1                                          @Filling blanks with F or 0 

    cmp r8,#0
    beq zero_fill_second_op
    cmp r4,#0
    bne zero_fill_second_op
    cmp r3,r6
    beq zero_fill_second_op
    mov r4,#-1

    zero_fill_first_op:
    zero_fill_second_op:


    @adding the numbers and getting the carry
    mov r6,#0
    adds r1,r3
    adc  r2,r4
    adc  r6,#0

    @putting result of addition to memory
    ldr r0,=results
    str r1,[r0]
    str r2,[r0, #4]

    @check if carry is asked
    cmp r5,#0
    beq end_summation_64
    str r6,[r0,#8]
    bal end_summation_64

    end_summation_64:
        @end the function
        pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}     @repopulating the registers
        pop {pc}



clear_results:
    push {lr}
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}
    mov r1,#0
    ldr r0,=results
    str r1,[r0]
    str r1,[r0,#4]
    str r1,[r0,#8]
    str r1,[r0,#12]
    str r1,[r0,#16]

    pop {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9}
    pop {pc}