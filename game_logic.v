`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////
//
//  Central game logic module
//  
//  
//
//
////////////////////////////////////////////////////////////////////////////

module game_logic ( input clock,
                input [6:0] midi_index,
                input midi_ready,
                output reg [10:0] p_offset, //horizontal offset
                output reg [9:0] p_vpos, //vertical position of character
                output reg [1:0] char_frame, //frame of character; 0 = stationary, 1 = rising, 2 = falling
                output reg [9:0] wave_prof, //waveform profile
                output reg [25:0] p_obj1, //25:23 frame, 22:21 identity, 20:10 horizontal position, 9:0 vertical position
                output reg [25:0] p_obj2, //identity 0, collectable
                output reg [25:0] p_obj3, //if 26'b0, disregard and render nothing.
                output reg [25:0] p_obj4, //thus a maximum of 5 objects may be on screen at one time.
                output reg [25:0] p_obj5,
                output reg vclock, //65 mhz
                output reg [10:0] hcount, //0 at left
                output reg [9:0] vcount, //0 at top
                output reg hsync,  //active low
                output reg vsync,  //active low
                output reg blank,
                output [4:0] freq_id,
                output new_freq);

    
    reg [1:0] state = START;
    always @ (posedge clock) begin
        case (state)
            START: begin
                if (midi_ready) begin
                    state<=PLAY;
                end
            end
            PLAY: begin
                
            end

        endcase

    end
endmodule