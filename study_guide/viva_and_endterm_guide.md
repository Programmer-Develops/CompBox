# Viva & Endterm Exam Mastery Guide
**Nand to Tetris – I (`ETCCNT301`) — Shantanu Pandya (`2501730014`, `K = 14`)**

---

## 1. Your Personal Numbers (Memorize Cold for the Viva!)

| Item | Formula | Your Exact Answer |
|---|---|---|
| Personal Number `K` | Last two digits of `2501730014` | **`14`** |
| Part B Extra Feature | `K mod 3 = 14 mod 3 = 2` | **Print a warning if the same label is written twice** |
| Box Start Row | Row `K` (0-indexed from top) | **Row `14`** |
| Box Height | Fixed `20` rows | **`20` rows** (rows `14` to `33` inclusive) |
| Box Width (words) | `(K mod 4) + 1 = (14 mod 4) + 1 = 2 + 1` | **`3` words** per row (left edge: words `0, 1, 2`) |
| Box Width (pixels) | `16 × 3` | **`48` pixels** (columns `0` to `47`) |
| Starting Screen Address | `SCREEN + 32 × K = 16384 + 32 × 14 = 16384 + 448` | **`16832`** |
| Last Row Start Address | `16384 + 32 × 33 = 16384 + 1056` | **`17440`** (words `17440, 17441, 17442`) |
| Total Screen Words Painted | `20 rows × 3 words/row` | **`60` words (`960` pixels)** |
| Black vs White Word Value | 16 ones vs 16 zeros in two's complement | **Black = `-1` (`0xFFFF`), White = `0` (`0x0000`)** |

---

## 2. The 5-Minute Viva Walkthrough Script

### Part A — `Memory.hdl` (45 seconds)
> *"Hack has a 15-bit data address space: `0–16383` is `RAM16K`, `16384–24575` is the `8K` Screen memory map, and `24576` (`0x6000`) is the read-only Keyboard register. Looking at the top two address bits `address[13..14]`: `00` and `01` belong to RAM16K, `10` is Screen, and `11` is Keyboard. I use `DMux4Way` to route the `load` bit so only the addressed device gets written (merging `00` and `01` with an `Or` gate for `RAM16K`), and `Mux4Way16` to select the correct device's output."*

- **Likely follow-up:** *"Why did you use `Or` on `loadRamLow` and `loadRamHigh`?"*
  - **Answer:** Because `RAM16K` covers 16K words = two 8K blocks (`address[13..14] = 00` for `0..8191` and `01` for `8192..16383`). Both must assert `RAM16K`'s `load` pin.
- **Likely follow-up:** *"Why does `Screen` only take `address[0..12]` while `RAM16K` takes `address[0..13]`?"*
  - **Answer:** `RAM16K` has $2^{14} = 16384$ registers (14 address bits `0..13`). `Screen` has $8K = 2^{13} = 8192$ registers (13 address bits `0..12`).

### Part A — `CPU.hdl` (60 seconds)
> *"Bit `instruction[15]` distinguishes A-instructions (`0`) from C-instructions (`1`). For an A-instruction, the `Mux16` feeds the raw instruction into `ARegister`, and `loadA` is always `1`, while `loadD`, `writeM`, and `pcLoad` are all gated by `instruction[15]` so an A-instruction can never accidentally write to `D`, memory, or trigger a jump. For a C-instruction, `instruction[12]` chooses whether the ALU's `y`-input is `A` or `inM`; bits `11..6` drive the ALU control pins `zx, nx, zy, ny, f, no`; bits `5..3` (`d1, d2, d3`) control writing to `A`, `D`, and `M`; and bits `2..0` (`j1, j2, j3`) are compared against the ALU's `ng`, `zr`, and computed `pos = NOT(zr OR ng)` flags to decide `pcLoad`."*

- **Likely follow-up:** *"Why do we need `And(a=instruction[15], b=...)` on `loadD`, `writeM`, and `pcLoad`?"*
  - **Answer:** In an A-instruction (`@12345`), bits `0..14` are just a numeric constant — bits `5..0` might happen to be `1`! Gating with `instruction[15]` guarantees only C-instructions can write `D`/`M` or jump.
