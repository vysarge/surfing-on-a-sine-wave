`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Wave computation module.
// 
// Instructions for use:
//          1. Input frequency id and pulse new_f high for one clock cycle.  0 is lowest, 24 is highest.
//          2. wave_ready asserted for one clock cycle when computation has finished and values can be read from the module.
//          3. To read a value, set index and read wave_height after a clock cycle has passed.
// 
module wave_logic #(parameter LOG_WIDTH=10, //log of horizontal values
                    parameter WIDTH=1024 //actual number of horizontal values
                    )
                   (input reset,
                    input clock,
                    input [4:0] freq_id, //current frequency id input, 0 to 24, 0 being lowest
                    input new_f, //pulses high for one clock cycle when a new frequency is input
                    input [10:0] index, //horizontal input index
                    output reg [9:0] wave_height, //waveform height at index
                    output reg [10:0] period, //number of places in waveform that are filled.
                    output reg [10:0] c_freq,
                    output reg wave_ready //goes high for one clock cycle when wave profile calculation is done
                    );
    
    //set up sine rom
    wire [10:0] period_out;
    wire [10:0] freq_out; 
    //reg [10:0] c_freq; //current frequency during calculation
    wire [9:0] c_value; //current value output from rom
    reg [10:0] c_index; //adjusted index (index to be input to ROM to receive proper output given frequency)
    reg [31:0] waveform [1023:0]; //full waveform profile, with any applied transforms etc
    reg [10:0] index_counter; // current index (filling waveform) 
    reg [18:0] undivided_c_index; //next index * c_freq (current adjusted index * 256)
    //reg [9:0] output_index; //index adjusted for period etc
    
    wave_rom wr(.index(c_index), .freq_id(freq_id), .value(c_value), .freq(freq_out), .period(period_out));
    
    //pipelining semaphore
    reg filling_waveform; //calculating waveform values
    reg prev_filling_waveform;
    
    initial begin //initial values for simulation
        index_counter = 0;
        filling_waveform = 0;
    end
    
    always @(posedge clock) begin
        
        wave_height <= waveform[index];
        
        //set correct index to retrieve for next cycle (loops input indexes repeatedly over single period where necessary
        //output_index <= index % period;
        
        
        //keeping track
        prev_filling_waveform <= filling_waveform;
                
        if (reset) begin //reset values
            c_freq <= 256;
            wave_ready <= 0;
            filling_waveform <= 1;
            index_counter <= 0;
            period <= 1024;
        end
        else if (new_f) begin //if a new frequency id input is there, rom fetching freq_out and period_out
            filling_waveform <= 1; //set flag; time to fill waveform array
            wave_ready <= 0;
            index_counter <= 0;
            
        end
        else if (filling_waveform) begin //actual frequency value here.  Fill one slot in waveform array this cycle.
            //if first cycle of filling
            if (prev_filling_waveform == 0) begin
                c_freq <= freq_out;
                period <= period_out;
                index_counter <= 0;
                wave_ready <= 0;
                c_index <= 0;
                undivided_c_index <= c_freq; //because of pipelining, this is initialized to the value corresponding to index_counter = 1
                filling_waveform <= 1; //keep filling semaphore on
            end
            else begin
                
                //depending on area, fill waveform in appropriate way
                if (period == 1) begin
                    waveform[index_counter] <= 384;
                end
                else if (c_index < 512) begin
                    waveform[index_counter] <= (c_value>>3)+384; //fill one slot
                end
                else begin
                    waveform[index_counter] <= 384-(c_value>>3); //fill one slot
                end
                
                
                if (index_counter >= period) begin //if done filling now
                    wave_ready <= 1;
                    filling_waveform <= 0; //set flags
                end
                else begin //otherwise keep going
                    filling_waveform <= 1;
                    wave_ready <= 0;
                    
                    
                    
                    index_counter <= index_counter+1; //increment counter
                    undivided_c_index <= undivided_c_index + c_freq; //gradually adding this up to avoid multiplying
                    c_index <= undivided_c_index >> 8; //c_index is used to read values from rom
                end
            end
            
            
        end
        else begin //if index is 0
            filling_waveform <= 0;
            wave_ready <= 0; //deassert wave_ready after one clock cycle
        end
    end
    
    
endmodule


