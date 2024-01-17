# ARM Single Core 4 Pipeline CPU RTL Design

This project is the RTL design of an ARM single core 4 pipeline CPU. It is implemented in VHDL and can be simulated using GHDL.

## Prerequisites

Ensure that you have GHDL installed on your system. You may need to adjust the GHDL path in the Makefile located in the TB folder to match your system configuration.

## Simulation and Testing

To simulate and test the processor, follow these steps:

1. Navigate to the TB folder and run the make command:

```bash
cd TB
make
```

2. Navigate back to the main folder and run the make command:

```bash
cd ..
make
```

3. Run the following command to generate the graphs:

```bash
./main_tb ../test_pgcd --vcd=test.vcd
```

4. Use the following command to visualize the graphs:

```bash
gtkwave test.vcd
```

Please note that the gtkwave tool is required to visualize the vcd files. If it's not installed, you can install it using your package manager.