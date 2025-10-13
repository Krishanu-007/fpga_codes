# ===========================
#  Dynamic FPGA Build Makefile
# ===========================

# User-provided top module name (e.g., make TOP=ledtest1)
TOP ?= 
PCF = pins.pcf
DEVICE = hx8k
PACKAGE = cb132

# Default target
all: $(TOP).bin

# ---------------------------
#  Build Flow
# ---------------------------

$(TOP).json: $(TOP).v
	@echo "🔧 Synthesizing $(TOP).v ..."
	yosys -p "synth_ice40 -top $(TOP) -json $(TOP).json" $(TOP).v

$(TOP).asc: $(TOP).json $(PCF)
	@echo "🏗️  Running nextpnr for $(TOP) ..."
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(TOP).json --pcf $(PCF) --asc $(TOP).asc

$(TOP).bin: $(TOP).asc
	@echo "📦 Packing bitstream ..."
	icepack $(TOP).asc $(TOP).bin

prog: $(TOP).bin
	@echo "🚀 Uploading to FPGA ..."
	iceprog $(TOP).bin

# ---------------------------
#  Clean Rules
# ---------------------------

clean:
ifeq ($(TOP),)
	@echo "🧹 Cleaning ALL build files ..."
	rm -f *.json *.asc *.bin
else
	@echo "🧹 Cleaning build files for $(TOP) ..."
	rm -f $(TOP).json $(TOP).asc $(TOP).bin
endif

# ---------------------------
#  Help
# ---------------------------

help:
	@echo ""
	@echo "Usage:"
	@echo "  make TOP=<module_name>        → Build bitstream"
	@echo "  make TOP=<module_name> prog   → Build + Upload"
	@echo "  make TOP=<module_name> clean  → Clean specific build files"
	@echo "  make clean                    → Clean ALL build files"
	@echo ""

