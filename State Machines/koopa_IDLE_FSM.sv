module koopa_IDLE_FSM (
    input logic clk,
    input logic anim_tick,
    input logic reset,
    output logic [5:0]anim_row,
    output logic [5:0]anim_col
);

logic [4:0] frame_hold;

typedef enum logic [2:0] {S1, S2, S3, S4, S5, S6} anim_state;
anim_state state, next_state;
always_ff @(posedge clk) begin
    if (anim_tick) begin
        if (reset) begin
            state <= S1;
        end else begin
            state <= next_state;
        end
    end
end
// if (frame_hold == 4) begin
//             frame_hold = 0;
             
//         end  else begin
//             frame_hold = frame_hold + 1;            
//         end
always_comb begin
  case(state) 
  S1: begin
    anim_row = 0;
    anim_col = 0;
    next_state = S2;
  end
  S2: begin
    anim_row = 0;
    anim_col = 23;
    next_state = S1;
  end
  default: begin
    anim_col = 0;
    anim_row = 0;
    next_state = S1;
    end
  endcase
end
endmodule