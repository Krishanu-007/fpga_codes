# ===========================
#  Dynamic FPGA Build Makefile (Interactive)
# ===========================

# User-provided top module name
top ?=
PCF = pins.pcf
DEVICE = hx8k
PACKAGE = cb132

# Default target
all: $(top).bin

# ---------------------------
#  Build Flow (Step-by-step)
# ---------------------------

$(top).json: $(top).v
	@echo ""
	@echo "🔧 STEP 1: Synthesizing $(top).v ..."
	@echo "⏳ Waiting 2 seconds before starting synthesis..."
	sleep 2
	@read -p 'Press [Enter] to begin synthesis...' dummy
	yosys -p "synth_ice40 -top $(top) -json $(top).json" $(top).v
	@echo "✅ Synthesis complete: $(top).json generated."
	@echo ""

$(top).asc: $(top).json $(PCF)
	@echo "🏗️  STEP 2: Running nextpnr for $(top) ..."
	@echo "⏳ Waiting 2 seconds before placement & routing..."
	sleep 2
	@read -p 'Press [Enter] to begin nextpnr...' dummy
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(top).json --pcf $(PCF) --asc $(top).asc --placed-svg $(top)_placed.svg --routed-svg $(top)_routed.svg
	@echo "✅ Place-and-Route complete: $(top).asc generated."
	@echo ""

$(top).bin: $(top).asc
	@echo "📦 STEP 3: Packing bitstream ..."
	@echo "⏳ Waiting 2 seconds before bitstream generation..."
	sleep 2
	@read -p 'Press [Enter] to pack bitstream...' dummy
	icepack $(top).asc $(top).bin
	@echo "✅ Bitstream ready: $(top).bin"
	@echo ""

prog: $(top).bin
	@echo "🚀 STEP 4: Uploading to FPGA ..."
	@echo "⚠️  Ensure your Alchitry Cu board is connected."
	@echo "⏳ Waiting 3 seconds before programming..."
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
	@echo "🧹 Cleaning ALL build files ..."
	@echo "⏳ Waiting 2 seconds..."
	sleep 2
	@read -p 'Press [Enter] to confirm cleaning ALL files...' dummy
	rm -f *.json *.asc *.bin
	@echo "✅ All build files removed."
else
	@echo "🧹 Cleaning build files for $(top) ..."
	@echo "⏳ Waiting 2 seconds..."
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
	@echo "  make top=<module_name>        → Build bitstream"
	@echo "  make top=<module_name> prog   → Build + Upload"
	@echo "  make top=<module_name> clean  → Clean specific build files"
	@echo "  make clean                    → Clean ALL build files"
	@echo ""

