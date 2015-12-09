`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Single frequency audio level calculation.
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
    reg [9:0] next_index; //place to put calculated index in anticipation of next cycle
    reg [BITS-1:0] count; //counter that loops between 0 and 63 by default
    reg [15:0] count_index; //frequency-adjusted index.
    wire [15:0] period; //period and freq outputs
    wire [15:0] freq;
    reg [4:0] freq_id_rom; //buffered input
    wire [BITS-1:0] value; //output from rom
    
    //for sine values
    audio_rom #(.BITS(6)) audio_rom(.index(index), .freq_id(freq_id_rom), .level(value), .freq(freq), .period(period));
    
    //on the positive clock edge
    always @(posedge clock) begin
        
        //given a new frequency, update the frequency id seen by the ROM
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
            else begin //increment
                count_index <= count_index + 1;
            end
            
            //calculate next index!
            //there's a lot of time to do this calculation.
            next_index <= {16'b0,count_index} * freq >> (BITS+8);
            
            //sine wave
            if (form == SIN) begin
                level <= value;
            end
            /*else if (form == TRI) begin //triangle wave; phased out because it sounds awful with LPF
                if (index < 256) level <= ((index) >> (BITS-2)) + 25;
                else if (index < 512) level <= ((512-index) >> (BITS-2)) + 25;
                else if (index < 768) level <= 25 - ((index - 512) >> (BITS-2));
                else level <= 25 - ((1024 - index) >> (BITS-2));
            end*/
            else if (form == SQ) begin //square wave
                if (index < 256) level <= 30;
                else if (index < 512) level <= 0;
                else if (index < 768) level <= 30;
                else level <= 0;
            end
            else begin //no sound catch-all
                level <= 0;
            end
            
        end
        
    end
endmodule
