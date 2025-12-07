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

    // Attack type encoding (avoiding enum for Yosys compatibility)
    localparam logic [2:0] ATK_NONE    = 3'd0;
    localparam logic [2:0] ATK_NEUTRAL = 3'd1;
    localparam logic [2:0] ATK_SIDE    = 3'd2;
    localparam logic [2:0] ATK_UP      = 3'd3;
    localparam logic [2:0] ATK_DOWN    = 3'd4;

    logic [2:0] curr;
    logic [7:0] timer;

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
                // start new attack - inline decode logic
                if (btn_atk) begin
                    if (btn_up)
                        curr <= ATK_UP;
                    else if (btn_down)
                        curr <= ATK_DOWN;
                    else if (btn_left || btn_right)
                        curr <= ATK_SIDE;
                    else
                        curr <= ATK_NEUTRAL;
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
