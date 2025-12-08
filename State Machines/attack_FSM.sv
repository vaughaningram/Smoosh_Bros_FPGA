module attack_FSM (
    input  logic clk,
    input  logic frame_tick,

    // Controller inputs
    input  logic btn_A,
    input  logic btn_up,
    input  logic btn_down,
    input  logic btn_left,
    input  logic btn_right,

    // Outputs
    output logic attack_active,
    output attack_state atk_state,
    // output logic [9:0] x_pos,
    // output logic [9:0] y_pos
    output logic A_pressed
);
    // lock animation so we cant attack again
    logic attack_locked;
    logic [7:0] lock_timer;
    // Edge detection for button presses to avoid repeated hits while holding
    logic prev_A;
    logic A_pulse;

    // Sequential Logic
    always_ff @(posedge clk) begin
        if (frame_tick) begin
            prev_A <= btn_A;
            A_pulse <= btn_A && !prev_A;
            // start new attack - inline decode logic
            if (A_pulse && !attack_locked) begin
                A_pressed <= 1;
                // if (btn_up)
                //     curr <= ATK_UP;
                // else if (btn_down)
                //     curr <= ATK_DOWN;
                // else if (btn_left || btn_right)
                //     curr <= ATK_SIDE;
                // else
                atk_state <= NEUTRAL;
                attack_locked <= 1;
                attack_active <= 1;
                lock_timer <= 16;
            end
            if (attack_locked) begin
                A_pressed <= 0;
                if (lock_timer == 0) begin
                    attack_locked <= 0;
                    attack_active <= 0;
                end else lock_timer <= lock_timer - 1;
            end
        end
    end  



endmodule
