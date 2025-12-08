module game_over_text (
    input logic [9:0] x,
    input logic [9:0] y,
    output logic pixel_on
);

    localparam int START_X = 144;
    localparam int START_Y = 200;
    localparam int SCALE = 4; // 8x8 font scaled by 4 -> 32x32 pixels per char
    localparam int SPACING = 8; // distance between chars in pixels (unscaled logic) -> 40px stride

    logic [9:0] rel_x;
    logic [9:0] rel_y;
    
    assign rel_x = x - START_X;
    assign rel_y = y - START_Y;
    
    // Determine which character slot we are in
    // Each char is 32px wide + 8px space = 40px stride
    logic [3:0] char_idx;
    assign char_idx = rel_x / 40;
    
    // Determine coordinate within the character (0-7)
    logic [2:0] cx;
    logic [2:0] cy;
    assign cx = (rel_x % 40) / SCALE; // integer division 
    assign cy = rel_y / SCALE;

    logic [7:0] font_row;

    // Font data: 8x8 bitmap
    // G A M E   O V E R
    // 0 1 2 3 4 5 6 7 8
    
    always_comb begin
        font_row = 8'b0;
        
        // Bounds check
        if (y >= START_Y && y < START_Y + (8 * SCALE) && x >= START_X && x < START_X + (9 * 40)) begin
            
            // Allow for space between chars (char width is 32, stride is 40. so if rel_x % 40 >= 32, it's space)
            if ((rel_x % 40) < 32) begin
                case (char_idx)
                    0: begin // G
                       case(cy)
                        0: font_row = 8'b01111110;
                        1: font_row = 8'b11000011;
                        2: font_row = 8'b11000000;
                        3: font_row = 8'b11000000;
                        4: font_row = 8'b11001111;
                        5: font_row = 8'b11000011;
                        6: font_row = 8'b11000011;
                        7: font_row = 8'b01111110;
                       endcase
                    end
                    1: begin // A
                       case(cy)
                        0: font_row = 8'b00111000;
                        1: font_row = 8'b01101100;
                        2: font_row = 8'b11000110;
                        3: font_row = 8'b11000110;
                        4: font_row = 8'b11111110;
                        5: font_row = 8'b11000110;
                        6: font_row = 8'b11000110;
                        7: font_row = 8'b11000110;
                       endcase
                    end
                    2: begin // M
                       case(cy)
                        0: font_row = 8'b11000011;
                        1: font_row = 8'b11100111;
                        2: font_row = 8'b11111111;
                        3: font_row = 8'b11011011;
                        4: font_row = 8'b11000011;
                        5: font_row = 8'b11000011;
                        6: font_row = 8'b11000011;
                        7: font_row = 8'b11000011;
                       endcase
                    end
                    3: begin // E
                       case(cy)
                        0: font_row = 8'b11111110;
                        1: font_row = 8'b11000000;
                        2: font_row = 8'b11000000;
                        3: font_row = 8'b11111100;
                        4: font_row = 8'b11000000;
                        5: font_row = 8'b11000000;
                        6: font_row = 8'b11000000;
                        7: font_row = 8'b11111110;
                       endcase
                    end
                    // 4 is Space
                    5: begin // O
                       case(cy)
                        0: font_row = 8'b01111110;
                        1: font_row = 8'b11000011;
                        2: font_row = 8'b11000011;
                        3: font_row = 8'b11000011;
                        4: font_row = 8'b11000011;
                        5: font_row = 8'b11000011;
                        6: font_row = 8'b11000011;
                        7: font_row = 8'b01111110;
                       endcase
                    end
                    6: begin // V
                       case(cy)
                        0: font_row = 8'b11000011;
                        1: font_row = 8'b11000011;
                        2: font_row = 8'b11000011;
                        3: font_row = 8'b11000011;
                        4: font_row = 8'b11000011;
                        5: font_row = 8'b01100110;
                        6: font_row = 8'b00111100;
                        7: font_row = 8'b00011000;
                       endcase
                    end
                    7: begin // E
                       case(cy)
                        0: font_row = 8'b11111110;
                        1: font_row = 8'b11000000;
                        2: font_row = 8'b11000000;
                        3: font_row = 8'b11111100;
                        4: font_row = 8'b11000000;
                        5: font_row = 8'b11000000;
                        6: font_row = 8'b11000000;
                        7: font_row = 8'b11111110;
                       endcase
                    end
                    8: begin // R
                       case(cy)
                        0: font_row = 8'b11111100;
                        1: font_row = 8'b11000110;
                        2: font_row = 8'b11000110;
                        3: font_row = 8'b11111100;
                        4: font_row = 8'b11001100;
                        5: font_row = 8'b11000110;
                        6: font_row = 8'b11000110;
                        7: font_row = 8'b11000110;
                       endcase
                    end
                    default: font_row = 8'b0;
                endcase
            end
        end
    end

    // Check if the specific bit is set (indexed from MSB 7 down to 0)
    assign pixel_on = font_row[7 - cx];

endmodule
