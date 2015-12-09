`timescale 1ns / 1ps

module midi
			#(parameter COUNT=12'd2080,			//baud rate of MIDI is 31.25kHz -> 65Mhz/31.25kHz = 2080
				TIME_THRESHOLD = 12'd300,
				ERROR_THRESHOLD = 12'd500,
				NOTE_WIDTH = 6,
				MSG_WIDTH = 10,
				WAIT = 0,
				START = 1,
				NOTE = 2,
				GET_MSG = 3,
				READ_MSG=4)				
				(input clk, serial,
				output reg ready,
				output reg [6:0] key1_index=0,
				output reg [6:0] key2_index=0);
	reg [11:0] time_counter = 0;
	reg [9:0] error = 0;
	reg set_index = 1;
	reg [11:0] serial_sample = 0;
	reg [3:0] bit_counter = 0;
	reg [2:0] state = WAIT;
	reg [6:0] temp_index=0;
	reg [10:0] message = 0;
	reg key1_held = 0;
	reg key2_held = 0;
	
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
                if (serial == 0) state<=START;              // begin deserializing when the signal goes low
            end
            
            START: begin 
                time_counter<=time_counter+1;               // wait through start bit
                if(time_counter == COUNT) begin
                    time_counter<=0;
                    state<=NOTE;
                end
            end
            
            NOTE: begin
                serial_sample <= serial_sample + serial;    // sample the signal every clock cycle
                time_counter <= time_counter+1;
                
                if(time_counter == COUNT)  begin            // beginning of new bit
                    time_counter<=0;
                    serial_sample<=0;
                    if (serial_sample > COUNT-TIME_THRESHOLD) begin     //record high or low for bit just ended
                        temp_index[bit_counter]<=1;
                    end
                    else if (serial_sample < TIME_THRESHOLD) begin      // use bit_counter as index because 
                        temp_index[bit_counter]<=0;                     // note value is little endian
                    end
                    else temp_index[bit_counter] <= 1'bx;
                    
                    if ( bit_counter == NOTE_WIDTH ) begin              // done collecting pitch value information
                        bit_counter<=MSG_WIDTH;     
                        state<=GET_MSG;
                    end
                    else
                        bit_counter<=bit_counter+1;
                end
                    
            end
            
            GET_MSG: begin
                serial_sample <= serial_sample + serial;                // same as above, but for message byte
                time_counter <= time_counter+1;
                
                if(time_counter == COUNT)  begin
                    time_counter<=0;
                    serial_sample<=0;
                    if (serial_sample > COUNT-TIME_THRESHOLD) begin
                        message[bit_counter]<=1;
                    end
                    else if (serial_sample < TIME_THRESHOLD) begin
                        message[bit_counter]<=0;
                    end
                    else message[bit_counter] <= 1'bx;
                    
                    if ( bit_counter == 0 ) begin
                        state<=READ_MSG;
                    end
                    else
                        bit_counter<=bit_counter-1;
                end
            end
            READ_MSG: begin
                state<=WAIT;
                if(message == 11'b01000000010) begin                //"note on" message
                    if(~key1_held) begin
                        key1_index<=temp_index;
                        key1_held<=1;
                        ready<=1;
                    end else if (~key2_held) begin
                        key2_index<=temp_index;
                        key2_held<=1;
                        ready<=1;
                    end
                end else if (message == 11'b01000000000) begin      //"note off" message
                    if(key2_held && (temp_index==key2_index)) begin
                        key2_index <= 0;
                        key2_held <= 0;
                        ready<=1;
                    end else if (key1_held && (temp_index==key1_index)) begin
                        if (key2_held) begin
                            key1_index <= key2_index;
                            key1_held<=1;
                            key2_held<=0;
                            key2_index<=0;
                            ready<=1;
                        end else begin
                            key1_held<=0;
                        end
                    end
                end
            end
        endcase
    end
		
endmodule
