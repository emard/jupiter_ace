`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    17:18:12 11/07/2015
// Design Name:
// Module Name:    jupiter_ace
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module jupiter_ace (
    input wire         clk25,
    input wire         clkps2,
    input wire         dataps2,
    input wire         ear,
    output wire        audio_out_left,
    output wire        audio_out_right,

    output wire [3:0]  gpdi_dp, gpdi_dn,
    output             usb_fpga_pu_dp,
    output             usb_fpga_pu_dn,
    output [7:0]       led,
    input [6:0]        btn
  );

  assign usb_fpga_pu_dp = 1;
  assign usb_fpga_pu_dn = 1;

  wire kbd_reset;
  wire [7:0] kbd_rows;
  wire [4:0] kbd_columns;
  wire video; // 1-bit video signal (black/white)


  // Trivial conversion for audio
  wire mic,spk;
  assign audio_out_left  = spk;
  assign audio_out_right = mic;
  
  // Video timing
  wire vga_hsync, vga_vsync, vga_blank;

  // Power-on RESET (8 clocks)
  reg [7:0] poweron_reset = 8'h00;
  always @(posedge clkcpu) begin
    poweron_reset <= {poweron_reset[6:0],1'b1};
  end

  wire clkdvi;
  wire clkram; 
  wire clkvga; 
  wire clkcpu; 

  clk_25_system
  clk_25_system_inst
  (
    .clk_in(clk25),
    .pll_125(clkdvi), // 125 Mhz, DDR bit rate
    .pll_75(clkram),  //  75 Mhz, treat bram as async
    .pll_25(clkvga),  //  25 Mhz, VGA pixel rate
    .pll_33(clkcpu)   //  3.25 Mhz, CPU clock
  );

  fpga_ace the_core (
    .clkram(clkram),
    .clk65(clkvga),
    .clkcpu(clkcpu),
    .reset(kbd_reset & poweron_reset[7] & btn[0]),
    .ear(ear),
    .filas(kbd_rows),
    .columnas(kbd_columns),
    .video(video),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .blank(vga_blank),
    .mic(mic),
    .spk(spk)
  );

  keyboard_for_ace the_keyboard (
    .clk(clkvga),
    .clkps2(clkps2),
    .dataps2(dataps2),
    .rows(kbd_rows),
    .columns(kbd_columns),
    .kbd_reset(kbd_reset),
    .kbd_nmi(),
    .kbd_mreset(),
    .led(led)
  );

  HDMI_out vga2dvid (
    .pixclk(clkvga),
    .pixclk_x5(clkdvi),
    .red({8{video}}),
    .green({8{video}}),
    .blue({8{video}}),
    .vde(!vga_blank),
    .hSync(vga_hsync),
    .vSync(vga_vsync),
    .gpdi_dp(gpdi_dp),
    .gpdi_dn(gpdi_dn)
);

endmodule