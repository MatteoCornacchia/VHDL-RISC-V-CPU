# VHDL RISC-V CPU + CORDIC Module

This repository contains a simple RISC-V CPU core implemented in VHDL, together with a CORDIC-based hardware module for trigonometric computations (sine and cosine).  
The project is meant as an educational and experimental design, focusing on clarity and modularity rather than performance or full ISA coverage.

The CPU follows a classic 5-stage structure (IF, ID, EX, MEM, WB), with each stage implemented as a separate VHDL module.  
The CORDIC unit is integrated as a standalone module and wrapped to be easily connected to the main datapath.

## Project Structure

```
scr/					            # MAIN STAGES
├── cpu_top.vhd				        # Datapath (top level)
│   ├── if_stage.vhd		    	# Instructiion Fetch (IF)
│   │   └── instruction_memory.vhd
│   ├── id_stage.vhd		    	# Instruction Decode (ID)
│   │   ├── register_file.vhd
│   │   └── decoder.vhd
│   ├── ex_stage.vhd	 		    # Instruction Execute (EX)
│   │   ├── alu.vhd
│   │   └── comparator.vhd
│   ├── mem_stage.vhd		    	# Data Memory (MEM)
│   └── wb_stage.vhd		    	# Write Back (WB)
│       └── data_mem.vhd
└── cordic_wrapper.vhd		    	# Cordic Wrapper
    └── cordic_core.vhd		    	# Cordic Algorithm


tb/					                # TESTBENCHES
├── tb_if_stage.vhd			        # testbench for IF
├── tb_id_stage.vhd			        # testbench for ID
├── tb_ex_stage.vhd			        # testbench for EX
├── tb_mem_wb_stage.vhd		        # testbench for MEM + WB
├── tb_cpu_top.vhd	 	        	# testbench for Datapath
└── tb_cordic_wrapper.vhd	     	# testbench for Cordic

```

## Goals and Scope

- Educational implementation of a simple RISC-V CPU core in VHDL.
- Modular design: each stage is developed and tested independently.
- Integration of a CORDIC hardware accelerator for sine and cosine computation.
- Clear and readable RTL, suitable for learning and experimentation.

## Notes

- The project does not aim to fully implement the RISC-V ISA or to be cycle-accurate with a commercial core.
- The CORDIC module is designed to be reusable and loosely coupled to the CPU datapath.
- Testbenches are provided for individual stages and for the top-level CPU and CORDIC wrapper.


