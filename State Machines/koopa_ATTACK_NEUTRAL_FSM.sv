module koopa_ATTACK_NEUTRAL_FSM (
    input  logic clk,
    input  logic anim_tick,
    input  logic reset,
    output logic [10:0] anim_row,
    output logic [10:0] anim_col
);

typedef enum logic [1:0] {S1, S2, S3} anim_state;
anim_state state, next_state;

logic [4:0] frame_hold;
logic [4:0] hold_target;

always_ff @(posedge clk) begin
    if (reset) begin
        state      <= S1;
    end else if (anim_tick) begin
        state <= next_state;
    end
end

always_comb begin
    case (state)
        S1: begin
            anim_row    = 90;
            anim_col    = 23;
            next_state  = S2;
        end
        S2: begin
            anim_row    = 120;
            anim_col    = 0;
            next_state  = S3;
        end
        S3: begin
            anim_row    = 120;
            anim_col    = 23;
            next_state  = S3;
        end
        default: begin
            anim_row    = 90;
            anim_col    = 23;
            next_state  = S1;
        end
    endcase
end

endmodule
