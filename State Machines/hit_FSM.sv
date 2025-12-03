module hit_FSM (
    input  logic clk,
    input  logic reset,
    input  logic frame_tick,        // 1 pulse per frame

    // Events
    input  logic got_hit,           // collision system asserts this
    input  logic [5:0] hit_damage_in,
    input  logic offscreen,         // player fell off stage

    // Info from environment
    input  logic grounded,

    // Outputs to top_states
    output logic hit_stun_active,   // true when in hitstun
    output logic can_grab_ledge,    // true unless stunned or invincible
    output logic [3:0] hit_anim_id, // which hit animation to show

    // Player stats
    output logic [9:0] damage,      // percent damage
    output logic [1:0] stocks        // lives left
);

endmodule
