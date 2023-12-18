.data
my_data:   .byte 10, 9, 8, 7, 6, 5, 4,1,2,1,2,3,4,56,2,1, 3, 2, 1

.text

.global _start

_start:
    ldr r0, =my_data
    mov r1, #18

outer_loop:
    mov r2, r1
    mov r3, r0

inner_loop:
    ldrb r6, [r3]
    ldrb r7, [r3, #1]
    cmp r6, r7
    ble skip
    
    strb r6, [r3, #1]
    strb r7, [r3]

skip:
    add r3, #1
    sub r2, #1
    cmp r2, #0
    bne inner_loop

    sub r1, #1
    cmp r1, #0
    bne outer_loop

    swi 0
