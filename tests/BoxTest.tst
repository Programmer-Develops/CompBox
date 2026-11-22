// Automated CPUEmulator test for Box.hack (K = 14: row 14..33, width 48 px = 3 words)
load Box.hack,
output-file BoxTest.out,
compare-to BoxTest.cmp,
output-list RAM[24576]%D2.6.2 RAM[16800]%D2.6.2 RAM[16832]%D2.6.2 RAM[16833]%D2.6.2 RAM[16834]%D2.6.2 RAM[16835]%D2.6.2 RAM[17120]%D2.6.2 RAM[17122]%D2.6.2 RAM[17123]%D2.6.2 RAM[17440]%D2.6.2 RAM[17442]%D2.6.2 RAM[17443]%D2.6.2 RAM[17472]%D2.6.2;

// Phase 1: No key pressed -> entire box remains white (0)
set RAM[24576] 0,
repeat 200 {
    ticktock;
}
output;

// Phase 2: Key pressed ('A' = 65) -> exact 48x20 box at rows 14..33 turns black (-1), guards stay 0
set RAM[24576] 65,
repeat 2000 {
    ticktock;
}
output;

// Phase 3: Key released -> exact 48x20 box disappears back to white (0)
set RAM[24576] 0,
repeat 2000 {
    ticktock;
}
output;

// Phase 4: Different key pressed (Space = 32) -> box reappears cleanly
set RAM[24576] 32,
repeat 2000 {
    ticktock;
}
output;
