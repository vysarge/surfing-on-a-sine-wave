// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.4.1 (lin64) Build 1149489 Thu Feb 19 16:01:47 MST 2015
// Date        : Tue Nov  3 17:32:35 2015
// Host        : eecs-digital-52 running 64-bit Ubuntu 12.04.5 LTS
// Command     : write_verilog -force -mode synth_stub
//               /afs/athena.mit.edu/user/v/y/vysarge/a/6.111/surfing-on-a-sine-wave/surfing-on-a-sine-wave/surfing-on-a-sine-wave.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_100mhz, clk_65mhz, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_100mhz,clk_65mhz,reset,locked" */;
  input clk_100mhz;
  output clk_65mhz;
  input reset;
  output locked;
endmodule
