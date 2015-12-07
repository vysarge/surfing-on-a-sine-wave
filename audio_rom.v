`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps



module audio_rom #(parameter BITS = 6)
                (input [10:0] index, // horizontal input
                input [4:0] freq_id, // frequency id on a 25-tone midi keyboard, 0 is lowest
                output reg [BITS-1:0] level, // vertical value
                output reg [15:0] freq, // proportional to frequency; adjusted so that freq*period = 2^16
                output reg [15:0] period //output period
                ); 
    
    
    reg [10:0] c_index; //adjusted index
    reg [10:0] value; //vertical value, 11 bits
    
    always @(*) begin
        
        //output absolute value of sine across entire period
        if (index < 256) begin
            c_index = index;
        end
        else if (index < 512) begin
            c_index = 512 - index;
        end
        else if (index < 768) begin
            c_index = index - 512;
        end
        else begin
            c_index = 1024 - index;
        end
        
        //frequency and period values
        case(freq_id)
            
            5'd0: begin freq = 16'd1817; period = 16'd9233; end //A2
            5'd1: begin freq = 16'd1925; period = 16'd8715; end
            5'd2: begin freq = 16'd2040; period = 16'd8226; end
            5'd3: begin freq = 16'd2161; period = 16'd7764; end
            5'd4: begin freq = 16'd2289; period = 16'd7328; end
            5'd5: begin freq = 16'd2426; period = 16'd6917; end
            5'd6: begin freq = 16'd2570; period = 16'd6529; end
            5'd7: begin freq = 16'd2723; period = 16'd6162; end
            5'd8: begin freq = 16'd2884; period = 16'd5816; end
            5'd9: begin freq = 16'd3056; period = 16'd5490; end
            5'd10: begin freq = 16'd3238; period = 16'd5182; end
            5'd11: begin freq = 16'd3430; period = 16'd4891; end
            5'd12: begin freq = 16'd3634; period = 16'd4616; end
            5'd13: begin freq = 16'd3850; period = 16'd4357; end
            5'd14: begin freq = 16'd4079; period = 16'd4113; end
            5'd15: begin freq = 16'd4322; period = 16'd3882; end
            5'd16: begin freq = 16'd4579; period = 16'd3664; end
            5'd17: begin freq = 16'd4851; period = 16'd3458; end
            5'd18: begin freq = 16'd5140; period = 16'd3264; end
            5'd19: begin freq = 16'd5445; period = 16'd3081; end
            5'd20: begin freq = 16'd5769; period = 16'd2908; end
            5'd21: begin freq = 16'd6112; period = 16'd2745; end
            5'd22: begin freq = 16'd6475; period = 16'd2591; end
            5'd23: begin freq = 16'd6860; period = 16'd2445; end
            5'd24: begin freq = 16'd7268; period = 16'd2308; end //A4
            5'd25: begin freq = 16'd7700; period = 16'd2178; end
            5'd26: begin freq = 16'd8158; period = 16'd2056; end
            5'd27: begin freq = 16'd8643; period = 16'd1941; end
            5'd28: begin freq = 16'd9157; period = 16'd1832; end
            5'd29: begin freq = 16'd9702; period = 16'd1729; end
            5'd30: begin freq = 16'd10279; period = 16'd1632; end
            5'd31: begin freq = 16'd0; period = 16'd1; end
            
            default: begin freq = 16'd1817; period = 16'd9233; end
        endcase
        
        
        level <= (value >> 10 - BITS);
        
        //sine values
        case(c_index)
            9'd000: value = 10'd0;
            9'd001: value = 10'd5;
            9'd002: value = 10'd9;
            9'd003: value = 10'd14;
            9'd004: value = 10'd19;
            9'd005: value = 10'd24;
            9'd006: value = 10'd28;
            9'd007: value = 10'd33;
            9'd008: value = 10'd38;
            9'd009: value = 10'd42;

            9'd010: value = 10'd47;
            9'd011: value = 10'd52;
            9'd012: value = 10'd56;
            9'd013: value = 10'd61;
            9'd014: value = 10'd66;
            9'd015: value = 10'd71;
            9'd016: value = 10'd75;
            9'd017: value = 10'd80;
            9'd018: value = 10'd85;
            9'd019: value = 10'd89;
            
            9'd020: value = 10'd94;
            9'd021: value = 10'd99;
            9'd022: value = 10'd103;
            9'd023: value = 10'd108;
            9'd024: value = 10'd113;
            9'd025: value = 10'd117;
            9'd026: value = 10'd122;
            9'd027: value = 10'd127;
            9'd028: value = 10'd131;
            9'd029: value = 10'd136;
            
            9'd030: value = 10'd141;
            9'd031: value = 10'd145;
            9'd032: value = 10'd150;
            9'd033: value = 10'd154;
            9'd034: value = 10'd159;
            9'd035: value = 10'd164;
            9'd036: value = 10'd168;
            9'd037: value = 10'd173;
            9'd038: value = 10'd177;
            9'd039: value = 10'd182;

            9'd040: value = 10'd187;
            9'd041: value = 10'd191;
            9'd042: value = 10'd196;
            9'd043: value = 10'd200;
            9'd044: value = 10'd205;
            9'd045: value = 10'd209;
            9'd046: value = 10'd214;
            9'd047: value = 10'd218;
            9'd048: value = 10'd223;
            9'd049: value = 10'd227;

            9'd050: value = 10'd232;
            9'd051: value = 10'd236;
            9'd052: value = 10'd241;
            9'd053: value = 10'd245;
            9'd054: value = 10'd250;
            9'd055: value = 10'd254;
            9'd056: value = 10'd259;
            9'd057: value = 10'd263;
            9'd058: value = 10'd268;
            9'd059: value = 10'd272;

            9'd060: value = 10'd276;
            9'd061: value = 10'd281;
            9'd062: value = 10'd285;
            9'd063: value = 10'd290;
            9'd064: value = 10'd294;
            9'd065: value = 10'd298;
            9'd066: value = 10'd303;
            9'd067: value = 10'd307;
            9'd068: value = 10'd311;
            9'd069: value = 10'd316;

            9'd070: value = 10'd320;
            9'd071: value = 10'd324;
            9'd072: value = 10'd328;
            9'd073: value = 10'd333;
            9'd074: value = 10'd337;
            9'd075: value = 10'd341;
            9'd076: value = 10'd345;
            9'd077: value = 10'd350;
            9'd078: value = 10'd354;
            9'd079: value = 10'd358;
            
            9'd080: value = 10'd362;
            9'd081: value = 10'd366;
            9'd082: value = 10'd370;
            9'd083: value = 10'd374;
            9'd084: value = 10'd379;
            9'd085: value = 10'd383;
            9'd086: value = 10'd387;
            9'd087: value = 10'd391;
            9'd088: value = 10'd395;
            9'd089: value = 10'd399;
            
            9'd090: value = 10'd403;
            9'd091: value = 10'd407;
            9'd092: value = 10'd411;
            9'd093: value = 10'd415;
            9'd094: value = 10'd419;
            9'd095: value = 10'd423;
            9'd096: value = 10'd427;
            9'd097: value = 10'd431;
            9'd098: value = 10'd434;
            9'd099: value = 10'd438;




            9'd100: value = 10'd442;
            9'd101: value = 10'd446;
            9'd102: value = 10'd450;
            9'd103: value = 10'd454;
            9'd104: value = 10'd457;
            9'd105: value = 10'd461;
            9'd106: value = 10'd465;
            9'd107: value = 10'd469;
            9'd108: value = 10'd472;
            9'd109: value = 10'd476;

            9'd110: value = 10'd480;
            9'd111: value = 10'd484;
            9'd112: value = 10'd487;
            9'd113: value = 10'd491;
            9'd114: value = 10'd494;
            9'd115: value = 10'd498;
            9'd116: value = 10'd502;
            9'd117: value = 10'd505;
            9'd118: value = 10'd509;
            9'd119: value = 10'd512;
            
            9'd120: value = 10'd516;
            9'd121: value = 10'd519;
            9'd122: value = 10'd523;
            9'd123: value = 10'd526;
            9'd124: value = 10'd530;
            9'd125: value = 10'd533;
            9'd126: value = 10'd536;
            9'd127: value = 10'd540;
            9'd128: value = 10'd543;
            9'd129: value = 10'd546;

            9'd130: value = 10'd550;
            9'd131: value = 10'd553;
            9'd132: value = 10'd556;
            9'd133: value = 10'd559;
            9'd134: value = 10'd563;
            9'd135: value = 10'd566;
            9'd136: value = 10'd569;
            9'd137: value = 10'd572;
            9'd138: value = 10'd575;
            9'd139: value = 10'd578;

            9'd140: value = 10'd582;
            9'd141: value = 10'd585;
            9'd142: value = 10'd588;
            9'd143: value = 10'd591;
            9'd144: value = 10'd594;
            9'd145: value = 10'd597;
            9'd146: value = 10'd600;
            9'd147: value = 10'd603;
            9'd148: value = 10'd605;
            9'd149: value = 10'd608;

            9'd150: value = 10'd611;
            9'd151: value = 10'd614;
            9'd152: value = 10'd617;
            9'd153: value = 10'd620;
            9'd154: value = 10'd622;
            9'd155: value = 10'd625;
            9'd156: value = 10'd628;
            9'd157: value = 10'd631;
            9'd158: value = 10'd633;
            9'd159: value = 10'd636;
            
            9'd160: value = 10'd639;
            9'd161: value = 10'd641;
            9'd162: value = 10'd644;
            9'd163: value = 10'd646;
            9'd164: value = 10'd649;
            9'd165: value = 10'd651;
            9'd166: value = 10'd654;
            9'd167: value = 10'd656;
            9'd168: value = 10'd659;
            9'd169: value = 10'd661;

            9'd170: value = 10'd664;
            9'd171: value = 10'd666;
            9'd172: value = 10'd668;
            9'd173: value = 10'd671;
            9'd174: value = 10'd673;
            9'd175: value = 10'd675;
            9'd176: value = 10'd677;
            9'd177: value = 10'd680;
            9'd178: value = 10'd682;
            9'd179: value = 10'd684;
            
            9'd180: value = 10'd686;
            9'd181: value = 10'd688;
            9'd182: value = 10'd690;
            9'd183: value = 10'd692;
            9'd184: value = 10'd694;
            9'd185: value = 10'd696;
            9'd186: value = 10'd698;
            9'd187: value = 10'd700;
            9'd188: value = 10'd702;
            9'd189: value = 10'd704;

            9'd190: value = 10'd706;
            9'd191: value = 10'd708;
            9'd192: value = 10'd710;
            9'd193: value = 10'd711;
            9'd194: value = 10'd713;
            9'd195: value = 10'd715;
            9'd196: value = 10'd717;
            9'd197: value = 10'd718;
            9'd198: value = 10'd720;
            9'd199: value = 10'd722;




            9'd200: value = 10'd723;
            9'd201: value = 10'd725;
            9'd202: value = 10'd726;
            9'd203: value = 10'd728;
            9'd204: value = 10'd729;
            9'd205: value = 10'd731;
            9'd206: value = 10'd732;
            9'd207: value = 10'd734;
            9'd208: value = 10'd735;
            9'd209: value = 10'd736;

            9'd210: value = 10'd738;
            9'd211: value = 10'd739;
            9'd212: value = 10'd740;
            9'd213: value = 10'd741;
            9'd214: value = 10'd743;
            9'd215: value = 10'd744;
            9'd216: value = 10'd745;
            9'd217: value = 10'd746;
            9'd218: value = 10'd747;
            9'd219: value = 10'd748;
           
            9'd220: value = 10'd749;
            9'd221: value = 10'd750;
            9'd222: value = 10'd751;
            9'd223: value = 10'd752;
            9'd224: value = 10'd753;
            9'd225: value = 10'd754;
            9'd226: value = 10'd755;
            9'd227: value = 10'd756;
            9'd228: value = 10'd757;
            9'd229: value = 10'd757;

            9'd230: value = 10'd758;
            9'd231: value = 10'd759;
            9'd232: value = 10'd760;
            9'd233: value = 10'd760;
            9'd234: value = 10'd761;
            9'd235: value = 10'd762;
            9'd236: value = 10'd762;
            9'd237: value = 10'd763;
            9'd238: value = 10'd763;
            9'd239: value = 10'd764;
            
            9'd240: value = 10'd764;
            9'd241: value = 10'd765;
            9'd242: value = 10'd765;
            9'd243: value = 10'd766;
            9'd244: value = 10'd766;
            9'd245: value = 10'd766;
            9'd246: value = 10'd767;
            9'd247: value = 10'd767;
            9'd248: value = 10'd767;
            9'd249: value = 10'd767;

            9'd250: value = 10'd767;
            9'd251: value = 10'd768;
            9'd252: value = 10'd768;
            9'd253: value = 10'd768;
            9'd254: value = 10'd768;
            9'd255: value = 10'd768;
            9'd256: value = 10'd768;
            9'd257: value = 10'd768;
            9'd258: value = 10'd768;
            9'd259: value = 10'd768;
            9'd260: value = 10'd768;
            
            11'b11111111111: value = 10'd0;
            
            default: value = 10'b0;
        endcase

    end
    
    
endmodule