- **Likely follow-up:** *"How do you compute `out > 0` when the ALU only gives `zr` and `ng`?"*
  - **Answer:** A number is strictly positive iff it is neither zero nor negative: `aluPos = NOT(aluZero OR aluNeg)`.
- **Likely follow-up:** *"What happens when `reset == 1`?"*
  - **Answer:** Inside `PC`, `reset` has highest priority over `load` and `inc`, so `pc` resets to `0` on the next clock edge.

### Part A — `Computer.hdl` (20 seconds)
> *"Hack uses a Harvard architecture with separate instruction memory (`ROM32K`) and data memory (`Memory`). `ROM32K` outputs the instruction at `pc`, `CPU` executes it using `inM` from `Memory`, and drives `outM`, `writeM`, `addressM`, and the next `pc`."*

### Part B — `assembler.py` (45 seconds)
> *"It is a two-pass assembler. Pass 1 strips `//` comments and whitespace, tracks the current ROM instruction counter, and records every `(LABEL)` in the symbol table without incrementing the ROM address. For my `K mod 3 = 2` feature, Pass 1 also tracks `defined_labels`: if a label was already declared, it prints a warning with both line numbers and keeps the original definition. Pass 2 translates `@` A-instructions (allocating unseen symbols starting at `RAM[16]`) and `[dest=]comp[;jump]` C-instructions using lookup tables. All 4 official programs — including `Pong.asm` (27,483 instructions) — match the official assembler bit-for-bit."*

- **Likely follow-up:** *"Why can't we do it in a single pass?"*
  - **Answer:** Because of **forward references**! An instruction like `@END` on line 5 may jump to `(END)` declared on line 20. Pass 1 resolves all label ROM addresses first so Pass 2 doesn't mistake a forward label for a RAM variable.

### Part C — `Box.asm` (45 seconds)
> *"At startup, I store `start_addr = 16832` (`16384 + 32×14`), `height = 20`, `width = 3` (48 pixels), and `prev_color = 0`. In `MAIN_LOOP`, I poll `@KBD` (`RAM[24576]`): if `0`, `color = 0` (white); else `color = -1` (black, 16 ones). I compare `color` with `prev_color` so I only repaint the 60 box words when the key state actually changes — avoiding unnecessary redraws. `DRAW_BOX` uses an outer loop of 20 rows (`row_base += 32` each row) and an inner loop of 3 words (`addr += 1`), writing `color` via pointer dereferencing (`@addr; A=M; M=D`)."*

---

## 3. On-the-Spot Viva Live-Edit Cheat Sheet

If the examiner asks you to modify a file live during the 5-minute viva:

| Examiner Request | Exact File & Edit | Re-run Command |
|---|---|---|
| **"Move the box down by 10 rows"** | In `Box.asm`: change `@16832` → `@17152` (`16832 + 32×10`) | `python capstone/assembler.py capstone/Box.asm` → reload `Box.hack` |
| **"Move the box down to row `R`"** | In `Box.asm`: change `@16832` → `@(16384 + 32*R)` (e.g. Row 50 = `17984`, Row 100 = `19584`) | Re-assemble & reload |
| **"Move the box right by `W` words (`16*W` px)"** | In `Box.asm`: add `W` to `@16832` (e.g. right by 32 px = `+2` → `@16834`, right by 160 px = `+10` → `@16842`) | Re-assemble & reload |
| **"Make the box taller (e.g., 40 rows)"** | In `Box.asm`: change `@20` → `@40` | Re-assemble & reload |
| **"Make the box wider (e.g., 80 px = 5 words)"** | In `Box.asm`: change `@3` → `@5` (row stride `row_base += 32` stays automatically accurate!) | Re-assemble & reload |
| **"Make the box appear when NO key is pressed (invert)"** | In `Box.asm`: swap `M=-1` and `M=0` (and set initial `@prev_color; M=-1` so it draws immediately on start) | Re-assemble & reload |
| **"Only show box when `'A'` (ASCII 65) is pressed"** | In `MAIN_LOOP`: replace `@KBD; D=M; @SET_WHITE; D;JEQ` with `@KBD; D=M; @65; D=D-A; @SET_WHITE; D;JNE` | Re-assemble & reload |
| **"Show a striped/checkered box instead of solid black"** | Replace `M=-1` with `@21845; D=A; @color; M=D` (`0101010101010101` = vertical stripes!) | Re-assemble & reload |
| **"Show duplicate label warning live"** | Run `python capstone/assembler.py tests/test_dup_labels.asm` | Watch both line-numbered warnings print! |

