`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////
//
//  Central game logic module
//  
//  
//
//
////////////////////////////////////////////////////////////////////////////

module game_logic 
                #(parameter START=0, PLAY=1,
                SCREEN_WIDTH=1024)
                ( input clock,
                input [6:0] midi_index,
                input midi_ready,
                input [9:0] wave_height,
                input wave_ready,
                input [10:0] hcount,    // pixel number on current line
                input [9:0] vcount,	 // line number
                input vsync,hsync,blank,
                output reg [10:0] p_offset=0, //horizontal offset
                output reg [9:0] p_vpos=384, //vertical position of character
                output reg [1:0] char_frame=0, //frame of character; 0 = stationary, 1 = rising, 2 = falling
                //output reg [9:0] wave_prof=0, //waveform profile
                output reg [25:0] p_obj1=26'b000_00_00100000000_0100000000, //25:23 frame, 22:21 identity, 20:10 horizontal position, 9:0 vertical position
                output reg [25:0] p_obj2=0, //identity 0, collectable
                output reg [25:0] p_obj3=0, //if 26'b0, disregard and render nothing.
                output reg [25:0] p_obj4=0, //thus a maximum of 5 objects may be on screen at one time.
                output reg [25:0] p_obj5=0,
                output [4:0] freq_id,
                output new_freq,
                output [10:0] p_index);
    
    wire vsync_pulse;
    reg [1:0] state = START;
    reg [3:0] speed = 1;
    reg [2:0] obj_frame_counter = 0;
    
    assign freq_id = midi_index - 7'd48;
    assign new_freq = midi_ready;
    
    assign p_index = hcount + p_offset;
    
    pulse vsync_p (.clock(clock),.signal(vsync),.out(vsync_pulse));
    
    always @ (posedge clock) begin
        
        //update player position
        
        case (state)
            START: begin
                if (midi_ready) begin
                    state<=PLAY;
                end
            end
            PLAY: begin
                if (hcount == 0) begin
                    p_vpos <= wave_height - 10; 
                end
                if(vsync_pulse) begin
                    //for testing purposes, constantly step p_offset by one
                    // TODO: CHANGE SCREEN_WIDTH TO PERIOD FROM WAVE_LOGIC
                    if (p_offset < SCREEN_WIDTH) begin
                        p_offset <= p_offset + speed;
                    end
                    else begin
                        p_offset <= 0;
                    end
                    if (p_obj1[20:10] > 0) begin
                        p_obj1[20:10] <= p_obj1[20:10] - speed;
                    end
                    else begin
                        p_obj1[20:10] <= SCREEN_WIDTH;
                    end
                    //increment frame counter so that obj appears to rotate roughly once a second
                    obj_frame_counter <= obj_frame_counter + 1; //3 bits; changes frame once every 8 vga frames
                    if (obj_frame_counter == 0) begin
                        p_obj1[25:23] <= p_obj1[25:23] + 1;
                    end
                end
            end

        endcase

    end
endmodule

module pulse (input clock, signal,
              output reg out);
    reg state = 0;
    
    always @ (posedge clock) begin
        state<=signal;
        if(out) out <= 0;
        else out <= signal & ~state;
    end
endmodule
