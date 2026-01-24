# VHDL-RISC-V-CPU
A simple RISC-V CPU design implemented in VHDL.

## Project Structure
```
src/                             # MAIN STAGES
└── cpu_top.vhd                  # Datapath (top level)
    ├── if_stage.vhd             # Instruction Fetch (IF)
    │   └── instruction_memory.vhd
    ├── id_stage.vhd             # Instruction Decode (ID)
    │   ├── register_file.vhd
    │   └── decoder.vhd
    ├── ex_stage.vhd             # Instruction Execute (EX)
    │   ├── alu.vhd
    │   └── comparator.vhd
    ├── mem_stage.vhd            # Data Memory (MEM)
    └── wb_stage.vhd             # Write Back (WB)
        └── data_mem.vhd

tb/                              # TESTBENCHES
├── tb_if_stage.vhd              # testbench for IF
├── tb_id_stage.vhd              # testbench for ID
├── tb_ex_stage.vhd              # testbench for EX
├── tb_mem_wb_stage.vhd          # testbench for MEM + WB
└── tb_cpu_top.vhd               # testbench for Datapath

```
