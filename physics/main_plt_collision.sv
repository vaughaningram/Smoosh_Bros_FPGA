module main_plt_collision #(
    parameter WIDTH = 0,
    parameter HEIGHT = 0
    )(
    input logic signed [10:0] x_pos,
    input logic signed [10:0] y_pos,
    input logic signed [10:0] next_y,
    output logic touching_platform
);
localparam int PLATFORM_Y = 380;
localparam int PLATFORM_X = 110;
localparam int PLT_WIDTH = 400;
// need larger width to prevent wrapping
// logic signed [10:0] y_bottom;
// logic signed [10:0] next_y_bottom;
always_comb begin
    // y_bottom = y_pos + (HEIGHT*2);
    // next_y_bottom = next_y + (HEIGHT*2);
    touching_platform =
        // character's bottom crossing platform top
        (y_pos + HEIGHT*2 <= PLATFORM_Y) &&      // was above the platform last frame
        (next_y + HEIGHT*2 >= PLATFORM_Y) &&     // will go past the platform top this frame
        (x_pos + WIDTH*2 >= PLATFORM_X) &&
        (x_pos <= PLATFORM_X + PLT_WIDTH);
end


endmodule