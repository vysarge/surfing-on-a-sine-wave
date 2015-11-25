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
   input [7:0] JA, 
   output[3:0] VGA_R, 
   output[3:0] VGA_B, 
   output[3:0] VGA_G,
   output VGA_HS, 
   output VGA_VS, 
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output[15:0] LED,
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );
    
    //65MHz clock generation from IP
    wire reset,user_reset;
    reg clk_reset;
    wire power_on_reset;    // remain high for first 16 clocks
    wire locked;
    wire clock_65mhz;
    wire clock_25mhz;
    
    clk_wiz_0 gen(.clk_100mhz(CLK100MHZ), .clk_65mhz(clock_65mhz), .clk_25mhz(clock_25mhz), .reset(clk_reset), .locked(locked));
    
    //reset signal
    SRL16 reset_sr (.D(1'b0), .CLK(clock_25mhz), .Q(power_on_reset),
               .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
    defparam reset_sr.INIT = 16'hFFFF;
    
    //user reset
    debounce center(.reset(power_on_reset),.clock(clock_25mhz),.noisy(BTNC),.clean(user_reset));
    assign reset = user_reset | power_on_reset;
    
    
    
    
    
// create 25mhz system clock
    
    //clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

//  instantiate 7-segment display;  
    wire [31:0] data;
    wire [6:0] segments;
    display_8hex display8hex(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));    
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;

//////////////////////////////////////////////////////////////////////////////////
//
//  remove these lines and insert your lab here

    //assign LED = SW;     
    //assign data = {28'h0123456, SW[3:0]};   // display 0123456 + SW

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
    reg [10:0] prev_hcount;
    reg [9:0] prev_vcount;
    wire hsync, vsync, blank; //vga
    reg prev_hsync, prev_vsync, prev_blank; //previous values
    reg [10:0] prev2_hcount;
    reg [9:0] prev2_vcount;
    reg prev2_hsync, prev2_vsync, prev2_blank; //previous previous values (for pipelining)
    reg [10:0] prev3_hcount;
    reg [9:0] prev3_vcount;
    reg prev3_hsync, prev3_vsync, prev3_blank; //etc
    
    wire [11:0] p_rgb; //current output pixel
    
    wire [10:0] p_offset; //current player horizontal position (positive as wave moves left)
    wire [9:0] p_vpos; //current player vertical position
    reg [9:0] wave_prof[1023:0]; //current waveform profile
    reg [9:0] prev_wave_prof[1023:0];
    
    //object data registers; see display module for details
    wire [25:0] obj1, obj2, obj3, obj4, obj5;
    reg [2:0] obj_frame_counter;
    
    wire [4:0] freq_id;
    //assign freq_id = SW[15:11];
    wire new_f;
    
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
    debounce sw0(.reset(reset),.clock(clock_25mhz),.noisy(SW[0]),.clean(disp_sel));
    debounce dbu(.reset(reset),.clock(clock_25mhz),.noisy(BTNU),.clean(up));
    debounce dbd(.reset(reset),.clock(clock_25mhz),.noisy(BTND),.clean(down));
    debounce dbl(.reset(reset),.clock(clock_25mhz),.noisy(BTNL),.clean(left));
    debounce dbr(.reset(reset),.clock(clock_25mhz),.noisy(BTNR),.clean(right));
    
    
    assign LED16_R = left;                  // left button -> red led
    assign LED16_G = BTNC;                  // center button -> green led
    assign LED16_B = right;                  // right button -> blue led
    
    /*
    initial begin
        p_vpos = 384;
        wave_index = 0;
        
        obj1 = 26'b000_00_00100000000_0100000000;
        obj2 = 0;
        obj3 = 0;
        obj4 = 0;
        obj5 = 0;
        obj_frame_counter = 0;
    end
    */
    
    /*each frame
    always @(posedge vsync) begin
        //for testing purposes, constantly step p_offset by one
        
        if (p_offset < SCREEN_WIDTH) begin
            p_offset <= p_offset + 1;
        end
        else begin
            p_offset <= 0;
        end
        
        //increment frame counter so that obj appears to rotate roughly once a second
        obj_frame_counter <= obj_frame_counter + 1; //3 bits; changes display frame once every 8 vga frames
        if (obj_frame_counter == 0) begin
            obj1[25:23] <= obj1[25:23] + 1;
        end
    end
    */
    
    //it's quite important that prev_hcount be used here; otherwise there will be a horizontal offset
    //assign disp_wave = disp_sel ? prev_hcount[9:0] : 10'd384;
    
    always @(posedge clock_65mhz) begin
        //updating previous variables
        prev_hcount <= hcount;
        prev_vcount <= vcount;
        prev_vsync <= vsync;
        prev_hsync <= hsync;
        prev_blank <= blank;
        prev2_hcount <= prev_hcount;
        prev2_vcount <= prev_vcount;
        prev2_vsync <= prev_vsync;
        prev2_hsync <= prev_hsync;
        prev2_blank <= prev_blank;
        prev3_hcount <= prev2_hcount;
        prev3_vcount <= prev2_vcount;
        prev3_vsync <= prev2_vsync;
        prev3_hsync <= prev2_hsync;
        prev3_blank <= prev2_blank;
        prev_disp_sel <= disp_sel;
        prev_up <= up;
        prev_down <= down;
        prev_left <= left;
        prev_right <= right;
        
        /*
        //flash new_f when SW0 goes high
        if (disp_sel & (prev_disp_sel == 0)) begin
            new_f <= 1;
        end
        else begin
            new_f <= 0;
        end
        
        
        //update player position
        if (prev2_hcount == 0) begin
            p_vpos <= disp_wave - 10; 
        end
        
        /*if (prev_disp_sel != disp_sel) begin
            //wave_index <= 0;
            //wave_we <= 1;
        end
        else begin
            /*if (wave_index < 1024) begin
                wave_we <= 1;
                wave_index <= wave_index + 1;
                
            end
            else begin
                wave_we <= 0;
            end*/
            
            /*if ((up & !prev_up) & (p_vpos > 0)) begin
                p_vpos <= p_vpos - 100;
            end
            else if ((down & !prev_down) & (p_vpos < SCREEN_HEIGHT-1)) begin
                p_vpos <= p_vpos + 100;
            end
            else begin
                p_vpos <= p_vpos;
            end
        end*/
        
        
        
    end
    
    
    
    xvga vga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.blank(blank));
    
    //wave_logic wave_logic(.reset(reset), .clock(clock_65mhz), .frequency(frequency), .new_f(new_f),
    //                      .wave_prof(wave_prof), .prev_wave_prof(prev_wave_prof), .wave_ready(wave_ready));
    
    wire [10:0] p_index;
    //assign p_index = hcount + p_offset;
    wave_logic wave_logic(.reset(reset), .clock(clock_65mhz), .freq_id(freq_id), .new_f(new_f), .index(p_index),
                          .wave_height(disp_wave), .wave_ready(wave_ready));
    
    wire midi_ready;
    wire [6:0] key_index;
    midi kb(.clk(clock_65mhz),.serial(JA[0]),.ready(midi_ready),.key_index(key_index));
    //assign freq_id = key_index - 7'd48;
    
    
    
    
    //wire[9:0] vpos;
    display display(.reset(reset), .p_offset(p_offset), .p_vpos(p_vpos), .char_frame(SW[2:1]), .wave_prof(disp_wave), 
                    .vclock(clock_65mhz), .hcount(prev_hcount), .vcount(prev_vcount),
                    .p_obj1(obj1), .p_obj2(obj2), .p_obj3(obj3), .p_obj4(obj4), .p_obj5(obj5),
                    .hsync(prev_hsync), .vsync(prev_vsync), .blank(prev_blank), .p_rgb(p_rgb));
                    
    game_logic gfsm (.clock(clock_65mhz),.midi_index(key_index),.midi_ready(midi_ready),
                		.wave_height(disp_wave),.wave_ready(wave_ready),.hcount(hcount),   
                		.vcount(vcount),.vsync(vsync),.hsync(hsync),.blank(blank),
                		.p_offset(p_offset), .p_vpos(p_vpos), .char_frame(char_frame), 
                		 .p_index(p_index),.p_obj1(obj1),.p_obj2(obj2),
                		.p_obj3(obj3), .p_obj4(obj4),.p_obj5(obj5),.freq_id(freq_id),.new_freq(new_f));
    
    
    
    assign VGA_R = prev3_blank ? 0: p_rgb[11:8];
    assign VGA_G = prev3_blank ? 0: p_rgb[7:4];
    assign VGA_B = prev3_blank ? 0: p_rgb[3:0];
    assign VGA_HS = ~prev3_hsync;
    assign VGA_VS = ~prev3_vsync;
    
    //test outputs
    //assign data[11:0] = {1'b0, reset_count}; //last three digits disp_wave
    assign data[31:20] = {2'b0, p_vpos}; //first three digits wave_index
    assign data[3:0] = {1'b0,obj1[25:23]};
    assign LED[0] = 1;
    assign LED[1] = 1;//up;
    assign LED[2] = down;
    
endmodule

