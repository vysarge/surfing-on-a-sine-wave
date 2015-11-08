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
    
    //65MHz clock generation from IP
    wire locked;
    wire clock_65mhz;
    clk_wiz_0 gen_65mhz(.clk_100mhz(CLK100MHZ), .clk_65mhz(clock_65mhz), .reset(reset), .locked(locked));
    
    //reset signal
    wire power_on_reset;    // remain high for first 16 clocks
    SRL16 reset_sr (.D(1'b0), .CLK(clock_65mhz), .Q(power_on_reset),
               .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
    defparam reset_sr.INIT = 16'hFFFF;
    
    //user reset
    wire reset,user_reset;
    debounce center(.reset(power_on_reset),.clock(clock_65mhz),.noisy(BTNC),.clean(user_reset));
    assign reset = user_reset | power_on_reset;
    
    
    
    
    
// create 25mhz system clock
    //wire clock_25mhz;
    //clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

//  instantiate 7-segment display;  
    wire [31:0] data;
    wire [6:0] segments;
    display_8hex display8hex(.clk(clock_65mhz),.data(data), .seg(segments), .strobe(AN));    
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;

//////////////////////////////////////////////////////////////////////////////////
//
//  remove these lines and insert your lab here

    //assign LED = SW;     
    assign JA[7:1] = 7'b0;
    assign JA[0] = clock_65mhz;
    //assign data = {28'h0123456, SW[3:0]};   // display 0123456 + SW
    assign LED16_R = BTNL;                  // left button -> red led
    assign LED16_G = BTNC;                  // center button -> green led
    assign LED16_B = BTNR;                  // right button -> blue led
    assign LED17_R = BTNL;
    assign LED17_G = BTNC;
    assign LED17_B = BTNR; 



//
//////////////////////////////////////////////////////////////////////////////////




 
//////////////////////////////////////////////////////////////////////////////////
// temporary organization / testing rig for peripheral modules
    
    //parameters only for later calculations; do not change
    parameter SCREEN_HEIGHT = 768;
    parameter SCREEN_WIDTH = 1024;
    
    //inputs and outputs
    wire [10:0] hcount; //vga
    wire [9:0] vcount; //vga
    wire hsync, vsync, blank; //vga
    
    wire [11:0] p_rgb; //current output pixel
    
    reg [10:0] p_offset; //current player horizontal position (positive as wave moves left)
    reg [9:0] p_vpos; //current player vertical position
    reg [9:0] wave_prof[1023:0]; //current waveform profile
    reg [9:0] prev_wave_prof[1023:0];
    
    wire [10:0] frequency;
    assign frequency = 11'b0;
    wire new_f;
    assign new_f = 0;
    wire wave_ready;
    
    
    wire [9:0] disp_wave;
    reg wave_we;
    reg [10:0] wave_index;
    wire disp_sel; // if 0, display horizontal profile.  If 1, display ramp
    reg prev_disp_sel; //previous value of disp_sel; 65mhz
    reg prev_up, prev_down, prev_left, prev_right;
    
    //button outputs
    wire up;
    wire down;
    wire left;
    wire right;
    
    //assigning buttons
    debounce sw0(.reset(reset),.clock(clock_65mhz),.noisy(SW[0]),.clean(disp_sel));
    debounce dbu(.reset(reset),.clock(clock_65mhz),.noisy(BTNU),.clean(up));
    debounce dbd(.reset(reset),.clock(clock_65mhz),.noisy(BTND),.clean(down));
    debounce dbl(.reset(reset),.clock(clock_65mhz),.noisy(BTNL),.clean(left));
    debounce dbr(.reset(reset),.clock(clock_65mhz),.noisy(BTNR),.clean(right));
    
    
    initial begin
        p_vpos = 384;
        wave_index = 0;
    end
    
    assign disp_wave = disp_sel ? wave_index[9:0] : 10'd384;
    
    always @(posedge clock_65mhz) begin
        prev_disp_sel <= disp_sel;
        prev_up <= up;
        prev_down <= down;
        prev_left <= left;
        prev_right <= right;
        
        
        
        if (prev_disp_sel != disp_sel) begin
            wave_index <= 0;
            wave_we <= 1;
        end
        else begin
            if (wave_index < 1024) begin
                wave_we <= 1;
                wave_index <= wave_index + 1;
                
            end
            else begin
                wave_we <= 0;
            end
            
            if ((up & !prev_up) & (p_vpos > 0)) begin
                p_vpos <= p_vpos - 100;
            end
            else if ((down & !prev_down) & (p_vpos < SCREEN_HEIGHT-1)) begin
                p_vpos <= p_vpos + 100;
            end
            else begin
                p_vpos <= p_vpos;
            end
        end
        
    end
    
    
    
    xvga vga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.blank(blank));
    
    //wave_logic wave_logic(.reset(reset), .clock(clock_65mhz), .frequency(frequency), .new_f(new_f),
    //                      .wave_prof(wave_prof), .prev_wave_prof(prev_wave_prof), .wave_ready(wave_ready));
    
    wire[9:0] vpos;
    display display(.reset(reset), .p_offset(p_offset), .p_vpos(p_vpos), .wave_prof(disp_wave), .wave_index(wave_index),
                    .wave_we(wave_we), .vclock(clock_65mhz), .hcount(hcount), .vcount(vcount),
                    .hsync(hsync), .vsync(vsync), .blank(blank), .p_rgb(p_rgb));
    
    
        
    assign VGA_R = blank ? 0: p_rgb[11:8];
    assign VGA_G = blank ? 0: p_rgb[7:4];
    assign VGA_B = blank ? 0: p_rgb[3:0];
    assign VGA_HS = ~hsync;
    assign VGA_VS = ~vsync;
    
    //test outputs
    //assign data[11:0] = {1'b0, reset_count}; //last three digits disp_wave
    assign data[31:20] = {2'b0, p_vpos}; //first three digits wave_index
    assign LED[0] = 1;
    assign LED[1] = up;
    assign LED[2] = down;
    
endmodule

