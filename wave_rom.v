`timescale 1ns / 1ps



module wave_rom(input [10:0] index, // horizontal input to sine function
                input [4:0] freq_id, // frequency id on a 25-tone midi keyboard, 0 is lowest
                output reg [9:0] value, // 768*sin(index*pi/256)
                output reg [10:0] freq); // scaled output frequency
    
    //frequency matching
    always @(freq_id) begin
        case(freq_id)
            
            5'd0: freq = 11'd256;
            5'd1: freq = 11'd271;
            5'd2: freq = 11'd287;
            5'd3: freq = 11'd304;
            5'd4: freq = 11'd323;
            5'd5: freq = 11'd342;
            5'd6: freq = 11'd362;
            5'd7: freq = 11'd384;
            5'd8: freq = 11'd406;
            5'd9: freq = 11'd431;
            5'd10: freq = 11'd456;
            5'd11: freq = 11'd483;
            5'd12: freq = 11'd512;
            5'd13: freq = 11'd542;
            5'd14: freq = 11'd575;
            5'd15: freq = 11'd609;
            5'd16: freq = 11'd645;
            5'd17: freq = 11'd683;
            5'd18: freq = 11'd724;
            5'd19: freq = 11'd767;
            5'd20: freq = 11'd813;
            5'd21: freq = 11'd861;
            5'd22: freq = 11'd912;
            5'd23: freq = 11'd967;
            5'd24: freq = 11'd1024;
            
            default: freq = 0;
        endcase
    end
    
    reg [8:0] c_index; //adjusted index
    //output absolute value of sine across entire period
    always @(index) begin
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
    end
    
    
    //sine values
    always @(c_index) begin
        case(c_index)
            8'd000: value = 10'd0;
            8'd001: value = 10'd5;
            8'd002: value = 10'd9;
            8'd003: value = 10'd14;
            8'd004: value = 10'd19;
            8'd005: value = 10'd24;
            8'd006: value = 10'd28;
            8'd007: value = 10'd33;
            8'd008: value = 10'd38;
            8'd009: value = 10'd42;

            8'd010: value = 10'd47;
            8'd011: value = 10'd52;
            8'd012: value = 10'd56;
            8'd013: value = 10'd61;
            8'd014: value = 10'd66;
            8'd015: value = 10'd71;
            8'd016: value = 10'd75;
            8'd017: value = 10'd80;
            8'd018: value = 10'd85;
            8'd019: value = 10'd89;
            
            8'd020: value = 10'd94;
            8'd021: value = 10'd99;
            8'd022: value = 10'd103;
            8'd023: value = 10'd108;
            8'd024: value = 10'd113;
            8'd025: value = 10'd117;
            8'd026: value = 10'd122;
            8'd027: value = 10'd127;
            8'd028: value = 10'd131;
            8'd029: value = 10'd136;

            8'd030: value = 10'd141;
            8'd031: value = 10'd145;
            8'd032: value = 10'd150;
            8'd033: value = 10'd154;
            8'd034: value = 10'd159;
            8'd035: value = 10'd164;
            8'd036: value = 10'd168;
            8'd037: value = 10'd173;
            8'd038: value = 10'd177;
            8'd039: value = 10'd182;

            8'd040: value = 10'd187;
            8'd041: value = 10'd191;
            8'd042: value = 10'd196;
            8'd043: value = 10'd200;
            8'd044: value = 10'd205;
            8'd045: value = 10'd209;
            8'd046: value = 10'd214;
            8'd047: value = 10'd218;
            8'd048: value = 10'd223;
            8'd049: value = 10'd227;

            8'd050: value = 10'd232;
            8'd051: value = 10'd236;
            8'd052: value = 10'd241;
            8'd053: value = 10'd245;
            8'd054: value = 10'd250;
            8'd055: value = 10'd254;
            8'd056: value = 10'd259;
            8'd057: value = 10'd263;
            8'd058: value = 10'd268;
            8'd059: value = 10'd272;

            8'd060: value = 10'd276;
            8'd061: value = 10'd281;
            8'd062: value = 10'd285;
            8'd063: value = 10'd290;
            8'd064: value = 10'd294;
            8'd065: value = 10'd298;
            8'd066: value = 10'd303;
            8'd067: value = 10'd307;
            8'd068: value = 10'd311;
            8'd069: value = 10'd316;

            8'd070: value = 10'd320;
            8'd071: value = 10'd324;
            8'd072: value = 10'd328;
            8'd073: value = 10'd333;
            8'd074: value = 10'd337;
            8'd075: value = 10'd341;
            8'd076: value = 10'd345;
            8'd077: value = 10'd350;
            8'd078: value = 10'd354;
            8'd079: value = 10'd358;

            8'd080: value = 10'd362;
            8'd081: value = 10'd366;
            8'd082: value = 10'd370;
            8'd083: value = 10'd374;
            8'd084: value = 10'd379;
            8'd085: value = 10'd383;
            8'd086: value = 10'd387;
            8'd087: value = 10'd391;
            8'd088: value = 10'd395;
            8'd089: value = 10'd399;

            8'd090: value = 10'd403;
            8'd091: value = 10'd407;
            8'd092: value = 10'd411;
            8'd093: value = 10'd415;
            8'd094: value = 10'd419;
            8'd095: value = 10'd423;
            8'd096: value = 10'd427;
            8'd097: value = 10'd431;
            8'd098: value = 10'd434;
            8'd099: value = 10'd438;




            8'd100: value = 10'd442;
            8'd101: value = 10'd446;
            8'd102: value = 10'd450;
            8'd103: value = 10'd454;
            8'd104: value = 10'd457;
            8'd105: value = 10'd461;
            8'd106: value = 10'd465;
            8'd107: value = 10'd469;
            8'd108: value = 10'd472;
            8'd109: value = 10'd476;

            8'd110: value = 10'd480;
            8'd111: value = 10'd484;
            8'd112: value = 10'd487;
            8'd113: value = 10'd491;
            8'd114: value = 10'd494;
            8'd115: value = 10'd498;
            8'd116: value = 10'd502;
            8'd117: value = 10'd505;
            8'd118: value = 10'd509;
            8'd119: value = 10'd512;
            
            8'd120: value = 10'd516;
            8'd121: value = 10'd519;
            8'd122: value = 10'd523;
            8'd123: value = 10'd526;
            8'd124: value = 10'd530;
            8'd125: value = 10'd533;
            8'd126: value = 10'd536;
            8'd127: value = 10'd540;
            8'd128: value = 10'd543;
            8'd129: value = 10'd546;

            8'd130: value = 10'd550;
            8'd131: value = 10'd553;
            8'd132: value = 10'd556;
            8'd133: value = 10'd559;
            8'd134: value = 10'd563;
            8'd135: value = 10'd566;
            8'd136: value = 10'd569;
            8'd137: value = 10'd572;
            8'd138: value = 10'd575;
            8'd139: value = 10'd578;

            8'd140: value = 10'd582;
            8'd141: value = 10'd585;
            8'd142: value = 10'd588;
            8'd143: value = 10'd591;
            8'd144: value = 10'd594;
            8'd145: value = 10'd597;
            8'd146: value = 10'd600;
            8'd147: value = 10'd603;
            8'd148: value = 10'd605;
            8'd149: value = 10'd608;

            8'd150: value = 10'd611;
            8'd151: value = 10'd614;
            8'd152: value = 10'd617;
            8'd153: value = 10'd620;
            8'd154: value = 10'd622;
            8'd155: value = 10'd625;
            8'd156: value = 10'd628;
            8'd157: value = 10'd631;
            8'd158: value = 10'd633;
            8'd159: value = 10'd636;
            
            8'd160: value = 10'd639;
            8'd161: value = 10'd641;
            8'd162: value = 10'd644;
            8'd163: value = 10'd646;
            8'd164: value = 10'd649;
            8'd165: value = 10'd651;
            8'd166: value = 10'd654;
            8'd167: value = 10'd656;
            8'd168: value = 10'd659;
            8'd169: value = 10'd661;

            8'd170: value = 10'd664;
            8'd171: value = 10'd666;
            8'd172: value = 10'd668;
            8'd173: value = 10'd671;
            8'd174: value = 10'd673;
            8'd175: value = 10'd675;
            8'd176: value = 10'd677;
            8'd177: value = 10'd680;
            8'd178: value = 10'd682;
            8'd179: value = 10'd684;

            8'd180: value = 10'd686;
            8'd181: value = 10'd688;
            8'd182: value = 10'd690;
            8'd183: value = 10'd692;
            8'd184: value = 10'd694;
            8'd185: value = 10'd696;
            8'd186: value = 10'd698;
            8'd187: value = 10'd700;
            8'd188: value = 10'd702;
            8'd189: value = 10'd704;

            8'd190: value = 10'd706;
            8'd191: value = 10'd708;
            8'd192: value = 10'd710;
            8'd193: value = 10'd711;
            8'd194: value = 10'd713;
            8'd195: value = 10'd715;
            8'd196: value = 10'd717;
            8'd197: value = 10'd718;
            8'd198: value = 10'd720;
            8'd199: value = 10'd722;




            8'd200: value = 10'd723;
            8'd201: value = 10'd725;
            8'd202: value = 10'd726;
            8'd203: value = 10'd728;
            8'd204: value = 10'd729;
            8'd205: value = 10'd731;
            8'd206: value = 10'd732;
            8'd207: value = 10'd734;
            8'd208: value = 10'd735;
            8'd209: value = 10'd736;

            8'd210: value = 10'd738;
            8'd211: value = 10'd739;
            8'd212: value = 10'd740;
            8'd213: value = 10'd741;
            8'd214: value = 10'd743;
            8'd215: value = 10'd744;
            8'd216: value = 10'd745;
            8'd217: value = 10'd746;
            8'd218: value = 10'd747;
            8'd219: value = 10'd748;
           
            8'd220: value = 10'd749;
            8'd221: value = 10'd750;
            8'd222: value = 10'd751;
            8'd223: value = 10'd752;
            8'd224: value = 10'd753;
            8'd225: value = 10'd754;
            8'd226: value = 10'd755;
            8'd227: value = 10'd756;
            8'd228: value = 10'd757;
            8'd229: value = 10'd757;

            8'd230: value = 10'd758;
            8'd231: value = 10'd759;
            8'd232: value = 10'd760;
            8'd233: value = 10'd760;
            8'd234: value = 10'd761;
            8'd235: value = 10'd762;
            8'd236: value = 10'd762;
            8'd237: value = 10'd763;
            8'd238: value = 10'd763;
            8'd239: value = 10'd764;

            8'd240: value = 10'd764;
            8'd241: value = 10'd765;
            8'd242: value = 10'd765;
            8'd243: value = 10'd766;
            8'd244: value = 10'd766;
            8'd245: value = 10'd766;
            8'd246: value = 10'd767;
            8'd247: value = 10'd767;
            8'd248: value = 10'd767;
            8'd249: value = 10'd767;

            8'd250: value = 10'd767;
            8'd251: value = 10'd768;
            8'd252: value = 10'd768;
            8'd253: value = 10'd768;
            8'd254: value = 10'd768;
            8'd255: value = 10'd768;


            
            default: value = 10'd768;
        endcase
    end
endmodule
