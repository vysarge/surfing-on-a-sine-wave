`timescale 1ns / 1ps

//top level test module
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

    //assign LED = SW;
    assign JA[7:0] = 8'b0;
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
    
    pipeliner #(.CYCLES(6), .LOG(3), .WIDTH(1)) p3_hsync (.reset(reset), .clock(clock_65mhz), .in(hsync), .out(prev3_hsync));
    pipeliner #(.CYCLES(6), .LOG(3), .WIDTH(1)) p3_vsync (.reset(reset), .clock(clock_65mhz), .in(vsync), .out(prev3_vsync));
    pipeliner #(.CYCLES(6), .LOG(3), .WIDTH(1)) p3_blank (.reset(reset), .clock(clock_65mhz), .in(blank), .out(prev3_blank));
    
    wire [11:0] p_rgb; //current output pixel
    reg [9:0] p_vpos; //current player vertical position
    
    //object data registers; see display module for details
    reg [25:0] obj1, obj2, obj3, obj4, obj5;
    reg [2:0] obj_frame_counter;
    reg new_f;
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
    
    initial begin
        p_vpos = 384;
        wave_index = 0;
        
        obj1 = 25'b000_00_00100000000_0100000000;
        obj2 = 0;
        obj3 = 0;
        obj4 = 0;
        obj5 = 0;
        obj_frame_counter = 0;
    end
    
    
    //each frame
    always @(negedge vsync) begin
        
        
        //increment frame counter so that obj appears to rotate roughly once a second
        obj_frame_counter <= obj_frame_counter + 1; //3 bits; changes display frame once every 8 vga frames
        if (obj_frame_counter == 0) begin
            obj1[25:23] <= obj1[25:23] + 1;
        end
    end
    
    
    
    
    always @(posedge clock_65mhz) begin
        
        
        //updating previous variables
        prev_disp_sel <= disp_sel;
        prev_up <= up;
        prev_down <= down;
        prev_left <= left;
        prev_right <= right;
        
        
        //flash new_f when SW0 goes high
        if (disp_sel & (prev_disp_sel == 0)) begin
            new_f <= 1;
        end
        else begin
            new_f <= 0;
        end
        
        
        
        //update player position
        if (prev3_hcount == 0) begin
            p_vpos <= p_height; 
        end
        
        /*if (up && !prev_up) begin
            state <= state + 1;
        end
        else if (down && !prev_down) begin
            state <= state - 1;
        end*/
        
    end
    
    wire sw1, sw2, sw3, sw4, sw5;
    debounce s1(.reset(reset),.clock(clock_65mhz),.noisy(SW[1]),.clean(sw1));
    debounce s2(.reset(reset),.clock(clock_65mhz),.noisy(SW[2]),.clean(sw2));
    debounce s3(.reset(reset),.clock(clock_65mhz),.noisy(SW[3]),.clean(sw3));
    debounce s4(.reset(reset),.clock(clock_65mhz),.noisy(SW[4]),.clean(sw4));
    debounce s5(.reset(reset),.clock(clock_65mhz),.noisy(SW[5]),.clean(sw5));
    
    
    xvga vga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.blank(blank));
    
    
    
    wire [9:0] disp_wave;
    wire [4:0] freq_id1, freq_id2;
    assign freq_id1 = SW[15:11];
    assign freq_id2 = SW[10:6];
    wire [9:0] p_height;
    wire [20:0] period;
    
    wire [10:0] period0;
    wire curr_w0;
    wire [3:0] wave_ready;
    wire [10:0] d_offset;
    assign d_offset = 1'b1;
    
    
    wire [12:0] offset_p0, offset_p2;
    
    physics physics(.reset(reset), .clock(clock_65mhz), .vsync(vsync), .d_offset(d_offset), .r_offset(reset), .hcount(hcount),
                    .freq_id1(freq_id1), .freq_id2(freq_id2), .new_f_in(new_f),
                    .player_profile(p_height), .wave_profile(disp_wave)
                    );
    
    
    
    
    
    display display(.reset(reset), .p_vpos(p_vpos), .char_frame(0), .wave_prof(disp_wave), 
                    .vclock(clock_65mhz), .hcount(prev_hcount), .vcount(prev_vcount),
                    .p_obj1(obj1), .p_obj2(obj2), .p_obj3(obj3), .p_obj4(obj4), .p_obj5(obj5),
                    .hsync(prev_hsync), .vsync(prev_vsync), .blank(prev_blank), .p_rgb(p_rgb));
    
    
    assign AUD_SD = 1;
    wire [1:0] form;
    //assign form = SW[2:1];
    wire music;
    assign music = sw3;
    assign form = {~sw3,sw2};
    wire new_f_notes;
    assign LED[2] = new_f_notes;
    wire sil;
    wire note;
    assign LED[3] = sil;
    assign LED[4] = note;
    wire [19:0] note_counter;
    wire [5:0] audio_counter;
    
    wire [4:0]freq0;
    wire [5:0] state;
    wire [5:0] state_out;
    
    audio audio(.reset(reset), .clock(clock_65mhz), .freq_id1(freq_id1), .freq_id2(freq_id2), .new_f(new_f), .state(state), .prev_state(state_out),
                .form(form), .music(music), .pwm(AUD_PWM), .new_f_notes(new_f_notes), .sil(sil), .note(note), .note_counter(note_counter), .count(audio_counter), .freq0(freq0));
    
    
    assign VGA_R = prev3_blank ? 0: p_rgb[11:8];
    assign VGA_G = prev3_blank ? 0: p_rgb[7:4];
    assign VGA_B = prev3_blank ? 0: p_rgb[3:0];
    assign VGA_HS = ~prev3_hsync;
    assign VGA_VS = ~prev3_vsync;
    
    //test outputs
    //assign data[11:0] = {1'b0, reset_count}; //last three digits disp_wave
    assign data[20:16] = {freq0}; //first three digits wave_index
    assign data[5:0] = {state_out};
    assign LED[0] = SW[2];
    assign LED[1] = curr_w0;//up;
    //assign LED[6:3] = wave_ready;
    //assign LED[2] = down;
    
endmodule

