`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Create Date: 10/1/2015 V1.0
// Design Name: 
// Module Name: nexys
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module nexys(
   input CLK100MHZ,
   input[15:0] SW, 
   input BTNC, BTNU, BTNL, BTNR, BTND,
   output[3:0] VGA_R, 
   output[3:0] VGA_B, 
   output[3:0] VGA_G,
   output[7:0] JA, 
   output VGA_HS, 
   output VGA_VS, 
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output[15:0] LED,
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );
    
    // 65MHz clock generation from IP
    wire locked;
    wire clock_65mhz;
    reg reset;
    clk_wiz_0 gen_65mhz(.clk_100mhz(CLK100MHZ), .clk_65mhz(clock_65mhz), .reset(reset), .locked(locked));
    
// create 25mhz system clock
    wire clock_25mhz;
    clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

//  instantiate 7-segment display;  
    wire [31:0] data;
    wire [6:0] segments;
    display_8hex display8hex(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));    
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;

//////////////////////////////////////////////////////////////////////////////////
//
//  remove these lines and insert your lab here

    assign LED = SW;     
    assign JA[7:1] = 7'b0;
    assign JA[0] = clock_65mhz;
    assign data = {28'h0123456, SW[3:0]};   // display 0123456 + SW
    assign LED16_R = BTNL;                  // left button -> red led
    assign LED16_G = BTNC;                  // center button -> green led
    assign LED16_B = BTNR;                  // right button -> blue led
    assign LED17_R = BTNL;
    assign LED17_G = BTNC;
    assign LED17_B = BTNR; 



//
//////////////////////////////////////////////////////////////////////////////////




 
//////////////////////////////////////////////////////////////////////////////////
// sample Verilog to generate color bars
    
    //inputs and outputs
    wire [10:0] hcount; //vga
    wire [9:0] vcount; //vga
    wire hsync, vsync, blank; //vga
    
    wire [11:0] p_rgb; //current output pixel
    
    wire [10:0] p_offset; //current player horizontal position (positive as wave moves left)
    wire [9:0] p_vpos; //current player vertical position
    wire [9:0] wave_prof[1023:0]; //current waveform profile
    wire [9:0] prev_wave_prof[1023:0];
    
    wire [10:0] frequency;
    assign frequency = 11'b0;
    wire new_f;
    assign new_f = 0;
    wire wave_ready;
    
    reg [9:0] disp_wave;
    reg wave_clk;
    
    
    //parameters only for later calculations; do not change
    parameter SCREEN_HEIGHT = 768;
    parameter SCREEN_WIDTH = 1024;
    
    xvga vga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.blank(blank));
    
    //wave_logic wave_logic(.reset(reset), .clock(clock_65mhz), .frequency(frequency), .new_f(new_f),
    //                      .wave_prof(wave_prof), .prev_wave_prof(prev_wave_prof), .wave_ready(wave_ready));
    
    
    display display(.reset(reset), .p_offset(p_offset), .p_vpos(p_vpos), .wave_prof(disp_wave), 
                    .wave_clk(wave_clk), .vclock(clock_65mhz), .hcount(hcount), .vcount(vcount),
                    .hsync(hsync), .vsync(vsync), .blank(blank), .p_rgb(p_rgb));
    
    
        
    assign VGA_R = blank ? 0: p_rgb[11:8];
    assign VGA_G = blank ? 0: p_rgb[7:4];
    assign VGA_B = blank ? 0: p_rgb[3:0];
    assign VGA_HS = ~hsync;
    assign VGA_VS = ~vsync;
    
    
    initial begin
        reset = 0;
    end
    
endmodule

