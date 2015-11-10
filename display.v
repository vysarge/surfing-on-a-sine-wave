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
               input [1:0] char_frame, //frame of character; 0 = stationary, 1 = rising, 2 = falling
               input [9:0] wave_prof, //waveform profile
               input [25:0] p_obj1, //25:23 frame, 22:21 identity, 20:10 horizontal position, 9:0 vertical position
               input [25:0] p_obj2, //identity 0, collectable
               input [25:0] p_obj3, //if 26'b0, disregard and render nothing.
               input [25:0] p_obj4, //thus a maximum of 5 objects may be on screen at one time.
               input [25:0] p_obj5,
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
    reg [25:0] obj1;
    reg [25:0] obj2;
    reg [25:0] obj3;
    reg [25:0] obj4;
    reg [25:0] obj5;
    
    //sprite pixel outputs
    wire [11:0] character_rgb;
    wire [11:0] obj1_rgb;
    wire [11:0] obj2_rgb;
    wire [11:0] obj3_rgb;
    wire [11:0] obj4_rgb;
    wire [11:0] obj5_rgb;
    wire [11:0] l_bg_rgb;
    wire [11:0] u_bg_rgb;
    
    //sprite declarations
    //character
    sprite #(.WIDTH(20), .HEIGHT(20), .LOG_FRAMES(3)) character 
                       (.vclock(vclock), .hcount(hcount), .x(0), .vcount(vcount),
                       .y(vpos), .s_type(3'b100), .curr_frame(char_frame), .p_rgb(character_rgb)
                       );
    
    //collectables
    sprite #(.WIDTH(15), .HEIGHT(16), .LOG_FRAMES(3)) object1
                           (.vclock(vclock), .hcount(hcount), .x(obj1[20:10]), .vcount(vcount),
                           .y(obj1[9:0]), .s_type(obj1[22:21]), .curr_frame(obj1[25:23]), .p_rgb(obj1_rgb)
                           );
    
    
    
    //background declarations
    background #(.ABOVE(0)) lower_background
                (.vclock(vclock), .hcount(hcount), .vcount(vcount), .prof_hcount(wave_prof), .p_rgb(l_bg_rgb));
    
    background #(.ABOVE(1)) upper_background
                (.vclock(vclock), .hcount(hcount), .vcount(vcount), .prof_hcount(wave_prof), .p_rgb(u_bg_rgb));
    
    initial begin //initial values
        //char_x = 0;
        vpos = 384;
        //char_frame = 0;
    end
    
    //at each new frame
    reg [10:0] i;
    always @(negedge vsync) begin
        //update values
        offset <= p_offset;
        vpos <= p_vpos;
        obj1 <= p_obj1;
        obj2 <= p_obj2;
        obj3 <= p_obj3;
        obj4 <= p_obj4;
        obj5 <= p_obj5;
        
    end
    
    //at each pixel
    always @(posedge vclock) begin
        if (reset) begin //reset values
            //char_x <= 0;
            //char_frame <= 0;
            p_rgb <= 0; //temporarily display black
        end
        else begin
            //shift in waveform data
            //if (wave_we) begin
            //    next_wave[wave_index] <= wave_prof;
            //end
            
            
            //if character data exists for this pixel
            if(character_rgb) begin //use that
                p_rgb <= character_rgb;
            end
            else if(obj1 && obj1_rgb) begin //otherwise use collectable data
                p_rgb <= obj1_rgb;
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
module sprite #(parameter WIDTH=20,
                parameter HEIGHT=20,
                parameter LOG_FRAMES=3)
               (input vclock,
                input [10:0] hcount, x,
                input [9:0] vcount, y,
                input [2:0] s_type, //type of sprite: 0 is character sprite
                input [LOG_FRAMES-1:0] curr_frame,
                output reg [11:0] p_rgb
                );
    
    wire [10:0] p_x, p_y; //relative x or y within sprite bounds
    wire within_limits; //1 if hcount and vcount currently within the sprite bounds
    assign within_limits = (hcount < x + WIDTH) & (hcount >= x) & (vcount < y + HEIGHT) & (vcount >= y);
    assign p_x = hcount - x;
    assign p_y = vcount - y;
    wire [11:0] p_rom; //output pixel from rom
    
    sprite_rom #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.LOG_FRAMES(LOG_FRAMES)) rom (.x(p_x), .y(p_y), .s_type(s_type), .frame(curr_frame), .pixel(p_rom));
    //on the rising edge of vclock
    always @(posedge vclock) begin
        
        //assign new pixel value
        if (within_limits) begin //if within box
            p_rgb <= p_rom; //for now, within the square is green
        end
        else begin //otherwise
            p_rgb <= 12'h000; //elsewhere is empty.
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
