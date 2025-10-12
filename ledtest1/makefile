TOP = ledtest1
PCF = ../pins.pcf
DEVICE = hx8k
PACKAGE = cb132

all: $(TOP).bin

$(TOP).json: $(TOP).v
	yosys -p "synth_ice40 -top $(TOP) -json $(TOP).json" $(TOP).v

$(TOP).asc: $(TOP).json
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(TOP).json --pcf $(PCF) --asc $(TOP).asc

$(TOP).bin: $(TOP).asc
	icepack $(TOP).asc $(TOP).bin

prog: $(TOP).bin
	iceprog $(TOP).bin

clean:
	rm -f $(TOP).json $(TOP).asc $(TOP).bin

