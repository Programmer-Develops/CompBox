#!/usr/bin/env python3
"""
End-to-End Verification Suite for Nand2Tetris Capstone Project
Student : Shantanu Pandya (Roll No. 2501730014, K = 14)

Verifies:
  Part A: CPU.hdl, Memory.hdl, Computer.hdl via official HardwareSimulator
  Part B: assembler.py bit-for-bit vs official Assembler + duplicate-label warning (K mod 3 = 2)
  Part C: Box.asm -> Box.hack (via our own assembler) -> official CPUEmulator pixel verification
"""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
CAPSTONE = ROOT / "capstone"
SUITE = ROOT / "nand2tetris_suite" / "nand2tetris"
TOOLS = SUITE / "tools"
PROJ5 = SUITE / "projects" / "5"
PROJ6 = SUITE / "projects" / "6"
TESTS = ROOT / "tests"

HW_SIM = TOOLS / "HardwareSimulator.bat"
CPU_EMU = TOOLS / "CPUEmulator.bat"
OFFICIAL_ASM = TOOLS / "Assembler.bat"


def run_cmd(cmd: list[str], cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        capture_output=True,
        text=True,
        check=False,
    )


def verify_part_a() -> bool:
    print("\n" + "=" * 72)
    print("PART A: Hardware Verification (CPU.hdl, Memory.hdl, Computer.hdl)")
    print("=" * 72)
    all_ok = True

    with tempfile.TemporaryDirectory(prefix="n2t_partA_") as tmp:
        tmp_dir = Path(tmp)
        for item in PROJ5.iterdir():
            if item.is_file():
                shutil.copy2(item, tmp_dir / item.name)
        for hdl in ("CPU.hdl", "Memory.hdl", "Computer.hdl"):
            shutil.copy2(CAPSTONE / hdl, tmp_dir / hdl)

        # Build non-interactive Memory test (checks RAM, Screen, overwrite isolation)
        mem_lines = (PROJ5 / "Memory.tst").read_text(encoding="utf-8").splitlines()
        cleaned = []
        skip_while = False
        for line in mem_lines:
            if "while out <>" in line:
                skip_while = True
                continue
            if skip_while:
                if line.strip().startswith("}"):
                    skip_while = False
                continue
            if any(
                tok in line
                for tok in (
                    "clear-echo",
                    'echo "Click',
                    'echo "Two horizontal',
                    "output-file",
                    "compare-to",
                )
            ):
                continue
            if line.strip().startswith("load Memory.hdl,"):
                cleaned.extend(
                    [
                        "load Memory.hdl,",
                        "output-file MemoryNonInteractive.out,",
                        "compare-to MemoryNonInteractive.cmp,",
                    ]
                )
            elif "set address 24576" in line:
                cleaned.append("set address 24576, eval,")
            else:
                cleaned.append(line)
        (tmp_dir / "MemoryNonInteractive.tst").write_text("\n".join(cleaned) + "\n", encoding="utf-8")

        cmp_text = (PROJ5 / "Memory.cmp").read_text(encoding="utf-8")
        cmp_text = cmp_text.replace("|     75 |", "|      0 |").replace("|     89 |", "|      0 |")
        (tmp_dir / "MemoryNonInteractive.cmp").write_text(cmp_text, encoding="utf-8")

        tests = [
            "CPU.tst",
            "CPU-external.tst",
            "MemoryNonInteractive.tst",
            "ComputerAdd.tst",
            "ComputerMax.tst",
            "ComputerRect.tst",
        ]
        for tst in tests:
            res = run_cmd([str(HW_SIM), str(tmp_dir / tst)])
            out = (res.stdout + res.stderr).strip()
            ok = "Comparison ended successfully" in out
            status = "PASS" if ok else "FAIL"
            print(f"  [{status}] {tst:<26} -> {out}")
            all_ok = all_ok and ok

    return all_ok


