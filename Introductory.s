.global _start
_start:
    MOV R0, #4096
    MOV R7, #1
    MOV R3, R0
    SWI 0
