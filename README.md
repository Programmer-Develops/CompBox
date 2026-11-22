# CompBox — Nand to Tetris Capstone Project (K = 14)

**Course:** Nand to Tetris – I (`ETCCNT301`) — School of Engineering & Technology, K.R. Mangalam University  
**Student:** Shantanu Pandya  
**Roll No.:** `2501730014`  
**Personal Number (`K`):** `14`

> A complete, verified implementation of the Hack computer (`CPU.hdl`, `Memory.hdl`, `Computer.hdl`), a two-pass Python Hack Assembler with duplicate-label diagnostics (`K mod 3 = 2`), and an interactive keyboard-controlled `48 × 20` box program (`Box.asm` → `Box.hack` at Row 14, `RAM[16832]`), accompanied by automated verification, a print-ready ZOSIMA report, and an interactive Hack visualizer for viva & endterm exam preparation.

---

## Personalized Specification (`K = 14`)

| Requirement | Formula | Computed Value |
|---|---|---|
| Personal Number `K` | Last 2 digits of `2501730014` | **`14`** |
| Part B Extra Feature | `K mod 3 = 14 mod 3 = 2` | **Print warning on duplicate `(LABEL)` declarations** |
| Box Start Row | Row `K` (0-indexed) | **Row `14`** (rows `14..33`) |
| Box Dimensions | `16 × ((K mod 4) + 1)` × `20` | **`48 × 20` pixels** (`3` words wide × `20` rows tall) |
| Start Screen RAM | `16384 + 32 × 14` | **`RAM[16832]`** (60 words = 960 pixels) |

---

## Repository Structure

```text
CompBox/
├── capstone/                       # Clean submission deliverables
│   ├── CPU.hdl                     # Part A: Hack CPU
│   ├── Memory.hdl                  # Part A: RAM16K + Screen + Keyboard router
│   ├── Computer.hdl                # Part A: Top-level Harvard Hack computer
│   ├── assembler.py                # Part B: Two-pass Python Hack assembler (K mod 3 = 2)
│   ├── Box.asm                     # Part C: Interactive 48x20 box at row 14
│   ├── Box.hack                    # Part C: Binary assembled by assembler.py (77 instructions)
│   └── README.md
├── tests/                          # Automated end-to-end verification
│   ├── verify_all.py               # Verifies Parts A, B, and C via official tools
│   ├── BoxTest.tst / BoxTest.cmp   # Official CPUEmulator pixel verification script
│   └── test_dup_labels.asm         # Duplicate-label warning test case
├── report/                         # ZOSIMA 4-page report
│   ├── report.html                 # Print-to-PDF ready 4-page academic report
│   └── screenshots/README.txt      # Screenshot capture checklist
├── study_guide/                    # Viva & Endterm Exam prep
│   ├── hack_visualizer.html        # Interactive Hack CPU, ALU, Memory & Box.hack simulator
│   └── viva_and_endterm_guide.md   # 5-minute viva script, live-edit cheat sheet & CO1–CO4 notes
└── open_official_gui.ps1           # One-click launcher for official HardwareSimulator & CPUEmulator
```

---

## Verification Summary

All tests verified via `python tests/verify_all.py`:
- **Part A:** `CPU.tst`, `CPU-external.tst`, `MemoryNonInteractive.tst`, `ComputerAdd.tst`, `ComputerMax.tst`, `ComputerRect.tst` — **PASS**
- **Part B:** `Add.asm` (6), `Max.asm` (16), `Rect.asm` (25), `Pong.asm` (27,483) — **100% bit-for-bit match** with official Assembler + verified duplicate-label warnings
- **Part C:** `Box.asm` → `Box.hack` (77 instructions) verified in official `CPUEmulator` across key press, release, re-press, and outer boundary guard words — **PASS**
