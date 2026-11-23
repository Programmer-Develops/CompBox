// Box.asm — Nand to Tetris I (ETCCNT301) Capstone Project
// Name: Shantanu Pandya | Roll No: 2501730014 | K = 14
//
// Draws a 48x20 black box starting at row 14 (left edge, RAM[16832])
// while any key is pressed, and clears it when the key is released.
//   Start address : SCREEN (16384) + 32 * 14 = 16832
//   Height        : 20 rows (rows 14..33)
//   Width         : 16 * ((14 mod 4) + 1) = 48 pixels (3 words)

    @16832          // Row 14 start address: 16384 + 32 * 14
    D=A
    @start_addr
    M=D

    @20             // Box height = 20 rows (rows 14..33)
    D=A
    @height
    M=D

    @3              // Box width = (14 mod 4) + 1 = 3 words = 48 pixels
    D=A
    @width
    M=D

    @prev_color     // Track last drawn color (screen starts white = 0)
    M=0

// --- Main Keyboard Polling Loop ---
(MAIN_LOOP)
    @KBD            // RAM[24576]: 0 if no key pressed, keycode != 0 if pressed
    D=M
    @SET_WHITE
    D;JEQ

    // Any key is pressed -> select black (-1 = 0xFFFF = 16 black pixels)
    @color
    M=-1
    @CHECK_CHANGE
    0;JMP

(SET_WHITE)
    // No key is pressed -> select white (0 = 0x0000 = 16 white pixels)
    @color
    M=0

(CHECK_CHANGE)
    // Redraw only when key state changes (eliminates unnecessary redraws/flicker)
    @color
    D=M
    @prev_color
    D=D-M
    @MAIN_LOOP
    D;JEQ

    // Save new color state before drawing
    @color
    D=M
    @prev_color
    M=D

// --- Draw / Erase the 48x20 Box (20 rows x 3 words/row = 60 screen words) ---
(DRAW_BOX)
    @start_addr
    D=M
    @row_base       // Current row's starting screen address
    M=D

    @height
    D=M
    @rows_left      // Remaining rows to paint
    M=D

(ROW_LOOP)
    @rows_left
    D=M
    @MAIN_LOOP      // Finished all 20 rows -> return to polling keyboard
    D;JEQ

    @row_base
    D=M
    @addr           // Current word address inside this row
    M=D

    @width
    D=M
    @cols_left      // Remaining 16-pixel words in this row
    M=D

(COL_LOOP)
    @cols_left
    D=M
    @NEXT_ROW       // Finished all 3 words in this row -> move to next row
    D;JEQ

    // Paint 16 pixels at RAM[addr] with color (-1 = black, 0 = white)
    @color
    D=M
    @addr
    A=M
    M=D

    // Advance word pointer right by 1 word (16 pixels)
    @addr
    M=M+1

    // Decrement remaining words in this row
    @cols_left
    M=M-1

    @COL_LOOP
    0;JMP

(NEXT_ROW)
    // Move down exactly 1 screen row (+32 words = +512 pixels)
    @32
    D=A
    @row_base
    M=D+M

    // Decrement remaining rows
    @rows_left
    M=M-1

    @ROW_LOOP
    0;JMP
