module hit_FSM (
    input  logic clk,
    input  logic reset,
    input  logic frame_tick,        // 1 pulse per frame

    // Events
    input  logic got_hit,           // collision system asserts this
    input  logic [5:0] hit_damage_in,
    input  logic offscreen,         // player fell off stage

    // From environment
    input  logic grounded,          // (IMPLEMENT: not used yet, but kept for future.)

    // Outputs to top_states
    output logic hit_stun_active,   // true when in hitstun
    output logic can_grab_ledge,    // true unless stunned
    output logic [3:0] hit_anim_id, // which hit animation to show

    // Player stats
    output logic [9:0] damage,      // percent damage
    output logic [1:0] stocks       // lives left
);

    // --------------------
    // Parameters
    // --------------------
    localparam int MAX_DAMAGE      = 999;
    localparam int START_STOCKS    = 3;
    localparam int HITSTUN_FRAMES  = 20;   // how long you're stunned after a hit

    // --------------------
    // Internal registers
    // --------------------
    logic [9:0] damage_r;
    logic [1:0] stocks_r;
    logic [7:0] hitstun_counter_r;
    logic [3:0] hit_anim_r;

    // --------------------
    // Drive outputs
    // --------------------
    assign damage         = damage_r;
    assign stocks         = stocks_r;
    assign hit_anim_id    = hit_anim_r;

    assign hit_stun_active = (hitstun_counter_r != 0);
    assign can_grab_ledge  = !hit_stun_active;  // simple rule for now

    // --------------------
    // Main behavior
    // --------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            damage_r          <= 10'd0;
            stocks_r          <= START_STOCKS[1:0];
            hitstun_counter_r <= 8'd0;
            hit_anim_r        <= 4'd0;   // idle / no-hit
        end else begin
            // Timers count down once per frame
            if (frame_tick) begin
                if (hitstun_counter_r != 0)
                    hitstun_counter_r <= hitstun_counter_r - 1;
            end

            // Got hit this frame (all attacks treated the same)
            if (got_hit && stocks_r != 0) begin
                int unsigned tmp;

                // Increase damage with saturation
                tmp = damage_r + hit_damage_in;   // IMPLEMENT? can be constant for now
                if (tmp > MAX_DAMAGE)
                    tmp = MAX_DAMAGE;
                damage_r <= tmp[9:0];

                // Start hitstun
                hitstun_counter_r <= HITSTUN_FRAMES;

                // Single generic hit animation for now 
                hit_anim_r <= 4'd1;
            end

            // Fell off the stage: lose a stock and reset damage
            if (offscreen && stocks_r != 0) begin
                stocks_r          <= stocks_r - 1;
                damage_r          <= 10'd0;
                hitstun_counter_r <= 8'd0;
                hit_anim_r        <= 4'd0;   // back to idle / respawn anim
            end
        end
    end

endmodule
