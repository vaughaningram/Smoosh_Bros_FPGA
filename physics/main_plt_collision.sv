module main_plt_collision #(
    parameter WIDTH = 0,
    parameter HEIGHT = 0
    )(
    input logic [9:0] x_pos,
    input logic [9:0] y_pos,
    input logic [9:0] next_y,
    output logic touching_platform
);
localparam int PLATFORM_Y = 410;
localparam int PLATFORM_X = 20;
localparam int PLT_WIDTH = 400;

always_comb begin
    touching_platform =
        // character's bottom crossing platform top
        (y_pos + HEIGHT*2 <= PLATFORM_Y) &&      // was above the platform last frame
        (next_y + HEIGHT*2 >= PLATFORM_Y) &&     // will go past the platform top this frame
        (x_pos + WIDTH*2 >= PLATFORM_X) &&
        (x_pos <= PLATFORM_X + PLT_WIDTH);
end


endmodule