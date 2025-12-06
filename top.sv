module top (
  input logic clk_in,
  output logic hsync,
  output logic vsync,
  output logic [5:0] rgb,
  output logic latch1,
  output logic latch2,
  output logic ctrl_clk1,
  output logic ctrl_clk2,
  input logic data1,
  input logic data2
);
  

logic valid;
logic [9:0] col;
logic [9:0] next_col;
logic [9:0] row;
logic [9:0] next_row;



logic clk_out;

    // character rgb from ROM
    logic [5:0] char_rgb1;
    logic [5:0] next_char_rgb1;
    logic inside_char_tile1;
    logic [5:0] char_rgb2;
    logic [5:0] next_char_rgb2;
    logic inside_char_tile2;
    logic [5:0] char_rgb;
    logic [5:0] next_char_rgb;
    logic inside_char_tile;

    logic [5:0] plt_rgb;
    logic [5:0] next_plt_rgb;
    logic inside_plt_tile;
    // tile from ROM
    logic [5:0] tile_rgb;
    logic [5:0] next_tile_rgb;
    // final rgb value to pass to VGA
    logic [5:0] final_rgb;
    logic [5:0] next_final_rgb;

    // character position for top left pixel
    logic [9:0] char_x1;
    logic [9:0] char_y1;
    logic [9:0] anim_row1 = 0;
    logic [9:0] anim_col1 = 0;
    logic [9:0] char_x2;
    logic [9:0] char_y2;
    logic [9:0] anim_row2 = 0;
    logic [9:0] anim_col2 = 0;

    logic facing_right1;
    logic facing_right2;
    logic [9:0] plt_x = 20;
    logic [9:0] plt_y = 410;

    // frame refresh
    logic frame_rate;

    // ROM address
    logic [16:0] back_addr;
    logic [16:0] next_back_addr;
    logic [13:0] char_addr1;
    logic [13:0] next_char_addr1;
    logic [13:0] char_addr2;
    logic [13:0] next_char_addr2;
    logic [13:0] char_addr;
    logic [13:0] next_char_addr;
    logic [9:0] plt_addr;
    logic [9:0] next_plt_addr;


  mypll u_mypll (
    .clock_in(clk_in),
    .clock_out(clk_out)
  );

  vga u_vga (
    .clk(clk_out),
    .hsync(hsync),
    .vsync(vsync),
    .col(next_col),  
    .row(next_row),    
    .valid(valid),
    .frame_tick(frame_rate)
  );

    localparam int TILE_SIZE = 8;
    localparam int TILES_X = 640 / TILE_SIZE;  // = 80

    logic [6:0]   tile_x;
    logic [6:0]   tile_y;
    // Determine which tile this pixel belongs to
    assign tile_x = col[9:3];   // col / 8
    assign tile_y = row[9:3];   // row / 8
    assign next_back_addr = tile_y * TILES_X + tile_x;

    logic inside_char_tile_next1;
    logic inside_char_tile_next_next1;
    logic inside_char_tile_next2;
    logic inside_char_tile_next_next2;

    logic inside_plt_tile_next;
    logic inside_plt_tile_next_next;

    
    always_comb begin
      // PLAYER 1 LOGIC
      inside_char_tile_next1 = (col >= char_x1 && col < char_x1 + 23*2  
                          && row >= char_y1 && row < char_y1 + 30*2);
      next_char_addr1 = inside_char_tile_next1 ?  facing_right1 ? ((((row - char_y1)>>1) + anim_row1 )* 69) + (69 - 1) - (((col - char_x1)>>1) + anim_col1):
                                                               ((((row - char_y1)>>1) + anim_row1 )* 69) + (((col - char_x1)>>1) + anim_col1)
                                          : 0;
      //PLAYER 2
      inside_char_tile_next2 = (col >= char_x2 && col < char_x2 + 30*2  
                          && row >= char_y2 && row < char_y2 + 40*2);
      next_char_addr2 = inside_char_tile_next2 ?  ~facing_right2 ? ((((row - char_y2)>>1))* 30) + (30 - 1) - (((col - char_x2)>>1)):
                                                               ((((row - char_y2)>>1))* 30) + (((col - char_x2)>>1))
                                          : 0;
      // platform drawing
      inside_plt_tile_next = (col >= plt_x && col < plt_x + 400 && row >= plt_y && row < plt_y + 9);
      next_plt_addr = inside_plt_tile_next ? (((row - plt_y))* 100) + (((col - plt_x))): 0;

      if (inside_char_tile1 && char_rgb1 != 6'b110011) begin
        next_final_rgb = char_rgb1;
      end else if (inside_char_tile2 && char_rgb2 != 6'b110011) begin
        next_final_rgb = char_rgb2;
      end else if (inside_plt_tile) begin 
        next_final_rgb = plt_rgb;
      end else begin
        next_final_rgb = tile_rgb;
      end

    end

    logic [23:0] counter;
    logic [5:0] d_rgb;

    always_ff @(posedge clk_out) begin
      counter <= counter + 1;
      row <= next_row;
      col <= next_col;
      char_rgb1 <= next_char_rgb1;
      char_addr1 <= next_char_addr1;
      char_rgb2 <= next_char_rgb2;
      char_addr2 <= next_char_addr2;
      inside_char_tile_next_next1 <= inside_char_tile_next1;
      inside_char_tile1 <= inside_char_tile_next_next1; // must delay cycle twice because rom is slow
      inside_char_tile_next_next2 <= inside_char_tile_next2;
      inside_char_tile2 <= inside_char_tile_next_next2; // must delay cycle twice because rom is slow
      

      plt_rgb <= next_plt_rgb;
      plt_addr <= next_plt_addr;

      inside_plt_tile_next_next <= inside_plt_tile_next;
      inside_plt_tile <= inside_plt_tile_next_next;

      back_addr <= next_back_addr;
      final_rgb <= next_final_rgb;
      tile_rgb <= next_tile_rgb;
    end


    typedef enum logic [2:0] {S1, S2, S3, S4, S5, S6} anim_state;
    anim_state state, next_state;
    always_ff @(posedge counter[21]) begin
      state <= next_state;
    end

  logic [7:0] buttons1;
  logic button_up1, button_down1, button_left1, button_right1;
  logic button_select1, button_start1, button_B1, button_A1;
  logic [7:0] LED;
  logic [7:0] buttons2;
  logic button_up2, button_down2, button_left2, button_right2;
  logic button_select2, button_start2, button_B2, button_A2;

movement_FSM #(
  .WIDTH(30),
  .HEIGHT(40),
  .INITIAL_X(375),
  .INITIAL_Y(300)
) player2_movement (
  .run_timer(counter[16]),
  .clk(clk_out),
  .frame_rate(frame_rate),
  .button_up(button_up2),
  .button_down(button_down2),
  .button_left(button_left2),
  .button_right(button_right2),
  .x_pos(char_x2),
  .y_pos(char_y2),
  .facing_right(facing_right2)
);

    movement_FSM #(
      .WIDTH(23),
      .HEIGHT(30),
      .INITIAL_X(50),
      .INITIAL_Y(290)
    ) player1_movement (
      .run_timer(counter[16]),
      .clk(clk_out),
      .frame_rate(frame_rate),
      .button_up(button_up1),
      .button_down(button_down1),
      .button_left(button_left1),
      .button_right(button_right1),
      .x_pos(char_x1),
      .y_pos(char_y1),
      .facing_right(facing_right1)
    );

  
    always_comb begin
      case(state) 
      S1: begin
        anim_row1 = 0;
        anim_col1 = 0;
        next_state = S2;
      end
      S2: begin
        anim_row1 = 0;
        anim_col1 = 23;
        next_state = S3;
      end
      S3: begin
        anim_row1 = 0;
        anim_col1 = 46;
        next_state = S4;
      end
      S4: begin
        anim_row1 = 30;
        anim_col1 = 0;
        next_state = S5;
      end
      S5: begin
        anim_row1 = 30;
        anim_col1 = 23;
        next_state = S6;
      end
      S6: begin
        anim_row1 = 30;
        anim_col1 = 46;
        next_state = S1;
      end
      default: begin
        anim_col1 = 0;
        anim_row1 = 0;
        next_state = S1;
        end
      endcase
    end

  controller u_controller1 (
      .latch(latch1),
      .clock(ctrl_clk1),
      .LED(LED),
      .buttons(buttons1),
      .button_up(button_up1),
      .button_down(button_down1),
      .button_left(button_left1),
      .button_right(button_right1),
      .button_select(button_select1),
      .button_start(button_start1),
      .button_B(button_B1),
      .button_A(button_A1),
      .data(data1),
      .clk(clk_in)
    );

  controller u_controller2 (
      .latch(latch2),
      .clock(ctrl_clk2),
      .LED(LED),
      .buttons(buttons2),
      .button_up(button_up2),
      .button_down(button_down2),
      .button_left(button_left2),
      .button_right(button_right2),
      .button_select(button_select2),
      .button_start(button_start2),
      .button_B(button_B2),
      .button_A(button_A2),
      .data(data2),
      .clk(clk_in)
    );

    ROM_koopa u_koopa_rom (
      .clk(clk_out),
      .addr(char_addr1),
      .rgb(next_char_rgb1)
    );

    ROM_marco u_marco_rom (
      .clk(clk_out),
      .addr(char_addr2),
      .rgb(next_char_rgb2)
    );

    ROM_platform u_platform_rom (
      .clk(clk_out),
      .addr(plt_addr),
      .rgb(next_plt_rgb)
    );

    // ROM instance
    ROM_Screen u_rom (
        .clk(clk_out),
        .addr(back_addr),
        .data(next_tile_rgb)
    );

  pattern_gen u_pattern_gen (
    .valid(valid),
    .col(col),  
    .row(row),
    .tile(final_rgb),    
    .rgb(rgb)     
  );




endmodule

