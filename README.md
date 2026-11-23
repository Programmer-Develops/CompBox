# Nand to Tetris – I Capstone Project

**Name:** Shantanu Pandya  
**Roll No.:** 2501730014  
**Personal Number (K):** 14  

## Specifications for K = 14
- **Part A (Computer):** `CPU.hdl`, `Memory.hdl`, `Computer.hdl` tested with `CPU.tst`, `Memory.tst`, `ComputerAdd.tst`, `ComputerMax.tst`, `ComputerRect.tst`.
- **Part B (Assembler):** Two-pass Python assembler (`assembler.py`) verified against the official assembler on `Add.asm`, `Max.asm`, `Rect.asm`, and `Pong.asm`.
  - Extra feature (`14 mod 3 = 2`): prints a warning if the same label is declared more than once.
- **Part C (Box Program):** `Box.asm` assembled using `assembler.py` into `Box.hack`.
  - Box starts at row 14 (`SCREEN + 32*14 = 16832`), height 20 rows, width `16 * ((14 mod 4) + 1) = 48` pixels (3 words) from the left edge.
  - Appears black while any key is pressed and disappears when released.

## Structure
- `capstone/` — `CPU.hdl`, `Memory.hdl`, `Computer.hdl`, `assembler.py`, `Box.asm`, `Box.hack`
- `tests/` — `test_dup_labels.asm`, `BoxTest.tst`, `BoxTest.cmp`
- `report/` — `Capstone_Report_2501730014_Shantanu_Pandya.pdf`

## Usage
```bash
python capstone/assembler.py capstone/Box.asm
```
