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
             output reg pwm,
             output new_f_notes,
             output reg sil,
             output reg note,
             output reg [NOTE_LENGTH-1:0] note_counter,
             output reg [BITS-1:0] count
    );
    
    //parameters for types of waves
    parameter SIN = 0;
    parameter TRI = 1;
    parameter SQ = 2;
    
    //parameters for chord states
    parameter I = 0;
    parameter I6 = 1;
    
    
    
    reg [BITS-1:0] curr_level; //net current wave level
    //reg [BITS-1:0] count; //current count; resets when it's time for a new pwm period
    
    wire [BITS-1:0] level[5:0];
    
    //reg playing; //currently playing a note (if 0, waiting)
    //reg [NOTE_LENGTH-1:0] note_counter;
    reg [SIL_LENGTH-1:0] sil_counter;
    
    //information about notes
    wire [4:0] freq_diff; //positive difference between notes
    wire [4:0] lower_freq; //lower frequency
    wire [4:0] higher_freq; //higher frequency; empty if only one frequency
    wire two_freq; //1 if two frequencies; 0 if only one
    //wire new_f_notes; //new_f for note audio_wave instances
    reg [4:0] base_freq; //frequency to be used as the 'base' (i/I chord) of the audio output
    reg [4:0] freq[3:0]; //frequencies to be played by the corresponding audio_wave instances
    reg [5:0] state; //chord state
    
    //freq_diff is the positive difference between notes.
    assign freq_diff = (freq_id1 > freq_id2) ? (freq_id1 - freq_id2) : (freq_id2 - freq_id1);
    assign {lower_freq, higher_freq} = (freq_id1 > freq_id2) ? {freq_id2, freq_id1} : {freq_id1, freq_id2};
    assign two_freq = (freq_id2 != 5'b11111);
    
    pipeliner #(.CYCLES(10), .LOG(4), .WIDTH(1)) a0 (.reset(reset), .clock(clock), .in(new_f), .out(new_f_notes));
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
         
         
         
         if (new_f) begin
             casez ({two_freq, freq_diff})
                 6'b0zzzzz: begin //only one frequency
                                base_freq <= (lower_freq < 13) ? lower_freq : (lower_freq - 12);
                                state = I;
                                
                                freq[0] <= base_freq; //root
                                                                      freq[1] <= base_freq + 4; //third
                                                                      freq[2] <= base_freq + 7; //fifth
                                                                      freq[3] <= base_freq + 12; //root
                            end
             endcase
             
             note_counter <= 1;
             sil_counter <= 1;
         end
         
         curr_level <= (music) ? (({2'b0,level[0]} + level[1] + level[2] + level[3]) >> 2) : (({1'b0,level[4]}+level[5])>>1);
         
         //increment count
         count <= count + 1;
         
         //curr_level / count is the volume level after the low pass.
         if (count == curr_level) begin
             pwm <= 0;
             //new_f_notes <= 0;
         end
         if (count == 0) begin
             pwm <= 1;
             
             //counting up sil_counter
             if (music && (note_counter == 0)) begin
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
                 
                 sil <= 0;
                 note <= 1;
                 
                 if (note_counter + 1 == 0) begin //if sil_counter is about to start
                     
                     //calculate new notes
                     case(state)
                         I:       begin //I chord
                                      freq[0] <= base_freq; //root
                                      freq[1] <= base_freq + 4; //third
                                      freq[2] <= base_freq + 7; //fifth
                                      freq[3] <= base_freq + 12; //root
                                      //new_f_notes <= 1;
                                  end
                         
                         default: begin
                                      freq[0] <= base_freq;
                                      freq[1] <= base_freq;
                                      freq[2] <= base_freq;
                                      freq[3] <= base_freq;
                                      //new_f_notes <= 1;
                                  end
                     endcase
                     
                 end
                 else begin
                     //new_f_notes <= 0;
                 end
             end
             else begin //if music is not currently playing, pause everything.
                 note_counter <= 1;
                 sil_counter <= 1;
             end
             
         end
         
    end
    
    
endmodule
