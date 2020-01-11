CLK1_NAME=clk_25_system
CLK1_FILE_NAME=../src/sys/$(CLK1_NAME).v
CLK1_OPTIONS=\
  --module=${CLK1_NAME} \
  --clkin_name=clk_in \
  --clkin=25 \
  --clkout0_name=pll_125 \
  --clkout0=125 \
  --clkout1_name=pll_75 \
  --clkout1=75 \
  --clkout2_name=pll_25 \
  --clkout2=25 \
  --clkout3_name=pll_33 \
  --clkout3=3.25 \

VERILOG = ../src/top/jupiter_ace_ulx3s.v \
    ../src/sys/clk_25_system.v ../src/sys/ps2.v ../src/sys/dvi.v \
    ../src/fpga_ace.v ../src/jace_logic.v ../src/memory.v ../src/keyboard_for_ace.v \
    ../src/cpu/tv80n.v ../src/cpu/tv80_core.v ../src/cpu/tv80_alu.v \
    ../src/cpu/tv80_reg.v ../src/cpu/tv80_mcode.v

PIN_DEF = ulx3s_ace.lpf

include ulx3s.mk

