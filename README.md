# Verilog playground
This repo contains code for tasks done in Verilog as part of Computer Architecture labs (CS F342)

## Requirements
- To run these files, [install](https://iverilog.fandom.com/wiki/Installation_Guide) Icarus Verilog in your local system

## Steps to execute (on Windows)
- Suppose you have written your verilog code in `example.v`, follow the below steps:
  - Step 1: Change your current working directory to `iverilog\bin` in your command prompt (for Windows)
  - Step 2: Compile the file using:
    ```
    iverilog -o example.vvp example.v
    ```
  - Step 3: Run the `.vvp` using:
    ```
    vvp example.vvp
    ```
  - Step 4: To see waveform make sure to add in testbench the required commands to create the `.vcd` file and run it using:
    ```
    gtkwave example.vcd
    ```
