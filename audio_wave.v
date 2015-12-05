`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module audio_wave #(parameter BITS = 6)
                 (input reset,
                  input clock,
                  input [4:0] freq_id,
                  input new_f,
                  output reg [BITS-1:0] level
    );
    
    reg [9:0] index; //current scaled horizontal index (512 is halfway through a period)
    reg [9:0] next_index;
    reg [BITS-1:0] count;
    reg [15:0] count_index;
    reg [15:0] period;
    reg [10:0] freq;
    reg [4:0] freq_id_rom;
    
    //audio_rom audio_rom();
    
    initial begin
        period = 243; //middle C
        freq = 270;
    end
    
    always @(posedge clock) begin
        
        //increment count
        count <= count + 1;
        
        
        
        
        
        if (count == 0) begin //if the next cycle is beginning
            index <= next_index;
            
            //count_index loops between 0 and period
            if (count_index >= (period << (BITS-2))) begin
                count_index <= 0;
            end
            else begin
                count_index <= count_index + 1;
            end
            
            /*if (count_index >= (period << (BITS-3))) begin
                level <= 20;
            end
            else begin
                level <= 0;
            end*/
            
            //calculate next index!
            next_index <= {10'b0,count_index} * freq >> (BITS+4);
            
            //square wave
            if (index > 512) begin
                level <= 0;
            end
            else begin
                level <= 20;
            end
        end
        else begin
            
        end
        
        
        
    end
endmodule
