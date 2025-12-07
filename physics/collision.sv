module collision #(
    parameter W1 = 23, H1 = 30,
    parameter W2 = 30, H2 = 40
)(
    input  logic signed [9:0] x1, y1,
    input  logic signed [9:0] x2, y2,
    input  logic collision,
    input  logic clk, frame_tick,
    output logic signed [9:0] new_x1,
    output logic signed [9:0] new_y1
);

logic signed [10:0] overlap_left;
logic signed [10:0] overlap_right;
logic signed [10:0] overlap_top;
logic signed [10:0] overlap_bottom;

assign overlap_left   = (x1 + W1) - x2;
assign overlap_right  = (x2 + W2) - x1;
assign overlap_top    = (y1 + H1) - y2;
assign overlap_bottom = (y2 + H2) - y1;

logic signed [10:0] resolve_x =
    (overlap_left < overlap_right) ? overlap_left : -overlap_right;

logic signed [10:0] resolve_y =
    (overlap_top < overlap_bottom) ? overlap_top : -overlap_bottom;

logic [10:0] abs_resolve_x;
logic [10:0] abs_resolve_y;

assign abs_resolve_x = (resolve_x < 0) ? -resolve_x : resolve_x;
assign abs_resolve_y = (resolve_y < 0) ? -resolve_y : resolve_y;

always_ff @(posedge clk) begin
    new_x1 <= x1;
    new_y1 <= y1;

    if (frame_tick && collision) begin
        if (abs_resolve_x < abs_resolve_y)
            new_x1 <= x1 - resolve_x;
        else
            new_y1 <= y1 - resolve_y;
    end
end

endmodule
