`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////
// 
// Display module; takes in data on player offset, player position,
// and waveform, as well as xvga signals.
// 
// wave_we is active high and enables wave_prof data to be written
// at wave_index; this is clocked by posedge vclock
// 
/////////////////////////////////////////////////////////////////
module display(input reset,
               input [10:0] p_offset, //horizontal offset
               input [9:0] p_vpos, //vertical position of character
               input [9:0] wave_prof, //waveform profile
               input [10:0] wave_index,
               input wave_we, //write enable; wave data clocked by vclock
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
    reg [9:0] next_wave[1023:0];
    reg [10:0] char_x;
    reg char_frame;
    
    //sprite pixel outputs
    wire [11:0] character_rgb;
    wire [11:0] l_bg_rgb;
    wire [11:0] u_bg_rgb;
    
    //sprite declarations
    sprite #(.WIDTH(20), .HEIGHT(10), .LOG_FRAMES(1)) character 
                       (.vclock(vclock), .hcount(hcount), .x(char_x), .vcount(vcount),
                       .y(vpos), .curr_frame(char_frame), .p_rgb(character_rgb)
                       );
    
    //background declarations
    background #(.ABOVE(0)) lower_background
                (.vclock(vclock), .hcount(hcount), .vcount(vcount), .prof_hcount(wave[hcount[9:0]]), .p_rgb(l_bg_rgb));
    
    background #(.ABOVE(1)) upper_background
                (.vclock(vclock), .hcount(hcount), .vcount(vcount), .prof_hcount(wave[hcount[9:0]]), .p_rgb(u_bg_rgb));
    
    initial begin //initial values
        char_x = 0;
        vpos = 384;
        char_frame = 0;
    end
    
    //at each new frame
    reg [10:0] i;
    always @(negedge vsync) begin
        //update values
        for (i = 0; i < 1024; i = i+1) begin
            wave[i] <= next_wave[i];
        end
        offset <= p_offset;
        vpos <= p_vpos;
        
    end
    
    //at each pixel
    always @(posedge vclock) begin
        if (reset) begin //reset values
            char_x <= 0;
            char_frame <= 0;
            p_rgb <= 0; //temporarily display black
        end
        else begin
            //shift in waveform data
            if (wave_we) begin
                next_wave[wave_index] <= wave_prof;
            end
            
            
            //if character data exists for this pixel
            if(character_rgb) begin //use that
                p_rgb <= character_rgb;
            end
            else if (l_bg_rgb) begin //otherwise use lower background data
                p_rgb <= l_bg_rgb;
            end
            else if (u_bg_rgb) begin
                p_rgb <= u_bg_rgb; //otherwise use upper background data
            end
            else begin //if no data exists for this pixel
                p_rgb <= 12'hF00; //default display red
            end
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
            p_rgb <= 12'h0F0; //for now, within the square is green
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
            if (ABOVE) begin
                p_rgb <= 12'hFFF; //for now, upper background is white
            end
            else begin
                p_rgb <= 12'h00F; //for now, lower background is blue
            end
        end
        else begin //otherwise
            p_rgb <= 12'b0; //elsewhere is empty.
        end
    end
endmodule
