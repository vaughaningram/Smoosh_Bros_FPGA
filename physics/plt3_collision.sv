module plt3_collision #(
    parameter WIDTH = 23,
    parameter HEIGHT = 30
    )(
    input logic [9:0] x_pos,
    input logic [9:0] y_pos,
    input logic [9:0] next_y,
    output logic touching_platform3
);
localparam int PLATFORM_Y = 215;
localparam int PLATFORM_X = 120;
localparam int PLT_WIDTH = 105;

always_comb begin
    touching_platform3 =
        // character's bottom crossing platform top
        (y_pos + HEIGHT*2 <= PLATFORM_Y) &&      // was above the platform last frame
        (next_y + HEIGHT*2 >= PLATFORM_Y) &&     // will go past the platform top this frame
        (x_pos + WIDTH*2 >= PLATFORM_X) &&
        (x_pos <= PLATFORM_X + PLT_WIDTH);
end


endmodule