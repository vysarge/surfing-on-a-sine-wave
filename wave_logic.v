`timescale 1ns / 1ps

module wave_logic #(parameter LOG_WIDTH=10, //log of horizontal values
                    parameter WIDTH=1024, //actual number of horizontal values
                    parameter RESOL=10, //log resolution of vertical outputs
                    parameter BASE_FREQ=220 //lowest possible frequency
                    )
                   (input reset,
                    input clock,
                    input [10:0] frequency, //current frequency input
                    input new_f, //pulses high for one clock cycle when a new frequency is input
                    //output reg [RESOL-1:0] wave_prof [WIDTH-1:0], //wave profile output
                    //output reg [RESOL-1:0] prev_wave_prof [WIDTH-1:0],
                    output reg wave_ready //goes high for one clock cycle when wave profile calculation is done
                    );
    
    //set up sine rom
    reg [10:0] c_freq; //current frequency during calculation
    reg [LOG_WIDTH-1:0] out_index;
    wire [LOG_WIDTH-1:0] index;
    wire [RESOL-1:0] value;
    sine_rom s_rom(.index(index), .value(value));
    freq_div #(.BASE_FREQ(BASE_FREQ)) fd (.out_index(out_index), .c_freq(c_freq), .index(index));
    
    always @(posedge clock) begin
        if (reset) begin //reset values
            out_index <= 0;
            c_freq <= 0;
            wave_ready <= 0;
        end
        else if (new_f) begin //if a new frequency input is there
            out_index <= 1;  //get ready to calculate
            c_freq <= frequency; //set frequency
            //wave_prof[0] <= 0; //0th entry is always 0
            wave_ready <= 0;
            //prev_wave_prof[WIDTH-1:0] <= wave_prof[WIDTH-1:0]; //shift previous values
        end
        else if ((out_index > 0) & (out_index < WIDTH)) begin //while calculating
            out_index <= out_index + 1; //increment index
            //wave_prof[out_index] <= value; //shift in current value
            
            if (out_index == WIDTH-1) begin //if done
                wave_ready <= 1; //assert wave_ready
            end
            else begin //otherwise
                wave_ready <= 0;
            end
        end
        else begin //if index is 0
            out_index <= 0;
            wave_ready <= 0; //deassert wave_ready after one clock cycle
        end
    end
    
    
endmodule




module sine_rom #(parameter LOG_VALUES=10,
                  parameter VALUES=1024,
                  parameter RESOL=10)
                 (input [LOG_VALUES-1:0] index,
                  output reg [RESOL-1:0] value
                  );
    
    //rom
    always @(index) begin
        
        case(index)
            default: value = 0;
        endcase
    end
    
    
    
endmodule



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//temporary placeholder
module freq_div #(parameter LOG_WIDTH = 10,
                  parameter BASE_FREQ = 220
                  )
                 (input[LOG_WIDTH-1:0] out_index, //index of current frequency waveform
                  input [10:0] c_freq, //current frequency
                  output[LOG_WIDTH-1:0] index //index of base frequency waveform
                  );
    assign index = out_index;
endmodule
