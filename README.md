# FPGA Codes

This repository will contain the pre-requisite ideas and test files that I need to work,practice and learn for my FPGA works. Final idea is about creating a IP block that I will synthesis on my FPGAs (As of now Alchitry, later on Shrike-lite by Vicharak) before entering into Openlane for the Digital ASIC designs.

---
## Progress
Each follow-up project will somehow increase in difficulty and lead to development of concepts that will finally contribute to the larger project designs.

---
## Tools and Setup Used

I am using the open-source tool-chain for the Alchitry Cu board (based on Lattice iCE40HX8K FPGA) which includes- yosys(synthesis), next-pnr(placement & route), icestorm(for binary creation and programming) The installation of the tools are given below:

### FPGA Toolchain Installation Guide
This guide covers installation of **Yosys**, **nextpnr**, and **Icestorm**, the open-source FPGA toolchain for **Lattice iCE40 FPGAs**.



#### 1. Update System
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git build-essential cmake python3 python3-pip clang bison flex libreadline-dev gawk tcl-dev libffi-dev mercurial graphviz xdot pkg-config

```
#### 2. Install Yosys
```bash
git clone https://github.com/YosysHQ/yosys.git
cd yosys
make -j$(nproc)
sudo make install
cd ..
yosys -V # Verify installation
```

#### 3. Install iCEStorm(iCE40 FPGA tools)
```bash
git clone https://github.com/cliffordwolf/icestorm.git
cd icestorm

# Build and install
make -j$(nproc)
sudo make install
cd ..

# Verify installation
iceprog -h
```

#### 4. Install nextpnr (Place & Route)
```bash
# Clone nextpnr repository
git clone https://github.com/YosysHQ/nextpnr.git
cd nextpnr

# Create build folder
mkdir build && cd build

# Build with iCE40 backend
cmake .. -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local
make -j$(nproc)
sudo make install

# Verify installation
nextpnr-ice40 --help

```

With this you have successfully installed the open-source FPGA toolchain for Lattice iCE40 FPGAs.

---
## Usage

The basic flow to synthesize and program a design onto the FPGA is as follows:
1. Write your Verilog code and save it in a `.v` file.
2. Create a constraints file (`.pcf`) to map your design's pins to the FPGA pins.
3. Use Yosys to synthesize the Verilog code into a netlist.
```bash
yosys -p "synth_ice40 -top <top_module_name> -json <output_file.json>" <input_file.v>
```
4. Use nextpnr to place and route the design.
```bash
nextpnr-ice40 --hx8k --package <package_name> --json <output_file.json> --pcf <constraints_file.pcf> --asc <output_file.asc>
```
5. Use icepack to convert the ASCII file to a binary file.
```bash
icepack <output_file.asc> <output_file.bin>
```
6. Use iceprog to program the binary file onto the FPGA.
```bash
iceprog <output_file.bin>
```

With these steps, one should be able to successfully synthesize and program a design onto the FPGA. However, for long processes, it is advisable to create a Makefile to automate the steps. 

---

## Makefile Usage Guide
 The makefile will contain the commands to automate the synthesis,place & route, binary creation and programming steps. The explanation of the makefile is given below:

#### 🎯 Configuration Variables
```makefile
top ?=              # Module name (provided by user)
PCF = pins.pcf      # Pin constraint file
DEVICE = hx8k       # FPGA chip model
PACKAGE = cb132     # Package type
```

- **`top`**: The name of your top-level Verilog module (you provide this when running `make`)
- **`PCF`**: Maps Verilog signals to physical FPGA pins
- **`DEVICE/PACKAGE`**: Specifies the exact FPGA hardware
#### 🔄 Build Pipeline (4 Steps)

##### Step 1: Synthesis → `$(top).json`
```makefile
yosys -p "synth_ice40 -top $(top) -json $(top).json" $(top).v
```

- **Tool**: Yosys
- **Input**: `$(top).v` (your Verilog code)
- **Output**: `$(top).json` (logical netlist)
- **What it does**: Converts Verilog into a hardware description using iCE40 primitives

##### Step 2: Place & Route → `$(top).asc`
```makefile
nextpnr-ice40 --hx8k --package cb132 --json $(top).json --pcf pins.pcf --asc $(top).asc
```

- **Tool**: nextpnr
- **Inputs**: JSON netlist + pin constraints
- **Output**: `$(top).asc` (ASCII bitstream config)
- **What it does**: Maps logic to physical FPGA resources and routes connections
- **Bonus**: Generates SVG visualizations of placement/routing

##### Step 3: Bitstream Packing → `$(top).bin`
```makefile
icepack $(top).asc $(top).bin
```

- **Tool**: icepack
- **Converts**: ASCII config → binary bitstream
- **Output**: `$(top).bin` (ready for upload)

##### Step 4: Programming → `prog` target
```makefile
iceprog $(top).bin
```

- **Tool**: iceprog
- **What it does**: Uploads bitstream to the FPGA via USB


#### 🧹 Cleaning Rules

##### Clean specific module:
```bash
make top=blinker clean
```

Removes only `blinker.json`, `blinker.asc`, `blinker.bin`, etc.

##### Clean everything:
```bash
make clean
```

Removes **all** `.json`, `.asc`, `.bin` files (prompts for confirmation)

#### ⚠️ Prerequisites

You need these tools installed:

- `yosys` (Verilog synthesis)
- `nextpnr-ice40` (place & route)
- `icepack` (bitstream packing)
- `iceprog` (FPGA programming)

All are part of the open-source iCE40 toolchain (IceStorm project).


#### 📊 Build Flow Diagram
```
┌─────────────┐
│  $(top).v   │ (Your Verilog code)
└──────┬──────┘
       │ yosys (synthesis)
       ▼
