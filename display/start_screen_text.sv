module start_screen_text (
    input logic [9:0] x,
    input logic [9:0] y,
    output logic pixel_on
);

    // Scaling constants
    localparam int SCALE_TITLE = 4; // 32x32 per char
    localparam int SCALE_SUB = 2;   // 16x16 per char
    
    // Position constants
    localparam int TITLE_START_X = 120;
    localparam int TITLE_START_Y = 100;
    localparam int TITLE_STRIDE = 40; // 32 + 8 spacing

    localparam int PRESS_START_X = 224;
    localparam int PRESS_START_Y = 250;
    localparam int PRESS_START_STRIDE = 20; // 16 + 4 spacing

    localparam int INSTR_X = 180;
    localparam int INSTR_Y = 320;
    localparam int INSTR_STRIDE = 20;

    logic [7:0] char_code;
    logic [2:0] row_index;
    logic [7:0] font_row;
    logic [2:0] bit_index;
    logic region_active;

    // Relative coordinates
    logic [9:0] rel_x_title, rel_y_title;
    logic [9:0] rel_x_press, rel_y_press;
    logic [9:0] rel_x_instr, rel_y_instr;

    assign rel_x_title = x - TITLE_START_X;
    assign rel_y_title = y - TITLE_START_Y;

    assign rel_x_press = x - PRESS_START_X;
    assign rel_y_press = y - PRESS_START_Y;

    assign rel_x_instr = x - INSTR_X;
    assign rel_y_instr = y - INSTR_Y;

    // 1. Coordinate Logic & Character Mapping
    always_comb begin
        char_code = 8'h00;
        row_index = 0;
        bit_index = 0;
        region_active = 0;

        // TITLE logic "SMOOSH BROS" (S=53, M=4D, O=4F, H=48, B=42, R=52)
        if (y >= TITLE_START_Y && y < TITLE_START_Y + (8 * SCALE_TITLE) &&
            x >= TITLE_START_X && x < TITLE_START_X + (11 * TITLE_STRIDE)) begin
            
            // Check spacing
            if ((rel_x_title % TITLE_STRIDE) < (8 * SCALE_TITLE)) begin
                region_active = 1;
                row_index = rel_y_title / SCALE_TITLE;
                bit_index = (rel_x_title % TITLE_STRIDE) / SCALE_TITLE;
                
                case(rel_x_title / TITLE_STRIDE)
                    0: char_code = "S";
                    1: char_code = "M";
                    2: char_code = "O";
                    3: char_code = "O";
                    4: char_code = "S";
                    5: char_code = "H";
                    // 6 Space
                    7: char_code = "B";
                    8: char_code = "R";
                    9: char_code = "O";
                    10: char_code = "S";
                    default: char_code = 0;
                endcase
            end
        end
        // PRESS START logic "PRESS START" (P=50, R=52, E=45, S=53, T=54, A=41)
        else if (y >= PRESS_START_Y && y < PRESS_START_Y + (8 * SCALE_SUB) &&
                 x >= PRESS_START_X && x < PRESS_START_X + (11 * PRESS_START_STRIDE)) begin
            
             // Check spacing
            if ((rel_x_press % PRESS_START_STRIDE) < (8 * SCALE_SUB)) begin
                region_active = 1;
                row_index = rel_y_press / SCALE_SUB;
                bit_index = (rel_x_press % PRESS_START_STRIDE) / SCALE_SUB;

                case(rel_x_press / PRESS_START_STRIDE)
                    0: char_code = "P";
                    1: char_code = "R";
                    2: char_code = "E";
                    3: char_code = "S";
                    4: char_code = "S";
                    // 5 Space
                    6: char_code = "S";
                    7: char_code = "T";
                    8: char_code = "A";
                    9: char_code = "R";
                    10: char_code = "T";
                    default: char_code = 0;
                endcase
            end
        end
        // INSTRUCTIONS logic "B JUMP A ATTACK" (B=42, J=4A, U=55, M=4D, P=50, A=41, T=54, C=43, K=4B)
        else if (y >= INSTR_Y && y < INSTR_Y + (8 * SCALE_SUB) &&
                 x >= INSTR_X && x < INSTR_X + (16 * INSTR_STRIDE)) begin
            
             // Check spacing
            if ((rel_x_instr % INSTR_STRIDE) < (8 * SCALE_SUB)) begin
                region_active = 1;
                row_index = rel_y_instr / SCALE_SUB;
                bit_index = (rel_x_instr % INSTR_STRIDE) / SCALE_SUB;

                 case(rel_x_instr / INSTR_STRIDE)
                    0: char_code = "B";
                    // 1 Space
                    2: char_code = "J";
                    3: char_code = "U";
                    4: char_code = "M";
                    5: char_code = "P";
                    // 6, 7 Space
                    8: char_code = "A";
                    // 9 Space
                    10: char_code = "A";
                    11: char_code = "T";
                    12: char_code = "T";
                    13: char_code = "A";
                    14: char_code = "C";
                    15: char_code = "K";
                    default: char_code = 0;
                 endcase
            end
        end
    end

    // 2. Font Bitmap Lookup
    always_comb begin
        font_row = 8'b0;
        case(char_code)
            "A": case(row_index)
                3'd0: font_row = 8'b00111000;
                3'd1: font_row = 8'b01101100;
                3'd2: font_row = 8'b11000110;
                3'd3: font_row = 8'b11000110;
                3'd4: font_row = 8'b11111110;
                3'd5: font_row = 8'b11000110;
                3'd6: font_row = 8'b11000110;
                3'd7: font_row = 8'b11000110;
            endcase
            "B": case(row_index)
                3'd0: font_row = 8'b11111100;
                3'd1: font_row = 8'b11000110;
                3'd2: font_row = 8'b11000110;
                3'd3: font_row = 8'b11111100;
                3'd4: font_row = 8'b11000110;
                3'd5: font_row = 8'b11000110;
                3'd6: font_row = 8'b11000110;
                3'd7: font_row = 8'b11111100;
            endcase
            "C": case(row_index)
                3'd0: font_row = 8'b00111100;
                3'd1: font_row = 8'b01100110;
                3'd2: font_row = 8'b11000000;
                3'd3: font_row = 8'b11000000;
                3'd4: font_row = 8'b11000000;
                3'd5: font_row = 8'b11000000;
                3'd6: font_row = 8'b01100110;
                3'd7: font_row = 8'b00111100;
            endcase
            "E": case(row_index)
                3'd0: font_row = 8'b11111110;
                3'd1: font_row = 8'b11000000;
                3'd2: font_row = 8'b11000000;
                3'd3: font_row = 8'b11111100;
                3'd4: font_row = 8'b11000000;
                3'd5: font_row = 8'b11000000;
                3'd6: font_row = 8'b11000000;
                3'd7: font_row = 8'b11111110;
            endcase
            "H": case(row_index)
                 3'd0: font_row = 8'b11000011;
                 3'd1: font_row = 8'b11000011;
                 3'd2: font_row = 8'b11000011;
                 3'd3: font_row = 8'b11111111;
                 3'd4: font_row = 8'b11000011;
                 3'd5: font_row = 8'b11000011;
                 3'd6: font_row = 8'b11000011;
                 3'd7: font_row = 8'b11000011;
            endcase
            "J": case(row_index)
                 3'd0: font_row = 8'b00000111;
                 3'd1: font_row = 8'b00000011;
                 3'd2: font_row = 8'b00000011;
                 3'd3: font_row = 8'b00000011;
                 3'd4: font_row = 8'b00000011;
                 3'd5: font_row = 8'b11000011;
                 3'd6: font_row = 8'b01100011;
                 3'd7: font_row = 8'b00111110;
            endcase
            "K": case(row_index)
                 3'd0: font_row = 8'b11000011;
                 3'd1: font_row = 8'b11000110;
                 3'd2: font_row = 8'b11001100;
                 3'd3: font_row = 8'b11110000;
                 3'd4: font_row = 8'b11110000;
                 3'd5: font_row = 8'b11001100;
                 3'd6: font_row = 8'b11000110;
                 3'd7: font_row = 8'b11000011;
            endcase
            "M": case(row_index)
                 3'd0: font_row = 8'b11000011;
                 3'd1: font_row = 8'b11100111;
                 3'd2: font_row = 8'b11111111;
                 3'd3: font_row = 8'b11011011;
                 3'd4: font_row = 8'b11000011;
                 3'd5: font_row = 8'b11000011;
                 3'd6: font_row = 8'b11000011;
                 3'd7: font_row = 8'b11000011;
            endcase
            "O": case(row_index)
                 3'd0: font_row = 8'b00111100;
                 3'd1: font_row = 8'b01100110;
                 3'd2: font_row = 8'b11000011;
                 3'd3: font_row = 8'b11000011;
                 3'd4: font_row = 8'b11000011;
                 3'd5: font_row = 8'b11000011;
                 3'd6: font_row = 8'b01100110;
                 3'd7: font_row = 8'b00111100;
            endcase
            "P": case(row_index)
                 3'd0: font_row = 8'b11111100;
                 3'd1: font_row = 8'b11000110;
                 3'd2: font_row = 8'b11000110;
                 3'd3: font_row = 8'b11111100;
                 3'd4: font_row = 8'b11000000;
                 3'd5: font_row = 8'b11000000;
                 3'd6: font_row = 8'b11000000;
                 3'd7: font_row = 8'b11000000;
            endcase
            "R": case(row_index)
                 3'd0: font_row = 8'b11111100;
                 3'd1: font_row = 8'b11000110;
                 3'd2: font_row = 8'b11000110;
                 3'd3: font_row = 8'b11111100;
                 3'd4: font_row = 8'b11001100;
                 3'd5: font_row = 8'b11000110;
                 3'd6: font_row = 8'b11000110;
                 3'd7: font_row = 8'b11000110;
            endcase
            "S": case(row_index)
                 3'd0: font_row = 8'b01111110;
                 3'd1: font_row = 8'b11000011;
                 3'd2: font_row = 8'b11000000;
                 3'd3: font_row = 8'b01111110;
                 3'd4: font_row = 8'b00000011;
                 3'd5: font_row = 8'b00000011;
                 3'd6: font_row = 8'b11000011;
                 3'd7: font_row = 8'b01111110;
            endcase
            "T": case(row_index)
                 3'd0: font_row = 8'b11111111;
                 3'd1: font_row = 8'b00011000;
                 3'd2: font_row = 8'b00011000;
                 3'd3: font_row = 8'b00011000;
                 3'd4: font_row = 8'b00011000;
                 3'd5: font_row = 8'b00011000;
                 3'd6: font_row = 8'b00011000;
                 3'd7: font_row = 8'b00011000;
            endcase
            "U": case(row_index)
                 3'd0: font_row = 8'b11000011;
                 3'd1: font_row = 8'b11000011;
                 3'd2: font_row = 8'b11000011;
                 3'd3: font_row = 8'b11000011;
                 3'd4: font_row = 8'b11000011;
                 3'd5: font_row = 8'b11000011;
                 3'd6: font_row = 8'b01100110;
                 3'd7: font_row = 8'b00111100;
            endcase
            
            default: font_row = 8'b0;
        endcase
    end

    // 3. Pixel Selection
    assign pixel_on = region_active && font_row[7 - bit_index];

endmodule
