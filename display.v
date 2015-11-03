`timescale 1ns / 1ps

module display(input [10:0] p_offset, //horizontal offset
               input [9:0] p_vpos, //vertical position of character
               input [9:0] wave[1023:0], //waveform profile
               input vclock, //65 mhz
               input [10:0] hcount, //0 at left
               input [9:0] vcount, //0 at top
               input hsync,  //active low
               input vsync,  //active low
               input blank,
               output reg [3:0] p_red,
               output reg [3:0] p_green,
               output reg [3:0] p_blue
               );
    
    
    
endmodule

//////////////////////////////////////////////////////////
//    
//    Produces the pixel as affected by a certain sprite
//    
//////////////////////////////////////////////////////////
module sprite #(parameter WIDTH,
                parameter HEIGHT,
                parameter LOG_FRAMES)
               (input [10:0] hcount, x,
                input [9:0] vcount, y,
                input [LOG_FRAMES-1:0] curr_frame,
                output reg [3:0] p_red,
                output reg [3:0] p_green,
                output reg [3:0] p_blue
                );
    
    
    
endmodule

//////////////////////////////////////////////////////////
//    
//    Produces the pixel as affected by a background portion
//    
//////////////////////////////////////////////////////////
module background #(parameter ABOVE) //1 if above dividing profile
                   (input 
                   );
    
endmodule
