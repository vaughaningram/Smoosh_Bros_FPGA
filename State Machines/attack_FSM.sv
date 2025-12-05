module attack_FSM (
    input  logic clk,
    input  logic reset,
    input  logic frame_tick,

    // Controller inputs
    input  logic btn_atk,
    input  logic btn_up,
    input  logic btn_down,
    input  logic btn_left,
    input  logic btn_right,

    // From hit FSM
    input  logic hit_stun_active,

    // Outputs
    output logic attack_active,
    output logic [3:0] anim_state
);

    localparam int ATTACK_FRAMES = 10;

    typedef enum logic [2:0] {
        ATK_NONE,
        ATK_NEUTRAL,
        ATK_SIDE,
        ATK_UP,
        ATK_DOWN
    } attack_type_t;

    attack_type_t curr, next;
    logic [7:0] timer;

    // Determine direction type of attack
    // function attack_type_t decode_attack(
    //     input logic up, down, left, right
    // );
    //     if (up)       return ATK_UP;
    //     if (down)     return ATK_DOWN;
    //     if (left||right) return ATK_SIDE;
    //     return ATK_NEUTRAL;
    // endfunction


    // Sequential Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            curr  <= ATK_NONE;
            timer <= 0;
        end else if (frame_tick) begin

            // if stunned, cancel attack
            if (hit_stun_active) begin
                curr  <= ATK_NONE;
                timer <= 0;
            end

            // if currently attacking
            else if (timer != 0) begin
                timer <= timer - 1;

                if (timer == 1)
                    curr <= ATK_NONE;

            end else begin
                // start new attack
                if (btn_atk) begin
                    curr  <= decode_attack(btn_up, btn_down, btn_left, btn_right);
                    timer <= ATTACK_FRAMES;
                end
            end
        end
    end


    // Output logic
    assign attack_active = (curr != ATK_NONE);

    always_comb begin
        case (curr)
            ATK_NEUTRAL: anim_state = 4'd6; // neutral animation row
            ATK_SIDE:    anim_state = 4'd7;
            ATK_UP:      anim_state = 4'd8;
            ATK_DOWN:    anim_state = 4'd9;
            default:     anim_state = 4'd0; // idle
        endcase
    end

endmodule
