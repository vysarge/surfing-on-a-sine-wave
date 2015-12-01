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