┌─────────────┐
│ $(top).json │ (Logical netlist)
└──────┬──────┘
       │ nextpnr (place & route)
       ▼
┌─────────────┐
│ $(top).asc  │ (ASCII bitstream)
└──────┬──────┘
       │ icepack (packing)
       ▼
┌─────────────┐
│ $(top).bin  │ (Binary bitstream)
└──────┬──────┘
       │ iceprog (programming)
       ▼
┌─────────────┐
│  FPGA 🎯    │
└─────────────┘
```


#### 💡 Tips

- Always specify the `top` variable: `make top=mymodule`
- Use `make help` if you forget the commands
- Check generated SVG files to visualize your design layout
- The interactive prompts can be removed by deleting the `sleep` and `@read` lines if you want faster builds

 This Makefile is designed to **synthesize, place & route, generate bitstream, and program an iCE40 FPGA** (like Alchitry Cu) interactively, with pauses and user prompts at each step.



---

## Constraints of the Board
For each of the project that will be uploaded is solely done on the Alchitry Cu board. The board contains 8 on-board LEDs and a single RESET button(Active LOW). Hence the switch that I am using in the projects is actually the RESET button of the board.

---

## Folder Structure
As of now I am learning the usage of makefile and hence there's no separate folder for each project. All are kept in the root directory. However, in future I will create separate folders for each project. To compensate this issue I have included the feature of cleaning specific project files in the makefile.

In case you want to know how to use the make file please refer to [Makefile Usage Guide](#makefile-usage-guide)

---
## Projects

Here are the projects that are being uploaded. Each project develops a certain concept that will be useful in the final design of the IP block.

### ledtest1:
 This project is the basic "Hello World" equivalent for FPGA. It simply blinks an LED on the Alchitry Cu board when the switch is being pressed and hold.

 ### ledtest2:
This project is just having a reversed logic of ledtest1. 

### toggle:
This project is a simple toggle switch. When the switch is pressed once, the LED turns ON and remains ON until the switch is pressed again.

### switch_toggle:
This project is an advanced version of the toggle switch. Here, the LED toggles its state from one pattern to another fixed pattern(basically jumps between two patterns) each time the switch is pressed.






