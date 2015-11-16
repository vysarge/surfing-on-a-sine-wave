`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// 
// This module implements the physics of transitioning from one waveform to another
// and provides a wrapper for the wave_logic module.
// It provides constant output, switching over frequencies smoothly when wave_logic is done calculating.
// 
//////////////////////////////////////////////////////////////////////////////////


module physics(input reset,
               input clock,
               input vsync,
               input [10:0] offset, //current offset of player relative to start of wave.
               input [10:0] hcount, //current hcount of requested pixel
               input [4:0] freq_id, //frequency id from keyboard; 0 is lowest, 24 highest.
               input new_f, //asserted when a new frequency is available from the keyboard
               output reg [9:0] player_profile, //where the player will be vertically.  Affected by prior frequency
               output reg [9:0] wave_profile //waveform to be displayed.  Affected only by current frequency
               );
    
    //calculation variables
    reg [9:0] coeff; //blending coefficient; 0 means entirely most recent frequency.
    reg curr_wl; //0 if wl1 is the most recently update, 1 if wl2
    
    //embedded wave_logic modules
    reg [4:0] freq_id1, freq_id2;
    reg new_f1, new_f2;
    reg [10:0] index;
    wire [9:0] height1, height2;
    wire [9:0] period1, period2;
    wire ready1, ready2;
    wave_logic wl1 (.reset(reset), .clock(clock), .freq_id(freq_id1), .new_f(new_f1), 
                    .index(index), .wave_height(height1), .period(period1), .wave_ready(ready1));
    wave_logic wl2 (.reset(reset), .clock(clock), .freq_id(freq_id2), .new_f(new_f2), 
                    .index(index), .wave_height(height2), .period(period2), .wave_ready(ready2));
    
    //at each new frame
    always @(posedge vsync) begin
        if (reset) begin //reset
            coeff <= 0;
        end
        
        //each frame, halve coeff
        coeff <= coeff >> 1;
    end
    
    //at each clock cycle
    always @(posedge clock) begin
        if (curr_wl) begin //if wl1 is most recently updated
            
            if (new_f) begin //if a new frequency has been input
                
            end
            
            
        end
        else begin
            
        end
    end
    
endmodule
