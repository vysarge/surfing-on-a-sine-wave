`timescale 1ns / 1ps

module display(input reset,
               input [10:0] p_offset, //horizontal offset
               input [9:0] p_vpos, //vertical position of character
               input [9:0] wave_prof, //waveform profile
               input wave_clk, //clocks in waveform data
               input vclock, //65 mhz
               input [10:0] hcount, //0 at left
               input [9:0] vcount, //0 at top
               input hsync,  //active low
               input vsync,  //active low
               input blank,
               output reg [11:0] p_rgb
               );
    
    //storing inputs from last clock cycle
    reg [10:0] offset;
    reg [9:0] vpos;
    reg [9:0] wave[1023:0];
    
    //sprite pixel outputs
    wire [11:0] character_rgb;
    
    //sprite declarations
    reg [10:0] char_x;
    reg [9:0] char_y;
    reg char_frame;
    sprite #(.WIDTH(20), .HEIGHT(10), .LOG_FRAMES(1)) character 
                       (.vclock(vclock), .hcount(hcount), .x(char_x), .vcount(vcount),
                       .y(char_y), .curr_frame(char_frame), .p_rgb(character_rgb)
                       );
    
    initial begin
        char_x = 0;
        char_y = 382;
        char_frame = 0;
    end
    
    always @(posedge vclock) begin
        offset <= p_offset;
        vpos <= p_vpos;
        
        if(character_rgb) begin
            p_rgb <= character_rgb;
        end
        else begin
            p_rgb <= 12'b111100000000; //default display all pixels red
        end
        
    end
    
    
    
endmodule

//////////////////////////////////////////////////////////
//    
//    Produces the pixel as affected by a certain sprite
//    
//////////////////////////////////////////////////////////
module sprite #(parameter WIDTH=10,
                parameter HEIGHT=10,
                parameter LOG_FRAMES=3)
               (input vclock,
                input [10:0] hcount, x,
                input [9:0] vcount, y,
                input [LOG_FRAMES-1:0] curr_frame,
                output reg [11:0] p_rgb
                );
    
    //on the rising edge of vclock
    always @(posedge vclock) begin
        
        //assign new pixel value
        if ((hcount < x + WIDTH) & (hcount > x) & (vcount < y + HEIGHT) & (vcount > y)) begin //if within box
            p_rgb <= 12'b111111111111; //for now, within the square is white
        end
        else begin //otherwise
            p_rgb <= 12'b0; //elsewhere is empty.
        end
    end
    
endmodule

//////////////////////////////////////////////////////////
//    
//    Produces the pixel as affected by a background portion
//    
//////////////////////////////////////////////////////////
module background #(parameter ABOVE=0, //1 if above dividing profile
                    parameter CENTER=382 //vertical value of center of screen
                    ) 
                   (input vclock,
                    input [10:0] hcount,
                    input [9:0] vcount,
                    input [9:0] prof_hcount,
                    output reg [11:0] p_rgb
                   );
                   
    //on the rising edge of vclock
    always @(posedge vclock) begin
        
        //assign new pixel value
        if (ABOVE ^ (vcount > prof_hcount)) begin //if in specified area
            p_rgb <= 12'b111111111111; //for now, within the square is white
        end
        else begin //otherwise
            p_rgb <= 12'b0; //elsewhere is empty.
        end
    end
endmodule
