`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module audio_wave #(parameter BITS = 6)
                 (input reset,
                  input clock,
                  input [1:0] form,
                  input [4:0] freq_id,
                  input new_f,
                  output reg [BITS-1:0] level
    );
    
    //parameters for types of waves
    parameter SIN = 2'd0;
    parameter TRI = 2'd1;
    parameter SQ = 2'd2;
    
    reg [9:0] index; //current scaled horizontal index (512 is halfway through a period)
    reg [9:0] next_index;
    reg [BITS-1:0] count;
    reg [15:0] count_index;
    wire [15:0] period;
    wire [15:0] freq;
    reg [4:0] freq_id_rom;
    wire [BITS-1:0] value;
    
    audio_rom #(.BITS(6)) audio_rom(.index(index), .freq_id(freq_id_rom), .level(value), .freq(freq), .period(period));
    
    
    initial begin
        
        //freq_id = 12;
        //period = 243; //middle C
        //freq = 270;
    end
    
    always @(posedge clock) begin
        
        if (new_f) begin
            freq_id_rom <= freq_id;
        end
        //increment count
        count <= count + 1;
        
        
        
        
        
        if (count == 0) begin //if the next cycle is beginning
            index <= next_index;
            
            //count_index loops between 0 and period
            if (count_index >= (period << (BITS-6))) begin
                count_index <= 0;
            end
            else begin
                count_index <= count_index + 1;
            end
            
            /*if (count_index >= (period >> (7-BITS))) begin
                level <= 20;
            end
            else begin
                level <= 0;
            end*/
            
            //calculate next index!
            next_index <= {16'b0,count_index} * freq >> (BITS+8);
            
            
            if (form == SIN) begin
                level <= value;
            end
            /*else if (form == TRI) begin
                if (index < 256) level <= ((index) >> (BITS-2)) + 25;
                else if (index < 512) level <= ((512-index) >> (BITS-2)) + 25;
                else if (index < 768) level <= 25 - ((index - 512) >> (BITS-2));
                else level <= 25 - ((1024 - index) >> (BITS-2));
            end*/
            else if (form == SQ) begin
                if (index < 256) level <= 30;
                else if (index < 512) level <= 0;
                else if (index < 768) level <= 30;
                else level <= 0;
            end
            else begin
                level <= 0;
            end
            
            
            //square wave
            /*if (index > 512) begin
                level <= 0;
            end
            else begin
                level <= 20;
            end*/
        end
        else begin
            
        end
        
        
        
    end
endmodule
