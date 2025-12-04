module attack_FSM (
    input  logic btn_atk,
    input  logic btn_up,
    input  logic btn_down,
    input  logic btn_right,
    input  logic btn_left,
    input  logic hit_stun_active,

    output logic attack_active,
    output logic [3:0] anim_ID
);

    always_comb begin
        // default: no attack
        attack_active = 1'b0;
        anim_ID       = 4'd0;

        if (!hit_stun_active && btn_atk) begin
            attack_active = 1'b1;
            anim_ID       = 4'd6; // IMPLEMENT: generic attack anim for now
        end
    end

endmodule
