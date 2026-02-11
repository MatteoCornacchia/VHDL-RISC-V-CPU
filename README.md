# VHDL RISC-V CPU + CORDIC Module

This project is entirely developed in VHDL and consists of three main components:

- A basic RISC-V CPU design, implemented with a simple and modular architecture.  
- A standalone CORDIC hardware module for sine and cosine computation, developed as an independent unit from the CPU core.  
- An interface with the Nexys 4 DDR FPGA board, used to interact with the CORDIC module for hardware-level input/output and testing.

The overall goal of the project is to provide a clear and educational hardware design, combining a simple RISC-V processor with a dedicated computational accelerator and real FPGA board interaction.


## Project Structure

```
scr/					                # MAIN STAGES
├── cpu_top.vhd				            # Datapath (top level for cpu)
│   ├── if_stage.vhd		        	# Instructiion Fetch (IF)
│   │   └── instruction_memory.vhd
│   ├── id_stage.vhd		        	# Instruction Decode (ID)
│   │   ├── register_file.vhd
│   │   └── decoder.vhd
│   ├── ex_stage.vhd	 		        # Instruction Execute (EX)
│   │   ├── alu.vhd
│   │   └── comparator.vhd
│   ├── mem_stage.vhd		        	# Data Memory (MEM)
│   └── wb_stage.vhd		        	# Write Back (WB)
│       └── data_mem.vhd
└── top_nexys.vhd		            	# Top Nexys (top level for board + cordic)
    ├── cordic_wrapper.vhd		        # Cordic Wrapper
    │   └── cordic_core.vhd		        # Cordic Algorithm
    ├── debounce_pulse.vhd		    	# Debounce + Pulse Generator for Pushbuttons
    └── seven_seg_driver.vhd	    	# 7 Segements Display Driver

constr/                                 # CONSTRAINTS
└── nexys4ddr.xdc                       # Constraints file for Nexys 4 DDR

tb/					                    # TESTBENCHES
├── tb_if_stage.vhd			            # testbench for IF
├── tb_id_stage.vhd			            # testbench for ID
├── tb_ex_stage.vhd			            # testbench for EX
├── tb_mem_wb_stage.vhd		            # testbench for MEM + WB
├── tb_cpu_top.vhd	 	            	# testbench for Datapath
├── tb_cordic_core.vhd	 	            # testbench for Cordic Algorithm
└── tb_cordic_wrapper.vhd	         	# testbench for Cordic Wrapper

doc/                                    # DOCUMENTATION
├── report.pdf                          # Final report (PDF)
└── latex_project.zip                   # LaTeX sources for the report

```
