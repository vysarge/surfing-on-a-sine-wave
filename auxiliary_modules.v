module clock_quarter_divider(input clk100_mhz, output reg clock_25mhz = 0);
    reg counter = 0;
    
    always @(posedge clk100_mhz) begin
        counter <= counter + 1;
        if (counter == 0) begin
            clock_25mhz <= ~clock_25mhz;
        end
    end
endmodule

//a module to handle delay of signals by a certain number of cycles
// LOG should be log2(CYCLES) rounded up
module pipeliner #(parameter CYCLES=1, parameter LOG=1, parameter WIDTH = 1)
                  (input reset,
                  input clock,
                  input [WIDTH-1:0] in,
                  output reg [WIDTH-1:0] out);
    reg [WIDTH-1:0] buffer [CYCLES-1:0];
    reg [LOG-1:0] i; //pointer to next output
    
    always @(posedge clock) begin
        if (reset) begin //reset
            //clear buffer
            for (i = 0; i < CYCLES; i = i+1) begin
                buffer[i] <= 0;
            end
            
            //reset pointer
            i <= 0;
            
            //reset output
            out <= 0;
            
        end
        
        //otherwise (normal operation)
        else begin
            //shift output out
            out <= buffer[i];
            
            //increment counter
            if (i == CYCLES-1) begin
                i <= 0;
            end
            else begin
                i <= i + 1;
            end
            
            //shift input in
            buffer[i] <= in;
        end
    end
endmodule

module debounce #(parameter DELAY=270000)   // .01 sec with a 27Mhz clock
	        (input reset, clock, noisy,
	         output reg clean);

   reg [18:0] count;
   reg new;

   always @(posedge clock)
     if (reset)
       begin
	  count <= 0;
	  new <= noisy;
	  clean <= noisy;
       end
     else if (noisy != new)
       begin
	  new <= noisy;
	  count <= 0;
       end
     else if (count == DELAY)
       clean <= new;
     else
       count <= count+1;
      
endmodule

module binary_to_bcd #(parameter LOG=3,
                         WIDTH=8,
                         WAIT=0,
                         CALC=1,
                         SHIFT=0,
                         ADD=1)
        (input [WIDTH-1:0] bin,
         input clock,
         output reg [4*LOG-1:0] out=0);
    reg count = 0;
    reg [WIDTH+4*LOG-1:0] calc = 0;
    reg state = WAIT;
    reg int_state = SHIFT;
    integer i = 0;
    wire new_num;
    wire new_pulse;
    reg [WIDTH-1:0] last_num = 0;
    assign new_num = |(last_num ^ bin);
    
    pulse2 new_p (.clock(clock), .signal(new_num),.out(new_pulse));
    always @ (posedge clock) begin
        case(state)
            WAIT: begin
                count <= 0;
                if (new_pulse) begin
                    calc<=bin;
                    state<= CALC;
                    last_num<=bin;
                end
            end
            CALC: begin
                if (new_pulse) begin
                    calc <= bin;
                    last_num <= bin;
                    count<=0;
                end
                else if (count < WIDTH) begin
                    if(int_state==SHIFT) begin
                        calc <= calc << 1;
                        int_state<=ADD;
                    end
                    else if (int_state==ADD) begin
                        for (i=0;i<LOG;i=i+1) begin
                            if (calc[WIDTH+i*4 +: 4] > 4) begin
                                calc[WIDTH+i*4 +: 4]<=calc[WIDTH+i*4 +: 4]+3;
                            end
                        end
                        count <= count+1;
                        int_state<=SHIFT;
                    end
                end
                else begin
                    out<=calc[WIDTH +: 4*LOG];
                    state<=WAIT;
                end
            end
        endcase
    end
endmodule
        
module pulse (input clock, signal,
              output reg out);
    reg state = 0;
    
    always @ (posedge clock) begin
        state<=signal;
        if(out) out <= 0;
        else out <= signal & ~state;
    end
endmodule

module pulse2 (input clock, signal,
              output reg out);
    reg state = 0;
    reg count = 0;
    
    always @ (posedge clock) begin
        state<=signal;
        if(out) begin
            if (count == 0) begin
                count<= count +1;
            end else begin
                out <= 0;
                count<=0;
            end
        end else out <= signal & ~state;
    end
endmodule