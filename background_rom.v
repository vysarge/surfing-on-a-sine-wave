module background_rom #(parameter WIDTH = 1024,
                    parameter HEIGHT = 512)
                   (input [10:0] x,
                   input [9:0] y,
                   output reg [11:0]  pixel);
    
    reg[(WIDTH>>4)*12-1:0] horiz; //a horizontal strip of pixels
    //selects the correct pixel from the horizontal strip
    
    always @(x, horiz) begin
        pixel = horiz >> (12*((WIDTH - x)>>4) - 12);
        //[WIDTH*12-1-x*12:WIDTH*12-13-x*12];
    end
    
    
    //for current y, return the corresponding pixel strip
    always @(y) begin
        case(y[8:4]) 
            8'b00000: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b00001: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b00010: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b00011: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b00100: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b00101: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b00110: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b00111: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b01000: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b01001: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b01010: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b01011: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b01100: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b01101: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b01110: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b01111: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b10000: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_efe_eff_8ce_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_9cd_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b10001: horiz=768'h_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_9bb_fff_acd_8cf_def_eef_fff_fff_def_9cf_7cf_7cf_7cf_7cf_eef_def_fff_ffe_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf_7cf;
			8'b10010: horiz=768'h_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_7cf_7ce_8cf_acd_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_7df_eef_fff_efe_eef_eef_eef_eef_eef_fff_fff_7cf_8cf_7cf_bcd_dee_fff_eef_eef_fff_9de_7ce_8cf_8cf_7cf_8cf_8cf_8cf_8cf_7cf_eff_eff_9de_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf;
			8'b10011: horiz=768'h_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_7cf_7df_eef_def_fff_fff_7cf_8cf_8cf_8cf_8cf_8cf_8cf_7cf_eef_eef_eef_eef_eee_fff_eef_eef_eef_eef_7cf_8cf_8cf_9ce_eef_eef_eef_eef_dee_fff_eef_8cf_8cf_8cf_abc_efe_acd_8cf_eef_eef_fff_fff_cee_8de_8cf_8cf_7cf_8cf_8cf_8cf_8cf;
			8'b10100: horiz=768'h_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8df_bcd_eef_fff_eef_eef_fff_bdf_8df_8cf_8cf_8cf_8cf_8df_eef_eef_eef_eef_fff_fff_fff_eff_eff_eef_eef_adf_8df_8cf_ddf_ddf_def_ddf_ddf_def_cef_8cf_8cf_8df_eef_fff_efe_eef_eef_eef_eef_eef_fff_fff_8cf_8cf_9ce_bef_8df_8cf_8cf;
			8'b10101: horiz=768'h_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_8cf_9df_eef_eef_eef_eef_def_fff_eef_8df_8cf_8cf_8cf_8cf_def_def_eef_eef_eef_eef_fff_eef_eef_def_eef_bef_7df_8cf_8df_acd_8df_8cf_8cf_8cf_8cf_8cf_8cf_8df_eef_eef_eef_eef_eee_fff_eef_eef_eef_eef_bef_8cf_ace_bef_8cf_8cf_8cf;
			8'b10110: horiz=768'h_9df_9df_8df_8cf_9df_acd_9cf_9df_9df_9df_9df_ddf_def_def_def_def_ddf_def_dff_8df_9df_9df_8df_cde_def_cef_def_ddf_ddf_cdf_def_def_ddf_cef_cef_bef_def_eef_fff_fef_ace_8cf_9df_8df_8df_9df_9df_eef_eef_eef_eef_fff_fff_fff_eff_eff_eef_eef_adf_8df_9df_9df_9df_9df;
			8'b10111: horiz=768'h_9df_9df_9df_eef_def_eff_fff_9cf_9df_9df_9df_8cf_9df_9df_eee_def_fff_eef_eef_fff_8df_9df_9df_9df_9df_9df_9df_8df_9df_9df_9df_9df_9df_9df_9df_9ce_eef_fff_eef_eef_dee_eff_ccd_eee_fff_9df_8df_def_def_eef_eef_eef_eef_eff_eef_eef_def_eef_bef_8df_9df_9df_9df_9df;
			8'b11000: horiz=768'h_9df_9df_cce_eee_fff_eef_eef_fff_bdf_9df_9df_9df_9df_9df_def_eef_dde_eef_eef_eef_eff_eef_9df_9df_9df_9df_9df_9df_9df_adf_adf_acf_9df_9df_9df_eef_eef_eef_fef_eef_eef_fff_def_def_def_def_aef_cde_def_ddf_def_ddf_ddf_bdf_def_def_ddf_cef_cef_cef_9df_9df_9df_9df;
			8'b11001: horiz=768'h_9df_adf_eef_eef_eef_eef_eef_def_fff_eef_eef_fff_def_9df_9df_def_def_def_ddf_def_def_eef_fff_9df_9df_9de_9df_9df_9df_9df_9df_9df_9df_9df_9df_cef_def_def_def_ddf_ddf_ddf_dde_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df_9df;
			8'b11010: horiz=768'h_adf_adf_cef_ddf_def_def_ddf_ddf_ddf_ddf_eef_eef_eef_eef_cde_adf_adf_adf_adf_adf_cde_def_eef_eef_cee_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_cef_bef_adf_adf_adf_adf_adf_adf_adf_adf_adf_aef_adf_adf_adf_adf_cde_cde_adf_adf_adf_adf_adf_adf_adf_adf_adf;
			8'b11011: horiz=768'h_adf_adf_adf_adf_cef_bdf_adf_adf_adf_adf_adf_adf_adf_cef_cef_adf_adf_adf_adf_adf_adf_adf_adf_bdf_cef_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_cef_eef_cff_adf_cef_cef_adf_adf_adf_adf_adf_adf_adf_adf_adf;
			8'b11100: horiz=768'h_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf;
			8'b11101: horiz=768'h_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf_adf;
			8'b11110: horiz=768'h_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef_bef;
			8'b11111: horiz=768'h_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf_bdf;


            
            default: horiz = 768'h_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00_F00;
        endcase

    end
    
endmodule

