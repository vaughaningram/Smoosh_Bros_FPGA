module controller (
    output logic latch,
    output logic clock,
    output logic [7:0] LED,
    input logic data
);
    //clock reference from online github repo about fpga clock setup
    logic clk48;
    SB_HFOSC #(
        .CLKHF_DIV("0b00")  // 00=48MHz
    ) osc (
        .CLKHFPU(1'b1), // turn on
        .CLKHFEN(1'b1), // enable
        .CLKHF(clk48),  // output clock pin
        .TRIM0(1'b0), .TRIM1(1'b0), .TRIM2(1'b0), .TRIM3(1'b0), .TRIM4(1'b0),
        .TRIM5(1'b0), .TRIM6(1'b0), .TRIM7(1'b0), .TRIM8(1'b0), .TRIM9(1'b0)
    );

    // 2^20 / 48e6 == 21.8 ms == 45.8 Hz frame rate
    localparam int N = 20; 
    logic [N:0] ctr;
    always_ff @(posedge clk48) ctr <= ctr + 1'b1;

    logic NESclk;
    logic [N-9:0] NEScount;
    assign NESclk = ctr[8];
    assign NEScount = ctr[N:9];

    // latch - 1 NESclk period at start of frame
    assign latch = (NEScount == 0);

    // clock - 8 NESclk pulses after latch
    assign clock = NESclk && (NEScount >= 1) && (NEScount <= 8);

    logic [7:0] shift_reg;
    always_ff @(posedge NESclk) begin
        if (latch) begin
            shift_reg <= 8'b0;
        end else if ((NEScount >= 1) && (NEScount <= 8)) begin
            shift_reg <= {shift_reg[6:0], data};  // puts new bit at LSB
        end
    end

    //copy to a stable holding register after 8 bits
    logic [7:0] buttons;
    always_ff @(posedge NESclk) begin
        if (NEScount == 9) begin
            buttons <= shift_reg;
        end
    end

    // Display buttons on LEDs
    assign LED = ~buttons;

endmodule
