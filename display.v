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
    //reg [9:0] wave[1023:0];
    //reg [9:0] next_wave[1023:0];
    //reg [10:0] char_x;
    
    
    //sprite pixel outputs
    wire [11:0] character_rgb;
    wire [11:0] l_bg_rgb;
    wire [11:0] u_bg_rgb;
    
    //sprite declarations
    sprite #(.WIDTH(20), .HEIGHT(20), .LOG_FRAMES(2)) character 
                       (.vclock(vclock), .hcount(hcount), .x(0), .vcount(vcount),
                       .y(vpos), .curr_frame(char_frame), .p_rgb(character_rgb)
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
    assign within_limits = (hcount < x + WIDTH) & (hcount > x) & (vcount < y + HEIGHT) & (vcount > y);
    assign p_x = hcount - x;
    assign p_y = vcount - y;
    wire [11:0] p_rom; //output pixel from rom
    
    sprite_rom #(.WIDTH(20),.HEIGHT(20),.LOG_FRAMES(2)) rom (.x(p_x), .y(p_y), .s_type(s_type), .frame(curr_frame), .pixel(p_rom));
    //on the rising edge of vclock
    always @(posedge vclock) begin
        
        //assign new pixel value
        if ((hcount < x + WIDTH) & (hcount > x) & (vcount < y + HEIGHT) & (vcount > y)) begin //if within box
            p_rgb <= p_rom; //for now, within the square is green
        end
        else begin //otherwise
            p_rgb <= 12'b0; //elsewhere is empty.
        end
    end
    
endmodule


module sprite_rom #(parameter WIDTH = 20,
                    parameter HEIGHT = 20,
                    parameter LOG_FRAMES = 3)
                   (input [4:0] x, //height and width are both 20
                   input [4:0] y,
                   input [2:0] s_type,
                   input [LOG_FRAMES-1:0] frame,
                   output reg [11:0]  pixel);
    
    reg[WIDTH*12-1:0] horiz; //a horizontal strip of pixels
    //selects the correct pixel from the horizontal strip
    always @(x, horiz) begin
        case (x) 
            5'b00000: pixel = horiz[239:228];
            5'b00001: pixel = horiz[227:216];
            5'b00010: pixel = horiz[215:204];
            5'b00011: pixel = horiz[203:192];
            5'b00100: pixel = horiz[191:180];
            5'b00101: pixel = horiz[179:168];
            5'b00110: pixel = horiz[167:156];
            5'b00111: pixel = horiz[155:144];
            5'b01000: pixel = horiz[143:132];
            5'b01001: pixel = horiz[131:120];
            5'b01010: pixel = horiz[119:108];
            5'b01011: pixel = horiz[107:96];
            5'b01100: pixel = horiz[95:84];
            5'b01101: pixel = horiz[83:72];
            5'b01110: pixel = horiz[71:60];
            5'b01111: pixel = horiz[59:48];
            5'b10000: pixel = horiz[47:36];
            5'b10001: pixel = horiz[35:24];
            5'b10010: pixel = horiz[23:12];
            5'b10011: pixel = horiz[11:0];
        endcase
    end
    
    //for current y and frame, return the corresponding pixel strip
    always @(y, frame) begin
        if (s_type == 0) begin
            case ({frame,y})
                8'b000_00000: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_00001: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_00010: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_00011: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_00100: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_00101: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_00110: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_00111: horiz = 240'h000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000;
                8'b000_01000: horiz = 240'h000_000_0F0_0F0_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000;
                8'b000_01001: horiz = 240'h000_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000;
                8'b000_01010: horiz = 240'h000_000_0F0_0F0_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000;
                8'b000_01011: horiz = 240'h000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000;
                8'b000_01100: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_01101: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_01110: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_01111: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_10000: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_10001: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_10010: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b000_10011: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                
                8'b001_00000: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b001_00001: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b001_00010: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b001_00011: horiz = 240'h000_000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000_000;
                8'b001_00100: horiz = 240'h000_000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000_000;
                8'b001_00101: horiz = 240'h000_000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000_000;
                8'b001_00110: horiz = 240'h000_000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000_000;
                8'b001_00111: horiz = 240'h000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000;
                8'b001_01000: horiz = 240'h000_000_0F0_0F0_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000;
                8'b001_01001: horiz = 240'h000_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000;
                8'b001_01010: horiz = 240'h000_000_0F0_0F0_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000;
                8'b001_01011: horiz = 240'h000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000;
                8'b001_01100: horiz = 240'h000_000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000_000;
                8'b001_01101: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b001_01110: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b001_01111: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b001_10000: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b001_10001: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b001_10010: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b001_10011: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                
                8'b010_00000: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_00001: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_00010: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_00011: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_00100: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_00101: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_00110: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_00111: horiz = 240'h000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000;
                8'b010_01000: horiz = 240'h000_000_0F0_0F0_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000;
                8'b010_01001: horiz = 240'h000_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000;
                8'b010_01010: horiz = 240'h000_000_0F0_0F0_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000;
                8'b010_01011: horiz = 240'h000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000;
                8'b010_01100: horiz = 240'h000_000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000_000;
                8'b010_01101: horiz = 240'h000_000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000_000;
                8'b010_01110: horiz = 240'h000_000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000_000;
                8'b010_01111: horiz = 240'h000_000_000_000_000_000_000_0F0_0F0_0F0_0F0_0F0_0F0_000_000_000_000_000_000_000;
                8'b010_10000: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_10001: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_10010: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                8'b010_10011: horiz = 240'h000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
                
                
                default: horiz = 240'hF00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00;
            endcase
        end
        else begin
            horiz = 0;
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
