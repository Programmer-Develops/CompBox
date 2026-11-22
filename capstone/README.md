# Capstone Project: Make the Computer Draw a Box

**Course:** Nand to Tetris – I (`ETCCNT301`) — School of Engineering & Technology, K.R. Mangalam University  
**Student:** Shantanu Pandya  
**Roll No.:** `2501730014`  
**Personal Number (`K`):** `14` (last two digits of roll number)

---

## Personalized Parameters (`K = 14`)

| Parameter | Formula | Value for `K = 14` |
|---|---|---|
| Personal Number `K` | Last 2 digits of `2501730014` | **`14`** |
| Assembler Extra Feature | `K mod 3` = `14 mod 3` = **`2`** | **Print a warning if the same label is written twice** |
| Box Start Row | Row `K` (0-indexed from top) | **Row `14`** (rows `14..33`) |
| Box Height | Fixed `20` rows | **`20` rows** |
| Box Width | `16 × ((K mod 4) + 1)` = `16 × (2 + 1)` | **`48` pixels** (`3` words from left edge) |
| Starting Screen RAM Address | `SCREEN + 32 × 14` = `16384 + 448` | **`RAM[16832]`** (60 screen words total) |

---

## Folder Contents

| File | Part | Description |
|---|---|---|
| `CPU.hdl` | Part A | Hack Central Processing Unit (instruction decoding, A/D registers, ALU control, jump logic, PC) |
| `Memory.hdl` | Part A | Hack Memory address decoder routing `RAM16K`, `Screen`, and `Keyboard` via `address[13..14]` |
| `Computer.hdl` | Part A | Top-level Harvard-architecture Hack computer uniting `ROM32K`, `CPU`, and `Memory` |
| `assembler.py` | Part B | Two-pass Python Hack Assembler matching the official assembler bit-for-bit + duplicate-label warning (`K mod 3 = 2`) |
| `Box.asm` | Part C | Hack assembly program that displays the `48 × 20` black box at row 14 while any key is pressed and clears it on release |
| `Box.hack` | Part C | 77-instruction Hack binary produced directly by `assembler.py` |

---

## How to Run & Verify

### 1. Assemble `Box.asm` (or any `.asm` program)
```bash
python assembler.py Box.asm
```
To test the duplicate-label warning (`K mod 3 = 2`):
```bash
python assembler.py ../tests/test_dup_labels.asm
```

### 2. Run Automated Verification (Parts A, B, and C)
From the project root (`CompBox/`):
```bash
python tests/verify_all.py
```

### 3. Run in Official GUI Simulators
- **Hardware Simulator (Part A):** Load `CPU.tst`, `Memory.tst`, `ComputerAdd.tst`, `ComputerMax.tst`, `ComputerRect.tst` alongside `CPU.hdl`, `Memory.hdl`, and `Computer.hdl`.
- **CPU Emulator (Part C):** Load `Box.hack`, set speed to **Fast**, enable the **Keyboard** button, press and hold any key to see the `48 × 20` black box at row 14, and release the key to see it disappear.

---

## Built-In Chips Note

Per the official Project 5 test scripts (`CPU.tst`, `Memory.tst`, `ComputerAdd.tst`, `ComputerMax.tst`, `ComputerRect.tst`), `ARegister`, `DRegister`, `ALU`, `PC`, `RAM16K`, `ROM32K`, `Screen`, `Keyboard`, and primitive combinational gates use the Hardware Simulator's built-in implementations so the test scripts can directly inspect internal registers and memory-mapped I/O.