def verify_part_b() -> bool:
    print("\n" + "=" * 72)
    print("PART B: Python Assembler Verification (Official Match + K mod 3 = 2)")
    print("=" * 72)
    all_ok = True

    with tempfile.TemporaryDirectory(prefix="n2t_partB_") as tmp:
        tmp_dir = Path(tmp)
        benchmarks = [
            PROJ6 / "add" / "Add.asm",
            PROJ6 / "max" / "Max.asm",
            PROJ6 / "rect" / "Rect.asm",
            PROJ6 / "pong" / "Pong.asm",
        ]
        for src in benchmarks:
            work_asm = tmp_dir / src.name
            shutil.copy2(src, work_asm)

            # Official assembler
            run_cmd([str(OFFICIAL_ASM), str(work_asm)])
            official_hack = work_asm.with_suffix(".hack").read_text(encoding="utf-8").strip()

            # Our Python assembler
            mine_path = tmp_dir / f"{src.stem}.mine.hack"
            res = run_cmd([sys.executable, str(CAPSTONE / "assembler.py"), str(work_asm), str(mine_path)])
            mine_hack = mine_path.read_text(encoding="utf-8").strip()

            ok = res.returncode == 0 and (official_hack == mine_hack)
            lines = len(mine_hack.splitlines())
            status = "PASS" if ok else "FAIL"
            print(f"  [{status}] {src.name:<12} ({lines:>5} instructions) — bit-for-bit match with official Assembler")
            all_ok = all_ok and ok

        # Test K mod 3 == 2 extra feature: duplicate label warnings
        dup_out = tmp_dir / "dup.hack"
        res = run_cmd([sys.executable, str(CAPSTONE / "assembler.py"), str(TESTS / "test_dup_labels.asm"), str(dup_out)])
        warn_lines = [l for l in res.stderr.splitlines() if "WARNING" in l and "Duplicate label" in l]
        ok_dup = res.returncode == 0 and len(warn_lines) == 2
        status = "PASS" if ok_dup else "FAIL"
        print(f"  [{status}] Duplicate-label feature (K mod 3 = 2): {len(warn_lines)} warnings emitted")
        for w in warn_lines:
            print(f"         {w}")
        all_ok = all_ok and ok_dup

    return all_ok


def verify_part_c() -> bool:
    print("\n" + "=" * 72)
    print("PART C: Box.asm -> Box.hack (K = 14: Row 14, Height 20, Width 48 px)")
    print("=" * 72)

    # Assemble Box.asm with our own assembler.py
    res = run_cmd([sys.executable, str(CAPSTONE / "assembler.py"), str(CAPSTONE / "Box.asm")])
    print(f"  Assembler: {res.stdout.strip()}")
    if res.returncode != 0:
        print(f"  [FAIL] Assembly error: {res.stderr.strip()}")
        return False

    with tempfile.TemporaryDirectory(prefix="n2t_partC_") as tmp:
        tmp_dir = Path(tmp)
        shutil.copy2(CAPSTONE / "Box.hack", tmp_dir / "Box.hack")
        shutil.copy2(TESTS / "BoxTest.tst", tmp_dir / "BoxTest.tst")
        shutil.copy2(TESTS / "BoxTest.cmp", tmp_dir / "BoxTest.cmp")

        res = run_cmd([str(CPU_EMU), str(tmp_dir / "BoxTest.tst")])
        out = (res.stdout + res.stderr).strip()
        ok = "Comparison ended successfully" in out
        status = "PASS" if ok else "FAIL"
        print(f"  [{status}] BoxTest.tst (CPUEmulator) -> {out}")
        return ok


def main() -> int:
    print("Nand to Tetris - I Capstone Verification (Shantanu Pandya | 2501730014 | K = 14)")
    a = verify_part_a()
    b = verify_part_b()
    c = verify_part_c()

    print("\n" + "=" * 72)
    if a and b and c:
        print("OVERALL RESULT: ALL CHECKS PASSED (100%)")
        return 0
    print("OVERALL RESULT: SOME CHECKS FAILED")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
