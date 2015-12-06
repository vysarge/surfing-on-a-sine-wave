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
                OBJ_HEIGHT=20,
                NUM_LIVES=3)
                ( input [3:0] speed_j,
                input clock,
                input [31:0] seed,
                input [6:0] key1_index,
                input [6:0] key2_index,
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
                output reg [25:0] p_obj1=0, //25:23 frame, 22:21 identity, 20:10 horizontal position, 9:0 vertical position
                output reg [25:0] p_obj2=0, //identity 0, collectable
                output reg [25:0] p_obj3=0, //if 26'b0, disregard and render nothing.
                output reg [25:0] p_obj4=0, //thus a maximum of 5 objects may be on screen at one time.
                output reg [25:0] p_obj5=0,
                output reg [7:0] score = 0,
                output reg [2:0] health = NUM_LIVES,
                output [4:0] freq_id1,
                output [4:0] freq_id2,
                output new_freq);
    
    wire vsync_pulse;
    reg [1:0] state = START;
    reg [2:0] obj_frame_counter = 0;
    wire [31:0] random;
    
    
    wire obj1_on, obj2_on, obj3_on, obj4_on, obj5_on;
    assign obj1_on = |p_obj1;
    assign obj2_on = |p_obj2;
    assign obj3_on = |p_obj3;
    assign obj4_on = |p_obj4;
    assign obj5_on = |p_obj5;
    
    assign freq_id1 = |key1_index ? (key1_index - 7'd48) : 5'b11111;
    assign freq_id2 = |key2_index ? (key2_index - 7'd48) : 5'b11111;
    assign new_freq = midi_ready;
    
    pulse vsync_p (.clock(clock),.signal(vsync),.out(vsync_pulse));
    
    rng rando (.clk(clock),.new_number(vsync_pulse),.seed(seed),
                    .random(random));
    
    always @ (posedge clock) begin
        
        //update player position
        speed <= speed_j;
        case (state)
            START: begin
                health<=NUM_LIVES;
                score<=0;
                p_obj1<=0;
                p_obj2<=0;
                p_obj3<=0;
                p_obj4<=0;
                p_obj5<=0;
                //speed<=0;
                if (midi_ready) begin
                    state<=PLAY;
                    speed<=1;
                end
            end
            PLAY: begin
                if(health == 0) begin
                    state<= START;
                end
                if(vsync_pulse) begin
                    obj_frame_counter <= obj_frame_counter + 1;
                    
                    if(obj1_on) begin
                        if (p_obj1[20:10] > speed) begin
                            p_obj1[20:10] <= p_obj1[20:10] - speed;
                        end
                        else begin
                            p_obj1<=0;
                        end
                        //increment frame counter so that obj appears to rotate roughly once a second
                         //3 bits; changes frame once every 8 vga frames
                        if (obj_frame_counter == 0) begin
                            p_obj1[25:23] <= p_obj1[25:23] + 1;
                        end
                        
                        if ((p_obj1[20:10] < CHAR_WIDTH) && (p_obj1[9:0] < p_vpos + CHAR_HEIGHT) && (p_obj1[9:0] > p_vpos - OBJ_HEIGHT)) begin
                            case(p_obj2[22:21])
                                0: begin
                                    score<=score+1;
                                end
                                1: begin
                                    health<=health-1;
                                end
                            endcase
                        end
                    end else if ( obj_frame_counter == 1 && random[31:25] == 0 ) begin
                        p_obj1[21]=random[3];
                        p_obj1[20:10] <= SCREEN_WIDTH;
                        p_obj1[9:0] <= 10'd220+random[7:0];
                    end
                    
                    if(obj2_on) begin
                        if (p_obj2[20:10] > 0) begin
                            p_obj2[20:10] <= p_obj2[20:10] - speed;
                        end
                        else begin
                            p_obj2<=0;
                        end
                        //increment frame counter so that obj appears to rotate roughly once a second
                         //3 bits; changes frame once every 8 vga frames
                        if (obj_frame_counter == 0) begin
                            p_obj2[25:23] <= p_obj2[25:23] + 1;
                        end
                        
                        if ((p_obj2[20:10] < CHAR_WIDTH) && (p_obj2[9:0] < p_vpos + CHAR_HEIGHT) && (p_obj2[9:0] > p_vpos - OBJ_HEIGHT)) begin
                            case(p_obj2[22:21])
                                0: begin
                                    score<=score+1;
                                end
                                1: begin
                                    health<=health-1;
                                end
                            endcase
                        end
                    end else if ( obj_frame_counter == 2 && random[31:25] == 0 ) begin
                        p_obj2[21]=random[1];
                        p_obj2[20:10] <= SCREEN_WIDTH;
                        p_obj2[9:0] <= 10'd220+random[8:1];
                    end
                                        
                    if(obj3_on) begin
                        if (p_obj3[20:10] > 0) begin
                            p_obj3[20:10] <= p_obj3[20:10] - speed;
                        end
                        else
                            p_obj3<=0;

                        //increment frame counter so that obj appears to rotate roughly once a second
                         //3 bits; changes frame once every 8 vga frames
                        if (obj_frame_counter == 0) begin
                            p_obj3[25:23] <= p_obj3[25:23] + 1;
                        end
                        
                        if ((p_obj3[20:10] < CHAR_WIDTH) && (p_obj3[9:0] < p_vpos + CHAR_HEIGHT) && (p_obj3[9:0] > p_vpos - OBJ_HEIGHT)) begin
                            case(p_obj3[22:21])
                                0: begin
                                    score<=score+1;
                                end
                                1: begin
                                    health<=health-1;
                                end
                            endcase
                            p_obj3<=0;
                        end
                    end else if (obj_frame_counter == 3 && random[31:25] == 0 ) begin
                        p_obj3[21]=random[0];
                        p_obj3[20:10] <= SCREEN_WIDTH;
                        p_obj3[9:0] <= 10'd220+random[9:2];
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

module pulse2 (input clock, signal,
              output reg out);
    reg state = 0;
    reg count = 0;
    
    always @ (posedge clock) begin
        state<=signal;
        if(out) begin
            if (count == 0) begin
                count<= count +1;
            end else begin
                out <= 0;
                count<=0;
            end
        end else out <= signal & ~state;
    end
endmodule