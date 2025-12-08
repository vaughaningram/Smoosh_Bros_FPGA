module animation (
    input logic clk,
    input logic anim_tick,
    input logic reset,
    input logic attack_active,
    input attack_state atk_state,
    input movement_state move_anim,
    output logic [10:0] anim_row,
    output logic [10:0] anim_col,
    output logic [5:0] max_width
    // take in a state of some size,
    // output logic anim_frame,
    // output logic x_offset, y_offset (output the offsets in the sprite sheet to top.sv or pattern_gen to draw there)
);
// logic HOLD_TIME  // going to be a mux of sorts that takes in anim_state and current frame #
// HOLD_TIME[anim_state][anim_frame] = count to hold for
// logic anim_frame // the curent frame of the animation we should be animating
// logic hit_box_active // going to be a mux that takes in animation and frame
// hit_box_active[anim_state][anim_frame]


// we want prev_movement state to check if we must reset
movement_state prev_anim_move;
movement_state curr_anim_move;
attack_state prev_atk_move;
attack_state curr_atk_move;
always_ff @(posedge anim_tick) begin
    prev_anim_move <= curr_anim_move;
    curr_anim_move <= move_anim;
    curr_atk_move <= atk_state;
    prev_atk_move <= curr_atk_move;
end

// reset IDLE if prev state does not match
assign idle_reset = (curr_anim_move == IDLE) && (prev_anim_move != IDLE);
// reset WALK if prev state does not match
assign walk_reset = (curr_anim_move == WALK) && (prev_anim_move != WALK);
// reset JUMP if prev state does not match
assign jump_reset = (curr_anim_move == JUMP) && (prev_anim_move != JUMP);
assign atk_neutral_reset = (curr_atk_move == NEUTRAL) && (prev_atk_move != NEUTRAL);
// next_state should be default idle in beginning of program from whatever passes into this animation.sv
always_comb begin
    if (attack_active) begin
        case(curr_atk_move)
        NEUTRAL: begin anim_row = atk_neutral_row; anim_col = atk_neutral_col; max_width = 46;end
        ATK_NONE: begin anim_row = idle_row; anim_col = idle_col; max_width = 46; end
        default: begin anim_row = idle_row; anim_col = idle_col; max_width = 46; end
        endcase
    end else begin
    case(curr_anim_move)
    WALK: begin anim_row = walk_row; anim_col = walk_col; max_width = 46;end
    IDLE: begin anim_row = idle_row; anim_col = idle_col; max_width = 46;end
    JUMP: begin anim_row = jump_fall_row; anim_col = jump_fall_col; max_width =46;end
    default: begin anim_row = idle_row; anim_col = idle_col; max_width = 46; end
    endcase
    end
end


    // if (curr_state == reset_state || next_state != prev_state) begin
    //   anim_frame <= 0;
    //   hit_box <= 0;
    // end else  begin
    // anim_frame <= anim_frame + 1;
    // prev_state <= next_state
    // end
logic idle_reset;
logic [5:0] idle_col;
logic [5:0] idle_row;
koopa_IDLE_FSM u_koopa_IDLE(
    .clk(clk),
    .anim_tick(anim_tick),
    .reset(idle_reset),
    .anim_row(idle_row),
    .anim_col(idle_col)
);

logic walk_reset;
logic [5:0] walk_col;
logic [5:0] walk_row;
koopa_WALK_FSM u_koopa_walk(
    .clk(clk),
    .anim_tick(anim_tick),
    .reset(walk_reset),
    .anim_row(walk_row),
    .anim_col(walk_col)
);

logic jump_reset;
logic [10:0] jump_fall_col;
logic [10:0] jump_fall_row;
koopa_JUMP_FALL_FSM u_koop_jump_fall(
    .clk(clk),
    .anim_tick(anim_tick),
    .reset(jump_reset),
    .anim_row(jump_fall_row),
    .anim_col(jump_fall_col)
);


logic atk_neutral_reset;
logic [10:0] atk_neutral_col;
logic [10:0] atk_neutral_row;
koopa_ATTACK_NEUTRAL_FSM u_koopa_neutral(
    .clk(clk),
    .anim_tick(anim_tick),
    .reset(jump_reset),
    .anim_row(atk_neutral_row),
    .anim_col(atk_neutral_col)
);

// assign hit_box = hit_box_active;


endmodule