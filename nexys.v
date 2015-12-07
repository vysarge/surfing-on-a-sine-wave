`timescale 1ns / 1ps

//top level test module
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
   output[7:0] AN,    // Display 0-7
   output AUD_PWM,
   output AUD_SD
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
    SRL16 reset_sr (.D(1'b0), .CLK(clock_65mhz), .Q(power_on_reset),
               .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
    defparam reset_sr.INIT = 16'hFFFF;
    
    //user reset
    debounce center(.reset(power_on_reset),.clock(clock_65mhz),.noisy(BTNC),.clean(user_reset));
    assign reset = user_reset | power_on_reset;
    
    
    
    
    
// create 25mhz system clock
    
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
    wire [10:0] prev_hcount;
    wire [9:0] prev_vcount;
    wire hsync, vsync, blank; //vga
    wire prev_hsync, prev_vsync, prev_blank; //previous values
    wire [10:0] prev3_hcount;
    wire [9:0] prev3_vcount;
    wire prev3_hsync, prev3_vsync, prev3_blank; //etc
    
    pipeliner #(.CYCLES(1), .LOG(1), .WIDTH(11)) p_hcount (.reset(reset), .clock(clock_65mhz), .in(hcount), .out(prev_hcount));
    pipeliner #(.CYCLES(1), .LOG(1), .WIDTH(10)) p_vcount (.reset(reset), .clock(clock_65mhz), .in(vcount), .out(prev_vcount));
    pipeliner #(.CYCLES(6), .LOG(3), .WIDTH(11)) p3_hcount (.reset(reset), .clock(clock_65mhz), .in(hcount), .out(prev3_hcount));
    pipeliner #(.CYCLES(6), .LOG(3), .WIDTH(10)) p3_vcount (.reset(reset), .clock(clock_65mhz), .in(vcount), .out(prev3_vcount));
    
    pipeliner #(.CYCLES(1), .LOG(1), .WIDTH(1)) p_hsync (.reset(reset), .clock(clock_65mhz), .in(hsync), .out(prev_hsync));
    pipeliner #(.CYCLES(1), .LOG(1), .WIDTH(1)) p_vsync (.reset(reset), .clock(clock_65mhz), .in(vsync), .out(prev_vsync));
    pipeliner #(.CYCLES(1), .LOG(1), .WIDTH(1)) p_blank (.reset(reset), .clock(clock_65mhz), .in(blank), .out(prev_blank));
    

    wire [10:0] p_offset; //current player horizontal position (positive as wave moves left)
    reg [9:0] wave_prof[1023:0]; //current waveform profile
    reg [9:0] prev_wave_prof[1023:0];

    pipeliner #(.CYCLES(6), .LOG(3), .WIDTH(1)) p3_hsync (.reset(reset), .clock(clock_65mhz), .in(hsync), .out(prev3_hsync));
    pipeliner #(.CYCLES(6), .LOG(3), .WIDTH(1)) p3_vsync (.reset(reset), .clock(clock_65mhz), .in(vsync), .out(prev3_vsync));
    pipeliner #(.CYCLES(6), .LOG(3), .WIDTH(1)) p3_blank (.reset(reset), .clock(clock_65mhz), .in(blank), .out(prev3_blank));
    
    wire [11:0] p_rgb; //current output pixel
    reg [9:0] p_vpos; //current player vertical position

    
    //object data registers; see display module for details
    wire [25:0] obj1, obj2, obj3, obj4, obj5;
    reg [2:0] obj_frame_counter;

    
    wire [4:0] freq_id;
    //assign freq_id = SW[15:11];
    wire new_f;
    

    wire wave_ready;
    
    
    
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
    
    
    assign LED16_R = left;                  // left button -> red led
    assign LED16_G = BTNC;                  // center button -> green led
    assign LED16_B = right;                  // right button -> blue led
    
    
    
    
    always @(posedge clock_65mhz) begin
        
        
        //updating previous variables
        prev_disp_sel <= disp_sel;
        prev_up <= up;
        prev_down <= down;
        prev_left <= left;
        prev_right <= right;

        if(prev3_hcount==0) begin 
            p_vpos<= p_height;              //sample player height to prevent glitching
        end 
    end
    
    wire sw1, sw2, sw3, sw4, sw5;
    debounce s1(.reset(reset),.clock(clock_65mhz),.noisy(SW[1]),.clean(sw1));
    debounce s2(.reset(reset),.clock(clock_65mhz),.noisy(SW[2]),.clean(sw2));
    debounce s3(.reset(reset),.clock(clock_65mhz),.noisy(SW[3]),.clean(sw3));
    debounce s4(.reset(reset),.clock(clock_65mhz),.noisy(SW[4]),.clean(sw4));
    debounce s5(.reset(reset),.clock(clock_65mhz),.noisy(SW[5]),.clean(sw5));
    
    
    xvga vga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.blank(blank));
    
    wire midi_ready;
    wire [6:0] key1_index;
    wire [6:0] key2_index;
    midi kb(.clk(clock_65mhz),.serial(JA[0]),.ready(midi_ready),
        .key1_index(key1_index),.key2_index(key2_index));
    //assign freq_id = key_index - 7'd48;

    
    wire [9:0] disp_wave;
    wire [4:0] freq_id1, freq_id2;
    //assign freq_id1 = SW[15:11];
    //assign freq_id2 = SW[10:6];
    wire [9:0] p_height;
    wire [20:0] period;
    
    wire [10:0] period0;
    wire [3:0] wave_ready;
    wire [10:0] d_offset;
    wire [9:0] score;
    wire [1:0] health;
    
    wire [10:0] paroffset;
    physics physics(.reset(reset), .clock(clock_65mhz), .vsync(vsync), .d_offset(d_offset), .r_offset(up), .hcount(hcount),
                    .freq_id1(freq_id1), .freq_id2(freq_id2), .new_f_in(new_f),
                    .player_profile(p_height), .wave_profile(disp_wave));
    
    
    display display(.reset(reset), .p_vpos(p_vpos), .char_frame(0), .wave_prof(disp_wave), 
                    .vclock(clock_65mhz), .hcount(prev_hcount), .vcount(prev_vcount),
                    .score(score),.health(health),.d100(d100),.d10(d10),.d1(d1),
                    .p_obj1(obj1), .p_obj2(obj2), .p_obj3(obj3), .p_obj4(obj4), .p_obj5(obj5),
                    .hsync(prev_hsync), .vsync(prev_vsync), .blank(prev_blank), .p_rgb(p_rgb));
                    
                    
    
    wire indic;
    assign LED[3] = indic;
    
    game_logic gfsm (.clock(clock_65mhz),.speed_j(SW[15:12]),.key1_index(key1_index),.key2_index(key2_index),.midi_ready(midi_ready),.p_vpos(p_height),
                		.wave_height(disp_wave),.wave_ready(wave_ready),.hcount(hcount),.health(health),
                		.vcount(vcount),.vsync(vsync),.hsync(hsync),.blank(blank), .score(score),
                		.speed(d_offset), .char_frame(char_frame), .p_obj1(obj1),.p_obj2(obj2),
                		.seed({2{SW[15:0]}}),.p_obj3(obj3), .p_obj4(obj4),.p_obj5(obj5),
                		.freq_id1(freq_id1),.freq_id2(freq_id2),.new_freq(new_f), .indic(indic));
    
    
    assign AUD_SD = 1; //audio output enable
    wire [1:0] form; //type of audio output; 10 is square wave, 00 is sine wave
    //assign form = SW[2:1];
    wire music;
    assign music = sw3;  //when high, music plays (when low, frequency tone plays)
    assign form = {1'b0,sw2};//sw2 turns music on and off (active low)
    
    //audio module.
    audio audio(.reset(reset), .clock(clock_65mhz), .freq_id1(freq_id1), .freq_id2(freq_id2), .new_f(new_f), 
                .form(form), .music(music), .pwm(AUD_PWM));
    
    //vga output.
    assign VGA_R = prev3_blank ? 0: p_rgb[11:8];
    assign VGA_G = prev3_blank ? 0: p_rgb[7:4];
    assign VGA_B = prev3_blank ? 0: p_rgb[3:0];
    assign VGA_HS = ~prev3_hsync;
    assign VGA_VS = ~prev3_vsync;
    
    //test outputs
    //assign data[11:0] = {1'b0, reset_count}; //last three digits disp_wave
    //assign data[31:20] = {period0}; //first three digits wave_index
    wire [3:0] d100,d10,d1;
    assign data[31:0]={4'b0,d100,d10,d1,2'b0,health,2'b0,score};
    wire [7:0] bcd1;
    wire [11:0] bcd2;
    
    binary_to_bcd #(.LOG(2),.WIDTH(8)) b1
            (.bin(8'd95),.clock(clock_65mhz),
             .out(bcd1));
    binary_to_bcd #(.LOG(3),.WIDTH(10)) b2
             (.bin(10'd229),.clock(clock_65mhz),
              .out(bcd2));
    
    wire [31:0] random;
    wire new_pulse;
    wire [1:0] rng_state;
    wire [9:0] i_rng;
    /*
    pulse2 p (.clock(clock_65mhz),.signal(down),.out(new_pulse));
    rng rando (.clk(clock_65mhz),.new_number(new_pulse),.seed({2{SW[15:0]}}),
                .random(random));
    */
endmodule

