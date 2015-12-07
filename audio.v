`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module audio #(parameter BITS = 6, //bit resolution of audio output
               parameter NOTE_LENGTH = 20, //2^NOTE_LENGTH cycles of count until the note changes
               parameter SIL_LENGTH = 17 //2^SIL_LENGTH cycles of count between notes.
               )
            (input reset,
             input clock,
             input [4:0] freq_id1,
             input [4:0] freq_id2,
             input new_f,
             input [1:0] form,
             input music, //1 if game should try to play music; 0 if only frequency tones should be played.
             output reg [5:0] state,
             output reg pwm,
             output reg new_f_notes,
             output reg sil,
             output reg note,
             output reg [NOTE_LENGTH-1:0] note_counter,
             output reg [BITS-1:0] count,
             output [4:0]freq0
    );
    assign freq0 = freq[0];
    //parameters for types of waves
    parameter SIN = 0;
    parameter TRI = 1;
    parameter SQ = 2;
    
    //parameters for chord states
    parameter I = 0;
    parameter V6 = 1;
    parameter I6 = 2;
    parameter V7 = 3;
    parameter IV7 = 4;
    parameter ii = 5;
    parameter IV = 6;
    parameter vi = 7;
    parameter iii = 8;
    parameter viid6 = 9;
    parameter i = 10;
    parameter iid = 11;
    parameter iv = 12;
    parameter VI = 13;
    parameter III = 14;
    parameter VII6 = 15;
    parameter A4 = 16;
    parameter V = 17;
    parameter VMINOR = 18;
    parameter viid6MINOR = 19;
    
    //random numbers for chord fsm
    wire [31:0] random;
    reg rng_pulse;
    rng rng (.clk(clock),.new_number(rng_pulse),.seed({freq[0],freq[1],freq[2],freq[3]}), .random(random));
    
    
    reg [BITS-1:0] curr_level; //net current wave level
    reg [BITS-1:0] curr_level_music;
    //reg [BITS-1:0] count; //current count; resets when it's time for a new pwm period
    
    wire [BITS-1:0] level[5:0];
    
    //reg playing; //currently playing a note (if 0, waiting)
    //reg [NOTE_LENGTH-1:0] note_counter;
    reg [SIL_LENGTH-1:0] sil_counter;
    
    //information about notes
    reg [4:0] freq_diff; //positive difference between notes
    reg [4:0] lower_freq; //lower frequency
    reg [4:0] higher_freq; //higher frequency; empty if only one frequency
    reg two_freq; //1 if two frequencies; 0 if only one
    //wire new_f_notes; //new_f for note audio_wave instances
    reg [4:0] base_freq; //frequency to be used as the 'base' (i/I chord) of the audio output
    reg [4:0] freq[3:0]; //frequencies to be played by the corresponding audio_wave instances
    //reg [5:0] state; //chord state
    reg [4:0] fade_coeff; //fade out.
    
    wire new_f_delay;
    pipeliner #(.CYCLES(1), .LOG(2), .WIDTH(1)) a0 (.reset(reset), .clock(clock), .in(new_f), .out(new_f_delay));
    wire new_f_delay2;
    pipeliner #(.CYCLES(2), .LOG(2), .WIDTH(1)) a1 (.reset(reset), .clock(clock), .in(new_f), .out(new_f_delay2));
    
    
    //pipeliner #(.CYCLES(10), .LOG(4), .WIDTH(1)) a2 (.reset(reset), .clock(clock), .in(new_f), .out(new_f_notes));
    audio_wave #(.BITS(6)) audio_wave0 (.reset(reset), .clock(clock), .form(form), .freq_id(freq[0]), .new_f(new_f_notes), .level(level[0]));
    audio_wave #(.BITS(6)) audio_wave1 (.reset(reset), .clock(clock), .form(form), .freq_id(freq[1]), .new_f(new_f_notes), .level(level[1]));
    audio_wave #(.BITS(6)) audio_wave2 (.reset(reset), .clock(clock), .form(form), .freq_id(freq[2]), .new_f(new_f_notes), .level(level[2]));
    audio_wave #(.BITS(6)) audio_wave3 (.reset(reset), .clock(clock), .form(form), .freq_id(freq[3]), .new_f(new_f_notes), .level(level[3]));
    
    audio_wave #(.BITS(6)) audio_wave4 (.reset(reset), .clock(clock), .form(form), .freq_id(freq_id1), .new_f(new_f), .level(level[4]));
    audio_wave #(.BITS(6)) audio_wave5 (.reset(reset), .clock(clock), .form(form), .freq_id(freq_id2), .new_f(new_f), .level(level[5]));
    
    initial begin
        freq[0] <= 5'b11111;
        freq[1] <= 5'b11111;
        freq[2] <= 5'b11111;
        freq[3] <= 5'b11111;
        
        note_counter <= 0;
        sil_counter <= 1;
        sil <= 0;
        note <= 0;
    end
    
    
    always @(posedge clock) begin //65mhz
         
         //rng_pulse should only go high for one clock
         if (rng_pulse) rng_pulse <= 0;
         
         
         if (new_f) begin //when new_f goes high
             //freq_diff is the positive difference between notes.
             freq_diff <= (freq_id1 > freq_id2) ? (freq_id1 - freq_id2) : (freq_id2 - freq_id1);
             {lower_freq, higher_freq} <= (freq_id1 > freq_id2) ? {freq_id2, freq_id1} : {freq_id1, freq_id2};
             two_freq <= (freq_id2 != 5'b11111);
         end 
         if (new_f_delay) begin //one cycle later
             if (lower_freq < 4) begin //adjust frequency to compensate for limited output range
                 base_freq <= lower_freq + 12;
             end
             else if (lower_freq < 13) begin
                 base_freq <= lower_freq;
             end
             else begin
                 base_freq <= lower_freq - 12;
             end
         end
         if (new_f_delay2) begin //one cycle later
             casez ({two_freq, freq_diff})
                 6'b0zzzzz: begin //only one frequency
                                state <= I;
                            end
                 default: state <= I;
             endcase
             
             note_counter <= 0;
             //sil_counter <= 1;
             //fade_coeff <= 5'b11111;
         end
         
         curr_level <= (music) ? curr_level_music : (({2'b0,level[4]}+level[5])>>2);
         
         //increment count
         count <= count + 1;
         
         //curr_level / count is the volume level after the low pass.
         if (count == curr_level) begin
             pwm <= 0;
             //new_f_notes <= 0;
         end
         if (count == 0) begin
             pwm <= 1;
             
             rng_pulse <= 1;//generate a new random number
             
             //music control
             if (music) begin
                 
                 note_counter <= note_counter + 1;
                 
                 curr_level_music <= (({2'b0,level[0]} + level[1] + level[2] + level[3]) >> 2);
                 //curr_level_music <= level[0];
                 
                 
                 if (note_counter == 0) begin
                     new_f_notes <= 1;
                     
                     //calculate new notes
                     case(state)
                         I:       begin //I chord
                                      freq[0] <= base_freq; //root
                                      freq[1] <= base_freq + 4; //third
                                      freq[2] <= base_freq + 7; //fifth
                                      freq[3] <= base_freq + 12; //root
                                      
                                      if (random[0] && random[1]) state <= V6;
                                      else if (random[2] && random[3]) state <= V;
                                      else if (random[4]) state <= vi;
                                      else if (random[5]) state <= ii;
                                      else if (random[6]) state <= iii;
                                      else if (random[7]) state <= viid6;
                                      else state <= IV;
                                      
                                  end

                         V6:       begin //V6 chord
                                      freq[0] <= base_freq + 7; //root
                                      freq[1] <= base_freq + 2; //5th
                                      freq[2] <= base_freq + 7; //root
                                      freq[3] <= base_freq - 1; //3rd
                                      if (random[0]) state <= I;
                                      else if (random[1]) state <= vi;
                                      else state <= I6;
                                  end

                         I6:       begin //...
                                      freq[0] <= base_freq + 4; //3rd
                                      freq[1] <= base_freq + 7; //5th
                                      freq[2] <= base_freq + 12; //root
                                      freq[3] <= base_freq + 7; //5th
                                      if (random[0] && random[1]) state <= vi;
                                      else if (random[2] && random[3]) state <= iii;
                                      else if (random[4]) state <= V;
                                      else if (random[5]) state <= ii;
                                      else if (random[6]) state <= V6;
                                      else if (random[7]) state <= viid6;
                                      else state <= IV;
                                  end

                         V7:       begin //...
                                      freq[0] <= base_freq + 2; //5th
                                      freq[1] <= base_freq + 5; //7th
                                      freq[2] <= base_freq + 7; //root
                                      freq[3] <= base_freq + 11; //3rd
                                      if (random[0] || random[1]) state <= I;
                                      else state <= I6;
                                  end

                         IV7:       begin //...
                                      freq[0] <= base_freq; //5th
                                      freq[1] <= base_freq + 4; //7th
                                      freq[2] <= base_freq + 5; //root
                                      freq[3] <= base_freq + 9; //3rd
                                      state <= V7;
                                  end

                         ii:       begin //...
                                      freq[0] <= base_freq + 2; //root
                                      freq[1] <= base_freq + 2; //double the root
                                      freq[2] <= base_freq + 5; //3rd
                                      freq[3] <= base_freq + 9; //5th
                                      if (random[0] || random[1]) state <= V;
                                      else state <= V7;
                                  end

                         IV:       begin //...
                                      freq[0] <= base_freq + 5; //root
                                      freq[1] <= base_freq + 9; //3rd
                                      freq[2] <= base_freq + 12; //5th
                                      freq[3] <= base_freq + 5; //root
                                      if (random[0]) state <= V;
                                      else if (random[1]) state <= ii;
                                      else if (random[2]) state <= I;
                                      else state <= I6;
                                  end

                         vi:       begin //...
                                      freq[0] <= base_freq - 3; //root
                                      freq[1] <= base_freq; //3rd
                                      freq[2] <= base_freq + 4; //5th
                                      freq[3] <= base_freq + 9; //root
                                      
                                      state <= ii;
                                  end

                         iii:       begin //...
                                      freq[0] <= base_freq + 4; //root
                                      freq[1] <= base_freq + 4; //root
                                      freq[2] <= base_freq + 7; //3rd
                                      freq[3] <= base_freq + 11; //5th
                                      
                                      if (random[0] && random[1] && random[2]) state <= IV;
                                      else state <= vi;
                                  end

                         viid6:       begin //...
                                      freq[0] <= base_freq + 11; //root
                                      freq[1] <= base_freq + 11; //root
                                      freq[2] <= base_freq + 2; //3rd
                                      freq[3] <= base_freq + 5; //5th
                                      
                                      if (random[0] && random[1]) state <= I6;
                                      else state <= I;
                                  end



                         i:       begin //...
                                      freq[0] <= base_freq; //root
                                      freq[1] <= base_freq + 12; //root
                                      freq[2] <= base_freq + 3; //3rd
                                      freq[3] <= base_freq + 7; //5th
                                      
                                      if (random[0] && random[1]) state <= VI;
                                      else if (random[2] && random[3]) state <= VII6;
                                      else if (random[4]) state <= VMINOR;
                                      else if (random[5]) state <= III;
                                      else if (random[6]) state <= iid;
                                      else if (random[7]) state <= iv;
                                      else state <= viid6MINOR;
                                  end

                         iid:       begin //...
                                      freq[0] <= base_freq + 2; //root
                                      freq[1] <= base_freq + 2; //root
                                      freq[2] <= base_freq + 5; //3rd
                                      freq[3] <= base_freq + 8; //5th
                                      
                                      state <= VMINOR;
                                  end

                         iv:       begin //...
                                      freq[0] <= base_freq + 5; //root
                                      freq[1] <= base_freq + 5; //root
                                      freq[2] <= base_freq + 8; //3rd
                                      freq[3] <= base_freq + 12; //5th
                                      
                                      if (random[0]) state <= VMINOR;
                                      else if (random[1]) state <= iid;
                                      else state <= i;
                                  end

                         VI:       begin //...
                                      freq[0] <= base_freq - 4; //root
                                      freq[1] <= base_freq + 8; //root
                                      freq[2] <= base_freq; //3rd
                                      freq[3] <= base_freq + 3; //5th
                                      
                                      state <= iid;
                                      
                                  end

                         III:       begin //...
                                      freq[0] <= base_freq + 3; //root
                                      freq[1] <= base_freq + 3; //root
                                      freq[2] <= base_freq + 7; //3rd
                                      freq[3] <= base_freq + 10; //5th
                                      
                                      if (random[0] && random[1]) state <= iv;
                                      else state <= VI;
                                  end

                         VII6:       begin //...
                                      freq[0] <= base_freq + 10; //root
                                      freq[1] <= base_freq + 10; //root
                                      freq[2] <= base_freq + 2; //3rd
                                      freq[3] <= base_freq + 5; //5th
                                      
                                      state <= III;
                                  end

                         A4:       begin //...
                                      freq[0] <= base_freq - 1; //d5 base
                                      freq[1] <= base_freq + 5; //d5 top, a5 base
                                      freq[2] <= base_freq + 5; //...
                                      freq[3] <= base_freq + 11; //a5 top
                                      
                                      state <= I;
                                  end

                         V:       begin //...
                                      freq[0] <= base_freq + 7; //root
                                      freq[1] <= base_freq + 11; //3rd
                                      freq[2] <= base_freq + 14; //5th
                                      freq[3] <= base_freq + 7; //root
                                      
                                      if (random[0]) state <= I6;
                                      else if (random[1] && random[2]) state <= vi;
                                      else state <= I;
                                  end



                         VMINOR:       begin //...
                                      freq[0] <= base_freq + 7; //root
                                      freq[1] <= base_freq + 11; //3rd
                                      freq[2] <= base_freq + 14; //5th
                                      freq[3] <= base_freq + 7; //root
                                      
                                      if (random[0]) state <= VI;
                                      else state <= i;
                                  end

                         viid6MINOR:       begin //...
                                      freq[0] <= base_freq + 11; //root
                                      freq[1] <= base_freq + 11; //root
                                      freq[2] <= base_freq + 2; //3rd
                                      freq[3] <= base_freq + 5; //5th
                                      
                                      state <= i;
                                  end


                         default: begin
                                      freq[0] <= base_freq;
                                      freq[1] <= base_freq;
                                      freq[2] <= base_freq;
                                      freq[3] <= base_freq;
                                  end
                     endcase
                 end
                 else begin
                     new_f_notes <= 0;
                 end
             end
         end
             //counting up sil_counter
             /*if (music && (note_counter == 0)) begin
                 
                 if (sil_counter == 1) begin
                     fade_coeff <= 5'b11111;
                 end
                 
                 if (sil_counter[16] == 0 && sil_counter[17] > 0) begin
                      fade_coeff <= ({6'b0,fade_coeff} * 31) >> 5; 
                      
                      //set music output
                      curr_level_music <= ((({2'b0,level[0]} + level[1] + level[2] + level[3]) >> 2)*({6'b0,fade_coeff})) >> 5;
                 end
                 
                 
                 sil <= 1;
                 note <= 0;
                 //new_f_notes <= 0;
                 if (sil_counter == 0) begin //when sil_counter loops around,
                     note_counter <= 1; //reset values
                     sil_counter <= 1;
                 end
                 else begin //if still counting, increment
                     sil_counter <= sil_counter + 1;
                 end
             end
             else if (music) begin //counting up note_counter
                 note_counter <= note_counter + 1;
                 
                 
                 //music level output
                 //curr_level_music <= (({2'b0,level[0]} + level[1] + level[2] + level[3]) >> 2);
                 
                 curr_level_music <= ((({2'b0,level[0]} + level[1] + level[2] + level[3]) >> 2)*({6'b0,~fade_coeff})) >> 5;
                 
                 if (note_counter[16] == 0 && note_counter[17] > 0) begin
                     fade_coeff <= ({6'b0,fade_coeff} * 31) >> 5;
                     
                     //curr_level_music <= (({2'b0,level[0]} + level[1] + level[2] + level[3]) >> 2);
                     //set music output
                     //curr_level_music <= ((({2'b0,level[0]} + level[1] + level[2] + level[3]) >> 2)*(~fade_coeff)) >> 5;
                 end
                 
                 sil <= 0;
                 note <= 1;
                 
                 if (note_counter == 1) begin //if playing a note
                     fade_coeff <= 5'b11111;
                     
                     
                     
                 end
                 else begin
                     new_f_notes <= 0;
                 end
             end
             else begin //if music is not currently playing, pause everything.
                 note_counter <= 1;
                 sil_counter <= 1;
             end
             
         end*/
         
    end
    
    
endmodule
