`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// 
// This module implements the physics of transitioning from one waveform to another
// and provides a wrapper for the wave_logic module.
// It provides constant output, switching over frequencies smoothly when wave_logic is done calculating.
    //reset is reset
    //clock is 65 mhz
    //vsync is vsync
    //d_offset is the change, in pixels, of the player offset in one frame.
    //r_offset, if asserted for one cycle of vsync, resets the internal offset counters to 0.  Active high.
    //hcount is hcount
    //freq_id1 and freq_id2 are frequency id inputs, ranging from 0 to 24.  
        //A value of 31 means no frequency input in that channel, so 0, 1, or 2 frequency inputs can be used.
    //new_f_in is asserted for one clock cycle when a new frequency id is input.
    //player_profile is the output corresponding to the player's vertical position.
    //wave_profile is the output corresponding to the wave's vertical height at that hcount and offset.
    //Outputs appear with a 6-cycle delay after their corresponding hcount is input.
// 
//////////////////////////////////////////////////////////////////////////////////


module physics(input reset,
               input clock,
               input vsync,
               input [10:0] d_offset, //change in offset of player relative to start of wave.
               input r_offset, //reset the offset counters.  Assert for one vsync.
               input [10:0] hcount, //current hcount of requested pixel
               input [4:0] freq_id1, //frequency id from keyboard; 0 is lowest, 24 highest.
               input [4:0] freq_id2, //5'b11111 if no second frequency
               input new_f_in, //asserted for one clock when a new frequency is available from the keyboard
               output reg [9:0] player_profile, //where the player will be vertically.  Affected by prior frequency
               output reg [9:0] wave_profile //waveform to be displayed.  Affected only by current frequency
               );
    
    //calculation variables
    reg [10:0] prev_hcount; //delayed by one cycle value of hcount
    reg [9:0] wave_coeff; //blending coefficient for waveform
    reg [9:0] coeff; //blending coefficient for player path; 0 means entirely most recent frequency.
    reg [9:0] index[3:0];
    reg [10:0] offset_p [3:0]; //offset trimmed to periods
    reg [12:0] offset_p1 [3:0]; //temp calculation holder
    reg [12:0] offset_p2 [3:0]; //temp calculation holder
    reg [1:0] offset_change; //from clock to vsync
    reg [1:0] offset_received; //from vsync back to clock
    reg [1:0] offset_calc; //within clock
    wire [1:0] offset_calcp; //delayed by some number of cycles to allow frequency to update
    reg [10:0] hcount_p [3:0]; //value + hcount
    reg curr_w0; //1 if 0 and 1 were most recently updated
    
    
    pipeliner #(.CYCLES(4), .LOG(3), .WIDTH(2)) p_hcount (.reset(reset), .clock(clock), .in(offset_calc), .out(offset_calcp));
    
    //embedded wave_logic modules
    reg [4:0] freq_id [3:0];
    wire [10:0] freq [3:0];
    reg [3:0] new_f;
    
    reg [2:0] quotient[3:0];
    reg [9:0] height[3:0];
    wire [9:0] height_out[3:0];
    wire [10:0] period[3:0];
    wire [3:0] ready;
    reg [3:0] wave_ready; //persistent record of ready[3:0]
    
    
    //wave logic modules
    //each of these handles one frequency.
    //0 and 1 handle the two recently-input frequencies when curr_w0 is 1
    //2 and 3 handle the two recently-input frequencies when curr_w0 is 0
    //When curr_w0 is 1, 2 and 3 maintain their previous values to effect a smooth transition.
    //The coeff and wave_coeff variables handle exponential decay of the previous waveforms.
    wave_logic wl0 (.reset(reset), .clock(clock), .freq_id(freq_id[0]), .new_f(new_f[0]), 
                    .index(index[0]), .wave_height(height_out[0]), .period(period[0]), .c_freq(freq[0]), .wave_ready(ready[0]));
    wave_logic wl1 (.reset(reset), .clock(clock), .freq_id(freq_id[1]), .new_f(new_f[1]), 
                    .index(index[1]), .wave_height(height_out[1]), .period(period[1]), .c_freq(freq[1]), .wave_ready(ready[1]));
    wave_logic wl2 (.reset(reset), .clock(clock), .freq_id(freq_id[2]), .new_f(new_f[2]), 
                    .index(index[2]), .wave_height(height_out[2]), .period(period[2]), .c_freq(freq[2]), .wave_ready(ready[2]));
    wave_logic wl3 (.reset(reset), .clock(clock), .freq_id(freq_id[3]), .new_f(new_f[3]), 
                    .index(index[3]), .wave_height(height_out[3]), .period(period[3]), .c_freq(freq[3]), .wave_ready(ready[3]));
    
    initial begin //initial values
        coeff <= 9'b111111111;
        wave_coeff <= 9'b111111111;
        wave_ready <= 0;
        curr_w0 <= 0;
        offset_p[0] <= 0;
        offset_p[1] <= 0;
        offset_p[2] <= 0;
        offset_p[3] <= 0;
        offset_change <= 0;
        offset_received <= 0;
    end
    
    //at each new clock cycle (pixel)
    always @(posedge clock) begin
        
        
        //calculating index (total offset within a period), which is equal to (offset + hcount) % period
        //number of periods within offset_p+hcount
        quotient[0] <= (({11'b0, offset_p[0]} + hcount) * freq[0]) >> 18;
        quotient[1] <= (({11'b0, offset_p[1]} + hcount) * freq[1]) >> 18;
        quotient[2] <= (({11'b0, offset_p[2]} + hcount) * freq[2]) >> 18;
        quotient[3] <= (({11'b0, offset_p[3]} + hcount) * freq[3]) >> 18;
        
        //keeps the output wave profile horizontal given a frequency id input of 5'b11111.
        height[0] <= &freq_id[0] ? 384 : height_out[0];
        height[1] <= &freq_id[1] ? 384 : height_out[1];
        height[2] <= &freq_id[2] ? 384 : height_out[2];
        height[3] <= &freq_id[3] ? 384 : height_out[3];
        
        //store previous hcount
        prev_hcount <= hcount;
        
        //computes (offset_p+hcount) % period
        //subtraction value is to get rid of errors due to the inaccuracy introduced by the need for ROM values to be integers
        index[0] <= (period[0]*quotient[0] > offset_p[0] + hcount) ? 0 : offset_p[0] + prev_hcount - period[0]*quotient[0]-1;
        index[1] <= (period[1]*quotient[1] > offset_p[1] + hcount) ? 0 : offset_p[1] + prev_hcount - period[1]*quotient[1]-1;
        index[2] <= (period[2]*quotient[2] > offset_p[2] + hcount) ? 0 : offset_p[2] + prev_hcount - period[2]*quotient[2]-1;
        index[3] <= (period[3]*quotient[3] > offset_p[3] + hcount) ? 0 : offset_p[3] + prev_hcount - period[3]*quotient[3]-1;
        
        //semaphores.  if vsync has acknowledged receipt, reset semaphores.
        if (offset_received[0]) begin
            offset_change[0] <= 0;
        end
        if (offset_received[1]) begin
            offset_change[1] <= 0;
        end
        
        //only asserted for one clock cycle
        if (offset_calc[0]) begin
            offset_calc[0] <= 0;
        end
        if (offset_calc[1]) begin
            offset_calc[1] <= 0;
        end
        //if calculating next offset
        if (offset_calcp[0]) begin
            offset_p2[0] <= {11'b0,offset_p1[0]}*period[0] >> 10; //multiply offsets by new period
            offset_p2[1] <= {11'b0,offset_p1[1]}*period[1] >> 10; //multiply offsets by new period
            
            offset_change[0] <= 1; //signal vsync
        end
        if (offset_calcp[1]) begin
            offset_p2[2] <= {11'b0,offset_p1[2]}*period[2] >> 10; //multiply offsets by new period
            offset_p2[3] <= {11'b0,offset_p1[3]}*period[3] >> 10; //multiply offsets by new period
            
            offset_change[1] <= 1;
        end
        
        //if new frequency
        if (new_f_in || reset) begin
            wave_ready <= 0; //reset ready signals
        end
        else begin //otherwise, each wave_ready bit is asserted when the corresponding ready is asserted
            wave_ready <= wave_ready | ready; //these bits remain asserted until reset
        end
                
        if (curr_w0) begin
            //calculate wave profile
            //wave_coeff and coeff ensure blending.  As they approach zero, the waveform becomes entirely composed of the new frequencies.
            wave_profile <= (((height[0] + height[1] - 384) * {10'b0, ~wave_coeff}) >> 10)+(({10'b0, wave_coeff} * (height[2] + height[3] - 384)) >> 10);
            player_profile <= (((height[0] + height[1] - 384) * {10'b0, ~coeff}) >> 10)+(({10'b0, coeff} * (height[2] + height[3] - 384)) >> 10);
            
            if (new_f_in) begin
                //always update these values
                freq_id[2] <= freq_id1;
                freq_id[3] <= freq_id2; //update freq_ids for waveform calculation
                new_f[2] <= 1;
                new_f[3] <= 1;
                
                //start calculating new offset
                offset_p1[2] <= offset_p[0]*{11'b0, freq[0]} >> 8; //divide offsets by old period
                offset_p1[3] <= offset_p[1]*{11'b0, freq[1]} >> 8; //divide offsets by old period
                offset_calc[1] <= 1;
                
            end
            else begin
                new_f[2] <= 0;
                new_f[3] <= 0;
            end
        end
        else begin
            //calculate wave profile
            wave_profile <= (((height[2] + height[3] - 384) * {10'b0, ~wave_coeff}) >> 10)+(({10'b0, wave_coeff} * (height[0] + height[1] - 384)) >> 10); //+ ({10'b0, wave_coeff} * (height[0] + height[1] - 384)) >> 10);//height[2] + height[3] - 384;
            player_profile <= (((height[2] + height[3] - 384) * {10'b0, ~coeff}) >> 10)+(({10'b0, coeff} * (height[0] + height[1] - 384)) >> 10);
            
            
            if (new_f_in) begin
                freq_id[0] <= freq_id1;
                freq_id[1] <= freq_id2; //update freq_ids for waveform calculation
                new_f[0] <= 1;
                new_f[1] <= 1;
                
                //start calculating offset
                offset_p1[0] <= offset_p[2]*{11'b0, freq[2]} >> 8; //divide offsets by old period
                offset_p1[1] <= offset_p[3]*{11'b0, freq[3]} >> 8; //divide offsets by old period
                offset_calc[0] <= 1;
                
                
            end
            else begin
                new_f[0] <= 0;
                new_f[1] <= 0;
            end
        end
    end
    
    //at each frame
    always @(negedge vsync) begin
        
        if (r_offset) begin //if offset reset signal is asserted
            offset_p[0] <= 0;
            offset_p[1] <= 0; //reset
            offset_p[2] <= 0;
            offset_p[3] <= 0;
            
            offset_received[0] <= 0;
            offset_received[1] <= 0;
        end
        else if (offset_change[0]) begin //shift in new calculated values
            offset_p[0] <= offset_p2[0];
            offset_p[1] <= offset_p2[1];
            
            offset_received[0] <= 1; //acknowledge receipt of offsets
            offset_received[1] <= 0;
        end
        else if (offset_change[1]) begin
            offset_p[2] <= offset_p2[2];
            offset_p[3] <= offset_p2[3];
            
            offset_received[0] <= 0;
            offset_received[1] <= 1; //acknowledge receipt of offsets
        end
        else begin //ordinarily
            //offset_p[i] integrates d_offset, staying within period[i].
            offset_p[0] <= (((offset_p[0] + d_offset) >= period[0]) ? ((offset_p[0] + d_offset)-period[0]) : ((offset_p[0] + d_offset)));
            offset_p[1] <= (((offset_p[1] + d_offset) >= period[1]) ? ((offset_p[1] + d_offset)-period[1]) : ((offset_p[1] + d_offset)));
            offset_p[2] <= (((offset_p[2] + d_offset) >= period[2]) ? ((offset_p[2] + d_offset)-period[2]) : ((offset_p[2] + d_offset)));
            offset_p[3] <= (((offset_p[3] + d_offset) >= period[3]) ? ((offset_p[3] + d_offset)-period[3]) : ((offset_p[3] + d_offset)));
            
            offset_received[0] <= 0;
            offset_received[1] <= 0;
        end
        
        
        
        coeff <= coeff * 1000 >> 10;
        wave_coeff <= wave_coeff * 950 >> 10;
                
        if (reset) begin //reset
            curr_w0 <= 0;
            
        end
        else if (curr_w0) begin //if wl[0 and 1] were most recently updated
            
            if (wave_ready[2] & wave_ready[3]) begin //if a calculation has finished in both waveforms
                //switch to other two waveforms being primary waveforms
                curr_w0 <= 0;
                
                //reset blending coefficients
                coeff <= 9'b111111111;
                wave_coeff <= 9'b111111111;
            end
            
            
        end
        else begin //if wl[2 and 3] were most recently updated
            
            
            if (wave_ready[0] & wave_ready[1]) begin //if a calculation has finished in both waveforms
                //switch to other two waveforms being primary waveforms
                curr_w0 <= 1;
                
                //reset blending coefficients
                coeff <= 9'b111111111;
                wave_coeff <= 9'b111111111;
            end
        end
    end
    
endmodule
