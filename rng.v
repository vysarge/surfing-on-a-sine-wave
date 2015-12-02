`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2015 03:46:47 PM
// Design Name: 
// Module Name: rng
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rng
    #(parameter SEED=0,
    TWIST=1,
    WAIT=2,
    GEN=3,
    N=624,
    LG_N = 10,
    W = 32,
    F=32'd1812433253,
    A=32'h9908B0DF,
    M= 397,
    UPPER_MASK = 32'h80000000,
    LOWER_MASK = 32'h7fffffff)
    (input [31:0] seed,
    input clk,
    input new_number,
    output reg [31:0] random=0
    );
    
    reg [1:0] state = SEED;
    reg [W-1:0] mt [N-1:0];
    reg [LG_N-1:0] i = 0;
    reg [W-1:0] x = 0;
    reg [W-1:0] temp = 0;
    reg [1:0] step = 0;
    
    always @ (posedge clk) begin
        case (state) 
            SEED: begin
                if (i == 0)
                    mt[i] <= seed;
                else begin 
                    mt[i] <= (F * (mt[i-1] ^ (mt[i-1] >> (W-2))) + i);
                end
                if (i<623) begin
                    i<=i+1;
                end else begin
                    state <= TWIST;
                    i<=0;
                end
            end
            TWIST: begin
                x <= (mt[i] & UPPER_MASK)
                               + (mt[(i+1<N)?i+1:i+1-N] & LOWER_MASK);
                if (x[0] == 1) begin // lowest bit of x is 1
                    x <= x>>1 ^ A;
                end
                mt[i] <= mt[((i + M)<N) ? i+M : i+M-N] ^ x;
                if (i<623) begin
                    i<=i+1;
                end else begin
                    state <= WAIT;
                    i<=0;
                end
            end
            WAIT: begin
                if(new_number) begin
                    state <= GEN;
                    temp <= mt[i];
                end
            end
            GEN: begin
                case (step)
                    0: begin
                        // Right shift by 11 bits
                        temp <= temp ^ (temp >> 11);
                        step<=step+1;
                    end
                    1: begin
                        //Shift y left by 7 and take the bitwise and of 2636928640
                        temp <= temp ^ ((temp << 7) & 32'h9D2C5680);
                        step<=step+1;
                    end
                    2: begin
                        // Shift y left by 15 and take the bitwise and of y and 4022730752
                        temp <= temp ^ ((temp << 15) & 32'hEFC60000);
                        step<=step+1;
                    end
                    3: begin
                        // Right shift by 18 bits
                        random <= temp ^ (temp >> 18);
                        step<=0;
                        if (i<623) begin
                            i<=i+1;
                            state<=WAIT;
                        end else begin
                            state <= TWIST;
                            i<=0;
                        end
                    end
                endcase
            end
        endcase
    end
endmodule
