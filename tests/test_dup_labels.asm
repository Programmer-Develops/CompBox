// Test file for Part B Extra Feature (K = 14 -> K mod 3 = 2)
// Prints a warning whenever the same label is written twice.

(START)
    @10
    D=A
    @counter
    M=D

(LOOP)
    @counter
    MD=M-1
    @END
    D;JEQ
    @LOOP
    0;JMP

// Intentional duplicate label declarations to trigger warnings:
(LOOP)
    @0
    D=A

(END)
    @END
    0;JMP

(END)
    @START
    0;JMP
