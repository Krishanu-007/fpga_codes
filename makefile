# ===========================
#  Dynamic FPGA Build Makefile (Hierarchical-Aware)
# ===========================

# Example usage:
#   make top=top_module main.v submodule1.v submodule2.v
#   make top=top_module prog main.v sub1.v sub2.v
#   make clean
#
# Automatically handles hierarchical Verilog files.

# ---------------------------
#  User Configurable Settings
# ---------------------------

PCF      = pins.pcf
DEVICE   = hx8k
PACKAGE  = cb132

# Default target
all: $(top).bin

# ---------------------------
#  Internal Variables
# ---------------------------

# Filter out make targets and keep only Verilog sources
# $(MAKECMDGOALS) removes targets like 'prog' or 'clean'
# $(filter %.v,$(MAKECMDGOALS)) gives us the list of Verilog source files
SRC_FILES := $(filter %.v,$(MAKECMDGOALS))

# If no extra files provided, default to $(top).v
ifeq ($(SRC_FILES),)
SRC_FILES := $(top).v
endif

# ---------------------------
#  Build Flow
# ---------------------------

$(top).json: $(SRC_FILES)
	@echo ""
	@echo "🔧 STEP 1: Synthesizing design..."
	@echo "   ➤ Top module: $(top)"
	@echo "   ➤ Source files: $(SRC_FILES)"
	@echo ""
	sleep 2
	@read -p 'Press [Enter] to begin synthesis...' dummy
	yosys -p "synth_ice40 -top $(top) -json $(top).json" $(SRC_FILES)
	@echo "✅ Synthesis complete: $(top).json generated."
	@echo ""

$(top).asc: $(top).json $(PCF)
	@echo "🏗️  STEP 2: Running nextpnr for $(top)..."
	@echo ""
	sleep 2
	@read -p 'Press [Enter] to begin place & route...' dummy
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) \
		--json $(top).json --pcf $(PCF) --asc $(top).asc \
		--placed-svg $(top)_placed.svg --routed-svg $(top)_routed.svg
	@echo "✅ Place-and-Route complete: $(top).asc generated."
	@echo ""

$(top).bin: $(top).asc
	@echo "📦 STEP 3: Packing bitstream..."
	@echo ""
	sleep 2
	@read -p 'Press [Enter] to pack bitstream...' dummy
	icepack $(top).asc $(top).bin
	@echo "✅ Bitstream ready: $(top).bin"
	@echo ""

prog: $(top).bin
	@echo "🚀 STEP 4: Uploading to FPGA..."
	@echo "⚠️  Ensure your Alchitry Cu board is connected."
	sleep 3
	@read -p 'Press [Enter] to flash the FPGA...' dummy
	iceprog $(top).bin
	@echo "✅ FPGA programmed successfully!"
	@echo ""

# ---------------------------
#  Clean Rules
# ---------------------------

clean:
ifeq ($(top),)
	@echo "🧹 Cleaning ALL build files..."
	sleep 2
	@read -p 'Press [Enter] to confirm cleaning ALL files...' dummy
	rm -f *.json *.asc *.bin *_placed.svg *_routed.svg
	@echo "✅ All build files removed."
else
	@echo "🧹 Cleaning build files for $(top)..."
	sleep 2
	@read -p 'Press [Enter] to confirm cleaning $(top) files...' dummy
	rm -f $(top).json $(top).asc $(top).bin $(top)_placed.svg $(top)_routed.svg
	@echo "✅ Build files for $(top) removed."
endif
	@echo ""

# ---------------------------
#  Help
# ---------------------------

help:
	@echo ""
	@echo "📘 Usage:"
	@echo "  make top=<top_module> main.v [submodules.v ...]       → Build bitstream"
	@echo "  make top=<top_module> prog main.v [submodules.v ...]  → Build + Upload"
	@echo "  make top=<top_module> clean                           → Clean specific build files"
	@echo "  make clean                                            → Clean ALL build files"
	@echo ""

# Avoid errors when multiple file names passed
%:
	@true

