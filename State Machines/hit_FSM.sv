module hit_FSM (
    input  logic clk,
    input  logic reset,
    input  logic frame_tick,        // 1 pulse per frame

    // Events
    input  logic got_hit,           // collision system asserts this
    input  logic [5:0] hit_damage_in,

    // Outputs
    output logic hit_stun_active,   // true when in hitstun
    output logic [9:0] damage,      // percent damage
    output logic [1:0] stocks,      // lives left
    output logic respawn_trigger    // 1-cycle pulse to reset position
);
    localparam int MAX_DAMAGE      = 999;
    localparam int HITSTUN_FRAMES  = 20;   // how long you're stunned after a hit
    localparam int START_STOCKS    = 3;

    logic [9:0] damage_r = 0;
    logic [7:0] hitstun_counter_r = 0;
    logic [1:0] stocks_r = START_STOCKS[1:0];
    logic respawn_r = 0;

    assign damage          = damage_r;
    assign hit_stun_active = (hitstun_counter_r != 0);
    assign stocks          = stocks_r;
    assign respawn_trigger = respawn_r;

    always_ff @(posedge clk) begin
        // Default pulse to 0 each cycle unless set
        respawn_r <= 0;

        if (reset) begin
            damage_r          <= 10'd0;
            hitstun_counter_r <= 8'd0;
            stocks_r          <= START_STOCKS[1:0];
        end else begin
            // Timers count down once per frame
            if (frame_tick) begin
                if (hitstun_counter_r != 0)
                    hitstun_counter_r <= hitstun_counter_r - 1;
            end

            // Got hit this frame
            if (got_hit && stocks_r > 0) begin
                // Check if this hit kills
                if (damage_r + hit_damage_in >= 100) begin
                    // DEATH / RESPAWN TRIGGER
                    stocks_r          <= stocks_r - 1;
                    damage_r          <= 0;
                    hitstun_counter_r <= 0;
                    respawn_r         <= 1; // Pulse reset for movement FSM
                end else begin
                    // Normal hit
                    damage_r          <= damage_r + hit_damage_in;
                    hitstun_counter_r <= HITSTUN_FRAMES;
                end
            end
        end
    end

endmodule
