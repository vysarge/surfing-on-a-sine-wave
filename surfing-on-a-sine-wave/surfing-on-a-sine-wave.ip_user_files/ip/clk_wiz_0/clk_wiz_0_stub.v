// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.3 (win64) Build 1368829 Mon Sep 28 20:06:43 MDT 2015
// Date        : Sun Nov 08 13:57:59 2015
// Host        : Dell running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/User/Documents/6.111/surfing-on-a-sine-wave/surfing-on-a-sine-wave/surfing-on-a-sine-wave.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_100mhz, clk_65mhz, clk_25mhz, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_100mhz,clk_65mhz,clk_25mhz,reset,locked" */;
  input clk_100mhz;
  output clk_65mhz;
  output clk_25mhz;
  input reset;
  output locked;
endmodule