---

## 4. Endterm Exam High-Yield Revision Notes (CO1 – CO4)

### CO1: Boolean Logic, Arithmetic & ALU (Chapters 1–2)
1. **Nand Universality (Know Every Construction!):**
   - `Not(a) = Nand(a, a)`
   - `And(a, b) = Not(Nand(a, b))`
   - `Or(a, b) = Nand(Not(a), Not(b))` (by De Morgan's Law!)
   - `Xor(a, b) = Or(And(a, Not(b)), And(Not(a), b))`
   - `Mux(a, b, sel) = Or(And(a, Not(sel)), And(b, sel))`
   - `DMux(in, sel) = { a = And(in, Not(sel)), b = And(in, sel) }`
2. **Adders:**
   - `HalfAdder(a, b)`: `sum = Xor(a, b)`, `carry = And(a, b)`
   - `FullAdder(a, b, c)`: `sum = a ⊕ b ⊕ c`, `carry = (a·b) + (c·(a ⊕ b))` (built from 2 HalfAdders + 1 Or)
   - `Add16`: 16-bit ripple-carry adder (overflow bit discarded).
3. **Two's Complement (16-bit signed integers):**
   - Range: `-32768` (`1000 0000 0000 0000`) to `+32767` (`0111 1111 1111 1111`).
   - Negation formula: `-x = (~x) + 1` (invert all bits, add 1).
   - `-1` is ALWAYS all ones (`1111 1111 1111 1111 = 0xFFFF`).
   - MSB (`bit 15`) = sign bit (`1` → negative, `0` → non-negative).
4. **The Hack ALU (6 Control Bits — GUARANTEED EXAM QUESTION!):**
   Pipeline order:
   1. If `zx`: `x = 0` → if `nx`: `x = !x`
   2. If `zy`: `y = 0` → if `ny`: `y = !y`
   3. If `f == 1`: `out = x + y` else `out = x & y`
   4. If `no`: `out = !out`
   5. Flags: `zr = (out == 0)`, `ng = (out < 0) = out[15]`

   **Quick Exam Derivation Tricks:**
   - `0`  → `101010` (zero x, zero y, `0 + 0`)
   - `1`  → `111111` (`x = !0 = -1`, `y = !0 = -1`, `(-1)+(-1) = -2`, `!(-2) = +1`!)
   - `-1` → `111010` (`x = -1`, `y = 0`, `-1 + 0 = -1`)
   - `x+1` → `011111` (`x = !x = -x-1`, `y = -1`, `(-x-1)+(-1) = -x-2`, `!(-x-2) = x+1`)
   - `x-y` → `010011` (`!(!x + y) = -(-x-1 + y) - 1 = x - y`!)

---

### CO2: Sequential Logic & Memory Hierarchy (Chapter 3)
1. **Combinational vs Sequential:**
   - Combinational: `out(t) = f(in(t))` (no state, instantaneous).
   - Sequential: `out(t) = f(in(t-1))` (clocked by DFF, holds state across clock cycles).
2. **Bit → Register → RAM Hierarchy:**
   - `Bit`: `Mux(a=dffOut, b=in, sel=load, out=muxOut); DFF(in=muxOut, out=dffOut, out=out);`
   - `Register`: 16 `Bit` chips in parallel sharing one `load`.
   - **RAM Addressing Rule (`RAM_N` built from 8 × `RAM_(N/8)`):**
     - Top 3 address bits select WHICH sub-RAM (`DMux8Way` on `load`, `Mux8Way16` on `out`).
     - Remaining lower address bits pass directly into every sub-RAM.
     - Example: `RAM16K` uses **4** × `RAM4K` (`address[12..13]` via `DMux4Way` / `Mux4Way16`, and `address[0..11]` into each `RAM4K`).
3. **Program Counter (`PC`) Priority (Highest → Lowest):**
   ```
   if      reset(t-1) == 1 : out(t) = 0
   else if load(t-1)  == 1 : out(t) = in(t-1)
   else if inc(t-1)   == 1 : out(t) = out(t-1) + 1
   else                    : out(t) = out(t-1)
   ```
   *(Implemented by wiring Muxes in REVERSE priority order: `inc` Mux first → `load` Mux second → `reset` Mux last → `Register(load=true)`!)*

---

### CO3: Hack Machine Language & Computer Architecture (Chapters 4–5)
1. **Instruction Formats:**
   - **A-instruction** (`@value`): `0 v14 v13 ... v0` (loads 15-bit non-negative value `0..32767` into `A`).
   - **C-instruction** (`dest=comp;jump`): `1 1 1 a c1 c2 c3 c4 c5 c6 d1 d2 d3 j1 j2 j3`
     - `d1=A`, `d2=D`, `d3=M` (bits 5, 4, 3)
     - `j1=(<0)`, `j2=(==0)`, `j3=(>0)` (bits 2, 1, 0)
2. **Hand-Assembly Worked Example (Classic Exam Question!):**
   - Assemble `MD=D-M;JGT`:
     - Opcode + unused: `111`
     - `comp = D-M`: uses `M` so `a=1`, `c1..c6 = 010011` → `1010011`
     - `dest = MD`: `A=0, D=1, M=1` → `011`
     - `jump = JGT`: `<0:0, ==0:0, >0:1` → `001`
     - Full 16-bit binary: `111 1010011 011 001` = **`1111010011011001`**
3. **Memory Map & Screen Formula:**
   - RAM: `0..16383` (`0x0000..0x3FFF`)
   - Screen: `16384..24575` (`0x4000..0x5FFF`) — 256 rows × 512 cols = 8192 words (32 words/row, 16 pixels/word, LSB = leftmost pixel of the 16-pixel word!).
   - Pixel `(row, col)`:
     - Word address = `16384 + 32 * row + floor(col / 16)`
     - Bit index inside word = `col mod 16` (0 = LSB/leftmost, 15 = MSB/rightmost)
   - Keyboard: `24576` (`0x6000`) — 0 when no key pressed; ASCII code (or special key code 128–152) when pressed.
4. **Harvard vs Von Neumann:**
   - Hack is **Harvard** (separate ROM for instructions, RAM for data → fetch and data access happen in the same clock cycle without structural hazard).

---

### CO4: Two-Pass Assembler (Chapter 6)
1. **Symbol Table Lifecycle:**
   - **Init:** Load 23 predefined symbols (`SP=0`, `LCL=1`, `ARG=2`, `THIS=3`, `THAT=4`, `R0..R15=0..15`, `SCREEN=16384`, `KBD=24576`).
   - **Pass 1 (Labels):** Scan lines; ignore blank/comment lines; on `(LABEL)` record `symbol_table[LABEL] = rom_address` (do NOT increment `rom_address`!); on A/C instruction increment `rom_address += 1`.
   - **Pass 2 (Code + Variables):** On `@symbol`: if numeric convert to 15-bit binary; else if in `symbol_table` use its address; else assign `next_ram_addr` (starts at `16`, increments by `1`). On C-instruction encode `111 + comp + dest + jump`.
2. **Exam Trap to Avoid:**
   - Pseudo-commands like `(LOOP)` do **NOT** generate machine code and do **NOT** increment the ROM counter!
   - Variables are allocated starting at `RAM[16]` in the **order they first appear in Pass 2** (NOT Pass 1, and NOT alphabetically!).
