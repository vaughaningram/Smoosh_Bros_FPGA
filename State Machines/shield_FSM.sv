module shield_FSM #(
    parameter int unsigned MAX_SHIELD   = 8'd200, // full shield
    parameter int unsigned DECAY_RATE   = 8'd2,   // per frame while active
    parameter int unsigned REGEN_RATE   = 8'd4    // per frame during cooldown
)(
    input  logic clk,
    input  logic reset,
    input  logic frame_tick,

    input  logic btn_shield,     // activates shield

    output logic shield_active,   // shield currently on
    output logic shield_ready,    // shield can be activated
    output logic [7:0] shield_value
);

    typedef enum logic [1:0] {
        S_IDLE,       // waiting for shield use
        S_ACTIVE,     // shield up, draining
        S_COOLDOWN    // regenerating to full
    } state_t;

    state_t curr, next;

    logic [7:0] val_r, val_n;

    // sequential
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            curr  <= S_IDLE;
            val_r <= MAX_SHIELD;
        end else begin
            if (frame_tick) begin
                curr  <= next;
                val_r <= val_n;
            end
        end
    end

    // combinational
    always_comb begin
        next          = curr;
        val_n         = val_r;

        shield_active = 1'b0;
        shield_ready  = 1'b0;

        case (curr)

            // IDLE
            S_IDLE: begin
                shield_ready = 1'b1;

                // Press → Activate shield
                if (btn_shield)
                    next = S_ACTIVE;
            end

            // ACTIVE
            S_ACTIVE: begin
                shield_active = 1'b1;

                // Decay HP
                if (val_r > DECAY_RATE)
                    val_n = val_r - DECAY_RATE;
                else
                    val_n = 8'd0;

                // If HP hits 0 → cooldown
                if (val_n == 0) begin
                    next = S_COOLDOWN;
                end
                // If player releases the button → still cooldown
                else if (!btn_shield) begin
                    next = S_COOLDOWN;
                end
            end

            // COOLDOWN
            S_COOLDOWN: begin
                // Regenerate
                if (val_r < MAX_SHIELD) begin
                    if (val_r + REGEN_RATE >= MAX_SHIELD)
                        val_n = MAX_SHIELD;
                    else
                        val_n = val_r + REGEN_RATE;
                end

                // Fully regenerated → ready again
                if (val_n == MAX_SHIELD)
                    next = S_IDLE;
            end

        endcase
    end

    assign shield_value = val_r;

endmodule
