DEVICE ?= 25k
PIN_DEF ?= ulx3s_v20.lpf
IDCODE ?= 0x21111043 # 12f

# ******* tools installation paths *******
# https://github.com/ldoolitt/vhd2vl
VHDL2VL ?= /mt/scratch/tmp/openfpga/vhd2vl/src/vhd2vl
# https://github.com/YosysHQ/yosys
YOSYS ?= /mt/scratch/tmp/openfpga/yosys/yosys
# https://github.com/YosysHQ/nextpnr
NEXTPNR-ECP5 ?= /mt/scratch/tmp/openfpga/nextpnr/nextpnr-ecp5
# https://github.com/SymbiFlow/prjtrellis
TRELLIS ?= /mt/scratch/tmp/openfpga/prjtrellis

# open source synthesis tools
ECPPLL ?= $(TRELLIS)/libtrellis/ecppll
ECPPACK ?= $(TRELLIS)/libtrellis/ecppack
TRELLISDB ?= $(TRELLIS)/database
LIBTRELLIS ?= $(TRELLIS)/libtrellis
BIT2SVF ?= $(TRELLIS)/tools/bit_to_svf.py
#BASECFG ?= $(TRELLIS)/misc/basecfgs/empty_$(FPGA_CHIP_EQUIVALENT).config
# yosys options, sometimes those can be used: -noccu2 -nomux -nodram
YOSYS_OPTIONS ?= 
# nextpnr options
NEXTPNR_OPTIONS ?=


BUILDDIR = bin

compile: $(BUILDDIR)/toplevel.bit

prog: $(BUILDDIR)/toplevel.bit
	ujprog $^

$(CLK1_FILE_NAME): Makefile
	LANG=C LD_LIBRARY_PATH=$(LIBTRELLIS) $(ECPPLL) $(CLK1_OPTIONS) --file $@	

$(BUILDDIR)/toplevel.json: $(VERILOG)
	mkdir -p $(BUILDDIR)
	$(YOSYS) -p "synth_ecp5 -json $@" $^

$(BUILDDIR)/%.config: $(PIN_DEF) $(BUILDDIR)/toplevel.json
	$(NEXTPNR-ECP5) --${DEVICE} --package CABGA381 --freq 25 --textcfg  $@ --json $(filter-out $<,$^) --lpf $< 

$(BUILDDIR)/toplevel.bit: $(BUILDDIR)/toplevel.config
	LANG=C LD_LIBRARY_PATH=$(LIBTRELLIS) $(ECPPACK) --db $(TRELLISDB) --compress --idcode ${IDCODE} $^ $@

clean:
	rm -rf ${BUILDDIR}

.SECONDARY:
.PHONY: compile clean prog
