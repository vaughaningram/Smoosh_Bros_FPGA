module vga (
    input  logic clk,
    output logic hsync,
    output logic vsync,
    output logic [9:0] col,  
    output logic [9:0] row,    
    output logic valid      
);

    localparam H_SYNC = 96;
    localparam H_BACKP = 48;
    localparam H_VAREA = 640;
    localparam H_FRONTP = 16;
    localparam H_TOTAL = H_VAREA + H_FRONTP + H_SYNC + H_BACKP;  // 800

    localparam V_SYNC = 2;
    localparam V_BACKP = 33;
    localparam V_VAREA = 480;
    localparam V_FRONTP = 10;
    localparam V_TOTAL = V_VAREA + V_FRONTP + V_SYNC + V_BACKP;  // 525

    // --- Counters ---
    logic [9:0] col_count = 0;
    logic [9:0] row_count = 0;

    // Horizontal counter
    always_ff @(posedge clk) begin
        if (col_count == H_TOTAL - 1) begin
            col_count <= 0;
            if (row_count == V_TOTAL - 1)
                row_count <= 0;
            else
                row_count <= row_count + 1;
        end else begin
            col_count <= col_count + 1;
        end
    end

    assign hsync = ~((col_count >= H_VAREA + H_FRONTP) && (col_count < H_VAREA + H_FRONTP + H_SYNC));

    assign vsync = ~((row_count >= V_VAREA + V_FRONTP) && (row_count < V_VAREA + V_FRONTP + V_SYNC));

    assign valid = (col_count < H_VAREA) && (row_count < V_VAREA);

    assign col = col_count;
    assign row = row_count;

endmodule
