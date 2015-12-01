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
                SCREEN_WIDTH=1024,
                CHAR_WIDTH=20,
                CHAR_HEIGHT=20,
                OBJ_HEIGHT=20)
                ( input clock,
                input [6:0] midi_index,
                input midi_ready,
                input [9:0] wave_height,
                input wave_ready,
                input [9:0] p_vpos,
                input [10:0] hcount,    // pixel number on current line
                input [9:0] vcount,	 // line number
                input vsync,hsync,blank,
                output reg [3:0] speed=0, //horizontal speed
                output reg [1:0] char_frame=0, //frame of character; 0 = stationary, 1 = rising, 2 = falling
                //output reg [9:0] wave_prof=0, //waveform profile
                output reg [25:0] p_obj1=26'b000_00_00100000000_0110000000, //25:23 frame, 22:21 identity, 20:10 horizontal position, 9:0 vertical position
                output reg [25:0] p_obj2=26'b100_00_00010000000_0000001111, //identity 0, collectable
                output reg [25:0] p_obj3=26'b010_00_00101000000_0000100000, //if 26'b0, disregard and render nothing.
                output reg [25:0] p_obj4=0, //thus a maximum of 5 objects may be on screen at one time.
                output reg [25:0] p_obj5=0,
                output reg [7:0] score = 0,
                output [4:0] freq_id,
                output new_freq);
    
    wire vsync_pulse;
    reg [1:0] state = START;
    reg [2:0] obj_frame_counter = 0;
    
    wire obj1_on, obj2_on, obj3_on, obj4_on, obj5_on;
    assign obj1_on = |p_obj1;
    assign obj2_on = |p_obj2;
    assign obj3_on = |p_obj3;
    assign obj4_on = |p_obj4;
    assign obj5_on = |p_obj5;
    
    assign freq_id = midi_index - 7'd48;
    assign new_freq = midi_ready;
    
    pulse vsync_p (.clock(clock),.signal(vsync),.out(vsync_pulse));
    
    always @ (posedge clock) begin
        
        //update player position
        
        case (state)
            START: begin
                if (midi_ready) begin
                    state<=PLAY;
                    speed<=1;
                end
            end
            PLAY: begin
                
                if(vsync_pulse) begin
                    obj_frame_counter <= obj_frame_counter + 1;
                    
                    if(obj1_on) begin
                        if (p_obj1[20:10] > 0) begin
                            p_obj1[20:10] <= p_obj1[20:10] - speed;
                        end
                        else begin
                            p_obj1[20:10] <= SCREEN_WIDTH;
                        end
                        //increment frame counter so that obj appears to rotate roughly once a second
                         //3 bits; changes frame once every 8 vga frames
                        if (obj_frame_counter == 0) begin
                            p_obj1[25:23] <= p_obj1[25:23] + 1;
                        end
                        
                        if ((p_obj1[20:10] < CHAR_WIDTH) && (p_obj1[9:0] < p_vpos + CHAR_HEIGHT) && (p_obj1[9:0] > p_vpos - OBJ_HEIGHT)) begin
                            score<=score+1;
                            p_obj1<=0;
                        end
                    end
                    
                    if(obj2_on) begin
                        if (p_obj2[20:10] > 0) begin
                            p_obj2[20:10] <= p_obj2[20:10] - speed;
                        end
                        else begin
                            p_obj2[20:10] <= SCREEN_WIDTH;
                        end
                        //increment frame counter so that obj appears to rotate roughly once a second
                         //3 bits; changes frame once every 8 vga frames
                        if (obj_frame_counter == 0) begin
                            p_obj2[25:23] <= p_obj2[25:23] + 1;
                        end
                        
                        if ((p_obj2[20:10] < CHAR_WIDTH) && (p_obj2[9:0] < p_vpos + CHAR_HEIGHT) && (p_obj2[9:0] > p_vpos - OBJ_HEIGHT)) begin
                            score<=score+1;
                            p_obj2<=0;
                        end
                    end
                                        
                    if(obj3_on) begin
                        if (p_obj3[20:10] > 0) begin
                            p_obj3[20:10] <= p_obj3[20:10] - speed;
                        end
                        else begin
                            p_obj3[20:10] <= SCREEN_WIDTH;
                        end
                        //increment frame counter so that obj appears to rotate roughly once a second
                         //3 bits; changes frame once every 8 vga frames
                        if (obj_frame_counter == 0) begin
                            p_obj3[25:23] <= p_obj3[25:23] + 1;
                        end
                        
                        if ((p_obj3[20:10] < CHAR_WIDTH) && (p_obj3[9:0] < p_vpos + CHAR_HEIGHT) && (p_obj3[9:0] > p_vpos - OBJ_HEIGHT)) begin
                            score<=score+1;
                            p_obj3<=0;
                        end
                    end 
                                       
                    if(obj4_on) begin
                        if (p_obj4[20:10] > 0) begin
                            p_obj4[20:10] <= p_obj4[20:10] - speed;
                        end
                        else begin
                            p_obj4<=0;
                        end
                        //increment frame counter so that obj appears to rotate roughly once a second
                         //3 bits; changes frame once every 8 vga frames
                        if (obj_frame_counter == 0) begin
                            p_obj4[25:23] <= p_obj4[25:23] + 1;
                        end
                        
                        if ((p_obj4[20:10] < CHAR_WIDTH) && (p_obj4[9:0] < p_vpos + CHAR_HEIGHT) && (p_obj4[9:0] > p_vpos - OBJ_HEIGHT)) begin
                            score<=score+1;
                            p_obj4<=0;
                        end
                    end
                    
                    if(obj5_on) begin
                        if (p_obj5[20:10] > 0) begin
                            p_obj5[20:10] <= p_obj5[20:10] - speed;
                        end
                        else begin
                            p_obj5<=0;
                        end
                        //increment frame counter so that obj appears to rotate roughly once a second
                         //3 bits; changes frame once every 8 vga frames
                        if (obj_frame_counter == 0) begin
                            p_obj5[25:23] <= p_obj5[25:23] + 1;
                        end
                        
                        if ((p_obj5[20:10] < CHAR_WIDTH) && (p_obj5[9:0] < p_vpos + CHAR_HEIGHT) && (p_obj5[9:0] > p_vpos - OBJ_HEIGHT)) begin
                            score<=score+1;
                            p_obj5<=0;
                        end
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
