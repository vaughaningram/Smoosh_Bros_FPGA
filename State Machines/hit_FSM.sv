module hit_FSM (
    input  logic clk,
    input  logic reset,
    input  logic frame_tick,

    input  logic got_hit,
    input  logic [5:0] hit_damage_in,

    output logic hit_stun_active,   // true when in hitstun
    output logic [9:0] damage
);

    localparam int MAX_DAMAGE      = 999;
    localparam int HITSTUN_FRAMES  = 20;   // how long you're stunned after a hit

    logic [9:0] damage_r;
    logic [7:0] hitstun_counter_r;

    assign damage          = damage_r;
    assign hit_stun_active = (hitstun_counter_r != 0);

    always_ff @(posedge clk) begin
        if (reset) begin
            damage_r          <= 10'd0;
            hitstun_counter_r <= 8'd0;
        end else begin
            // Timers count down once per frame
            if (frame_tick) begin
                if (hitstun_counter_r != 0)
                    hitstun_counter_r <= hitstun_counter_r - 1;
            end

            // Got hit this frame
            if (got_hit) begin
                // Increase damage with saturation using simple logic
                if (damage_r + hit_damage_in > MAX_DAMAGE)
                    damage_r <= 10'd999;
                else
                    damage_r <= damage_r + hit_damage_in;

                // Start hitstun
                hitstun_counter_r <= HITSTUN_FRAMES;
            end
        end
    end
endmodule
