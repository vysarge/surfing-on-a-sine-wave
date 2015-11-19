`timescale 1ns / 1ps

module midi
			#(parameter COUNT=12'd2080,			//baud rate of MIDI is 31.25kHz -> 65Mhz/31.25kHz = 2080
				TIME_THRESHOLD = 12'd300,
				ERROR_THRESHOLD = 12'd500,
				NOTE_WIDTH = 6,
				WAIT = 0,
				START = 1,
				NOTE = 2,
				CHECK_MSG = 3)				
				(input clk, serial,
				output reg ready,
				output reg [6:0] key_index=0);
	reg [11:0] time_counter = 0;
	reg [9:0] error = 0;
	reg set_index = 1;
	reg [11:0] serial_sample = 0;
	reg [3:0] bit_counter = 0;
	reg [1:0] state = 0;
	reg [6:0] temp_index=0;
	
	always @ (posedge clk) begin
        case (state)
            WAIT: begin
                time_counter<=0;
                bit_counter<=0;
                ready<=0;
                temp_index<=0;
                serial_sample<=0;
                error<=0;
                set_index<=1;
                if (serial == 0) state<=START;
            end
            
            START: begin 
                time_counter<=time_counter+1;
                if(time_counter == COUNT) begin
                    time_counter<=0;
                    state<=NOTE;
                end
            end
            
            NOTE: begin
                serial_sample <= serial_sample + serial;
                time_counter <= time_counter+1;
                
                if(time_counter == COUNT)  begin
                    time_counter<=0;
                    serial_sample<=0;
                    if (serial_sample > COUNT-TIME_THRESHOLD) begin
                        temp_index[bit_counter]<=1;
                    end
                    else if (serial_sample < TIME_THRESHOLD) begin
                        temp_index[bit_counter]<=0;
                    end
                    else temp_index[bit_counter] <= 1'bx;
                    
                    if ( bit_counter == NOTE_WIDTH ) begin
                        bit_counter<=0;
                        state<=CHECK_MSG;
                    end
                    else
                        bit_counter<=bit_counter+1;
                end
                    
            end
            
            CHECK_MSG: begin
                time_counter <= time_counter+1;
                if(bit_counter == 1 || bit_counter == 9) begin
                    if(time_counter > TIME_THRESHOLD && time_counter < (COUNT-TIME_THRESHOLD) && serial==0)
                        error <= error+1;
                         
                end else begin
                    if(time_counter > TIME_THRESHOLD && time_counter < (COUNT-TIME_THRESHOLD) && serial==1)
                        error <= error+1; 
                end
                
                if(error>ERROR_THRESHOLD)
                    set_index<=0;
                
                if(time_counter==COUNT) begin
                    bit_counter <= bit_counter+1;
                    time_counter <= 0;
                end
                
                if(bit_counter==11) begin
                    state <= WAIT;
                    if(set_index) begin
		                ready <= 1;
		                key_index <= temp_index;
		            end
                end
            end
        endcase
    end
		
endmodule
