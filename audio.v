`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module audio #(parameter BITS = 6 //bit resolution of audio output
               )
            (input reset,
             input clock,
             input [4:0] freq_id1,
             input [4:0] freq_id2,
             input new_f,
             output reg pwm
    );
    
    reg [BITS-1:0] curr_level; //net current wave level
    reg [BITS-1:0] count; //current count; resets when it's time for a new pwm period
    
    wire [BITS-1:0] level[5:0];
    
    audio_wave #(.BITS(6)) audio_wave0 (.reset(reset), .clock(clock), .freq_id(freq_id1), .new_f(new_f), .level(level[0]));
    //audio_wave #(.BITS(6)) audio_wave1 (.reset(reset), .clock(clock), .freq_id(freq_id1+2), .new_f(new_f), .level(level[1]));
    //audio_wave #(.BITS(6)) audio_wave1 (.reset(reset), .clock(clock), .freq_id(freq_id1+4), .new_f(new_f), .level(level[2]));
    
    audio_wave #(.BITS(6)) audio_wave1 (.reset(reset), .clock(clock), .freq_id(freq_id2), .new_f(new_f), .level(level[1]));
    //audio_wave #(.BITS(6)) audio_wave1 (.reset(reset), .clock(clock), .freq_id(freq_id2+2), .new_f(new_f), .level(level[4]));
    //audio_wave #(.BITS(6)) audio_wave1 (.reset(reset), .clock(clock), .freq_id(freq_id2+4), .new_f(new_f), .level(level[5]));
    
    always @(posedge clock) begin //65mhz
         
         curr_level <= ({1'b0,level[0]}+level[1])>>1;
         
         //increment count
         count <= count + 1;
         
         //curr_level / count is the volume level after the low pass.
         if (count == curr_level) begin
             pwm <= 0;
         end
         else if (count == 0) begin
             pwm <= 1;
         end
    end
    
    
endmodule
