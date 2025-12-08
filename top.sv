typedef enum logic [3:0] {
    IDLE,
    WALK,
    RUN,
    JUMP,
    CROUCH,
    FALL
} movement_state;
typedef enum logic [3:0] {
    ATK_NONE,
    NEUTRAL,
    UP_ATK,
    FOWARD_ATK
} attack_state;

typedef enum logic [1:0] {
    STATE_START_SCREEN,
    STATE_PLAYING,
    STATE_GAME_OVER
} game_state_t;

module top (
  input logic clk_in,
  output logic debug_collision,
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

assign debug_collision = player1_hit;

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
    logic [5:0] koopa_max_width_1;
    logic [5:0] koopa_max_width_2;
    logic [10:0] char_x1;
    logic [10:0] char_y1;
    logic [10:0] anim_row1;
    logic [10:0] anim_col1;
    logic [10:0] char_x2;
    logic [10:0] char_y2;
    logic [10:0] anim_row2;
    logic [10:0] anim_col2;

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

    logic player1_hit;
    logic player2_hit;

    // simple AABB collision
    assign player1_hit =
        (char_x1 < char_x2 + 60) &&
        (char_x1 + 46 > char_x2) &&
        (char_y1 < char_y2 + 80) &&
        (char_y1 + 60 > char_y2);

    assign player2_hit = player1_hit;   // same check for both players
    
    always_comb begin
      // PLAYER 1 LOGIC
      inside_char_tile_next1 = (col >= char_x1 && col < char_x1 + 23*2  
                          && row >= char_y1 && row < char_y1 + 30*2);
      next_char_addr1 = inside_char_tile_next1 ?  facing_right1 ? ((((row - char_y1)>>1) + anim_row1 )* koopa_max_width_1) + ( (23 - 1 - (((col - char_x1)>>1))) + anim_col1 ):
                                                               ((((row - char_y1)>>1) + anim_row1 )* koopa_max_width_1) + (((col - char_x1)>>1) + anim_col1)
                                          : 0;
      //PLAYER 2
      inside_char_tile_next2 = (col >= char_x2 && col < char_x2 + 23*2  
                          && row >= char_y2 && row < char_y2 + 30*2);
      next_char_addr2 = inside_char_tile_next2 ?  facing_right2 ? ((((row - char_y2)>>1) + anim_row2)* koopa_max_width_2) + ( (23 - 1- (((col - char_x2)>>1))) + anim_col2):
                                                               ((((row - char_y2)>>1) + anim_row2)* koopa_max_width_2) + (((col - char_x2)>>1) + anim_col2)
                                          : 0;
      // platform drawing
      inside_plt_tile_next = (col >= plt_x && col < plt_x + 400 && row >= plt_y && row < plt_y + 9);
      //next_plt_addr = inside_plt_tile_next ? (((row - plt_y))* 100) + (((col - plt_x))): 0;

      if (inside_char_tile1 && char_rgb1 != 6'b110011 && player1_alive) begin
        next_final_rgb = char_rgb1;
      end else if (inside_char_tile2 && char_rgb2 != 6'b110011 && player2_alive) begin
        next_final_rgb = char_rgb2;
      end else if (inside_plt_tile) begin 
        next_final_rgb = plt_rgb;
      end else begin
        next_final_rgb = tile_rgb;
      end

    end
    logic [5:0] d_rgb;

    always_ff @(posedge clk_out) begin
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
  // getting a FPS
  localparam int MAX_TICK = 5_000_000; // we can change this for speed
  logic [31:0] anim_counter;
  logic anim_tick;
  always_ff @(posedge clk_out) begin
    if (anim_counter == MAX_TICK) begin
      anim_tick <= 1;
      anim_counter <= 0;
    end else begin
      anim_tick <= 0;
      anim_counter <= anim_counter + 1;
    end
  end

  logic hit_on1;
  animation player1_animation (
    .clk(clk_out),
    .anim_tick(anim_tick),
    .attack_active(attack_active1),
    .atk_state(atk_state1),
    .move_anim(player1_move_state),
    .anim_row(anim_row1),
    .anim_col(anim_col1),
    .max_width(koopa_max_width_1)
  );
  logic hit_on2;
  animation player2_animation(
    .clk(clk_out),
    .anim_tick(anim_tick),
    .attack_active(attack_active2),
    .atk_state(atk_state2),
    .move_anim(player2_move_state),
    .anim_row(anim_row2),
    .anim_col(anim_col2),
    .max_width(koopa_max_width_2)
  );


  logic [7:0] buttons1;
  logic button_up1, button_down1, button_left1, button_right1;
  logic button_select1, button_start1, button_B1, button_A1;
  logic [7:0] buttons2;
  logic button_up2, button_down2, button_left2, button_right2;
  logic button_select2, button_start2, button_B2, button_A2;
movement_state player2_move_state;
movement_FSM #(
  .WIDTH(23),
  .HEIGHT(30),
  .INITIAL_X(420),
  .INITIAL_Y(300)
) player2_movement (
  .clk(clk_out),
  .player(0),
  .char_reset(respawn2),
  .frame_rate(gated_frame_rate),
  .button_up(button_B2), // using button B instead of up pad since it is really painful to keep accidentally pressing
  .button_down(button_down2),
  .button_left(button_left2),
  .button_right(button_right2),
  .got_hit(got_hit2),
  .knock_from_right(knock_from_right2),
  //.collision(player2_hit),
  .x_pos(char_x2),
  .y_pos(char_y2),
  .facing_right(facing_right2),
  .move_state(player2_move_state),
  .reset(respawn2) // Respawn resets position
);
movement_state player1_move_state;
movement_FSM #(
  .WIDTH(23),
  .HEIGHT(30),
  .INITIAL_X(130),
  .INITIAL_Y(300)
) player1_movement (
  .clk(clk_out),
  .player(1),
  .char_reset(respawn1),
  .frame_rate(gated_frame_rate),
  .button_up(button_B1),  // using button B instead of up pad since it is really painful to keep accidentally pressing
  .button_down(button_down1),
  .button_left(button_left1),
  .button_right(button_right1),
  .got_hit(got_hit1),
  .knock_from_right(knock_from_right1),
  //.collision(player1_hit),
  .x_pos(char_x1),
  .y_pos(char_y1),
  .facing_right(facing_right1),
  .move_state(player1_move_state),
  .reset(respawn1) // Respawn resets position
);



controller u_controller1 (
    .latch(latch1),
    .clock(ctrl_clk1),
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
    .clk(clk_out)
);

controller u_controller2 (
    .latch(latch2),
    .clock(ctrl_clk2),
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
    .clk(clk_out)
);

ROM_koopa_animations_23x30 u_koopa_rom_1 (
  .clk(clk_out),
  .addr1(char_addr1),
  .addr2(char_addr2),
  .rgb1(next_char_rgb1),
  .rgb2(next_char_rgb2)
);

// ROM_platform u_platform_rom (
//   .clk(clk_out),
//   .addr(plt_addr),
//   .rgb(next_plt_rgb)
// );

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
  .tile(display_rgb),    
  .rgb(rgb)     
);

// Hit/damage signals
// Hit/damage signals
logic hit_stun_active1, hit_stun_active2;
logic [9:0] damage1, damage2;
logic [1:0] stocks1, stocks2;
logic hit_respawn1, hit_respawn2;
logic respawn1, respawn2;

// Player alive status - alive if they have lives left
logic player1_alive, player2_alive;
assign player1_alive = (stocks1 > 0);
assign player2_alive = (stocks2 > 0);

// Game State Machine
game_state_t current_state = STATE_START_SCREEN;
game_state_t next_state;

always_ff @(posedge clk_out) begin
    if (init_respawn) 
        current_state <= STATE_START_SCREEN;
    else 
        current_state <= next_state;
end

always_comb begin
    next_state = current_state;
    // Valid start press requires the controller to not be returning all 0s (disconnected/glitch)
    // buttons is active LOW, so 8'h00 means ALL pressed.
    logic start_valid_1; 
    logic start_valid_2;
    start_valid_1 = button_start1 && (buttons1 != 8'h00);
    start_valid_2 = button_start2 && (buttons2 != 8'h00);

    case (current_state)
        STATE_START_SCREEN: begin
            if (start_valid_1 || start_valid_2)
                next_state = STATE_PLAYING;
        end
        STATE_PLAYING: begin
            if (!player1_alive || !player2_alive)
                next_state = STATE_GAME_OVER;
        end
        STATE_GAME_OVER: begin
            if (start_valid_1 || start_valid_2)
                next_state = STATE_PLAYING;
        end
    endcase
end


logic global_reset;
// Reset if powering up OR transitioning FROM game over/start screen TO playing logic
// Actually, simple way: Reset whenever we ENTER playing state from non-Playing state? 
// Or just hold reset high when NOT playing?
// Let's use specific triggers.
// We want to reset positions/health when we START the game.
// So global_reset should be true when (next_state == STATE_PLAYING && current_state != STATE_PLAYING)

// BUT, init_respawn is 1-cycle at boot.
// Let's make a dedicated "start_game_trigger" pulse.
logic start_game_trigger;
assign start_game_trigger = (current_state != STATE_PLAYING && next_state == STATE_PLAYING);

assign global_reset = init_respawn || start_game_trigger;

assign respawn1 = hit_respawn1 || global_reset;
assign respawn2 = hit_respawn2 || global_reset;

// We should only advance physics/logic when STATE_PLAYING
logic game_active;
assign game_active = (current_state == STATE_PLAYING);
logic gated_frame_rate;
assign gated_frame_rate = frame_rate && game_active;


// If button A is pressed AND characters are colliding (player1_hit) -> opponent takes damage
// Uses the existing AABB collision detection from daniel
attack_state atk_state1;
logic a1_pressed1;
logic attack_active1;
attack_FSM player1_atk (
  .clk(clk_out),
  .frame_tick(gated_frame_rate),
  .reset(init_respawn),
  .btn_A(button_A1),
  .btn_up(button_up1),
  .btn_down(button_down1),
  .btn_left(button_left1),
  .btn_right(button_right1),
  .attack_active(attack_active1),
  .atk_state(atk_state1),
  .A_pressed(a1_pressed1)
);
attack_state atk_state2;
logic a1_pressed2;
logic attack_active2;
attack_FSM player2_atk (
  .clk(clk_out),
  .frame_tick(gated_frame_rate),
  .reset(init_respawn),
  .btn_A(button_A2),
  .btn_up(button_up2),
  .btn_down(button_down2),
  .btn_left(button_left2),
  .btn_right(button_right2),
  .attack_active(attack_active2),
  .atk_state(atk_state2),
  .A_pressed(a1_pressed2)
);

// which side did we get attacked
logic knock_from_right1;
logic knock_from_right2;
// P1: got hit by P2 from the right if P2 is to the right of P1
assign knock_from_right1 = (char_x2 > char_x1);

// P2: got hit by P1 from the right if P1 is to the right of P2
assign knock_from_right2 = (char_x1 > char_x2);
// Player 1 attacks Player 2 when: A pressed + characters colliding + P2 not in hitstun
logic got_hit2;
assign got_hit2 = a1_pressed1 && player1_hit && !hit_stun_active2;

// Player 2 attacks Player 1 when: A pressed + characters colliding + P1 not in hitstun  
logic got_hit1;
assign got_hit1 = a1_pressed2 && player1_hit && !hit_stun_active1;

// Player 1 Hit/Damage FSM
hit_FSM player1_hit_fsm (
    .clk(clk_out),
    .reset(global_reset),
    .frame_tick(gated_frame_rate),
    .got_hit(got_hit1),
    .hit_damage_in(6'd12),  // 12% damage per hit
    .hit_stun_active(hit_stun_active1),
    .damage(damage1),
    .stocks(stocks1),
    .respawn_trigger(hit_respawn1)
);

// Player 2 Hit/Damage FSM
hit_FSM player2_hit_fsm (
    .clk(clk_out),
    .reset(global_reset),
    .frame_tick(gated_frame_rate),
    .got_hit(got_hit2),
    .hit_damage_in(6'd12),  // 12% damage per hit
    .hit_stun_active(hit_stun_active2),
    .damage(damage2),
    .stocks(stocks2),
    .respawn_trigger(hit_respawn2)
);

// HEALTH BAR RENDERING

// Health bar positions
localparam int P1_BAR_X = 20;
localparam int P2_BAR_X = 520;
localparam int BAR_Y = 10;
localparam int BAR_WIDTH = 100;
localparam int BAR_HEIGHT = 15;

// Calculate health bar fill (inverse of damage - more damage = less bar)
logic [9:0] p1_fill, p2_fill;
assign p1_fill = (damage1 >= 100) ? 0 : (100 - damage1);
assign p2_fill = (damage2 >= 100) ? 0 : (100 - damage2);

// Health bar pixel detection
logic inside_p1_bar_outline, inside_p1_bar_fill;
logic inside_p2_bar_outline, inside_p2_bar_fill;
logic inside_health_bar;
logic [5:0] health_bar_rgb;

always_comb begin
    // Player 1 health bar
    inside_p1_bar_outline = (col >= P1_BAR_X && col < P1_BAR_X + BAR_WIDTH + 4 &&
                             row >= BAR_Y && row < BAR_Y + BAR_HEIGHT + 4);
    inside_p1_bar_fill = (col >= P1_BAR_X + 2 && col < P1_BAR_X + 2 + p1_fill &&
                          row >= BAR_Y + 2 && row < BAR_Y + BAR_HEIGHT + 2);
    
    // Player 2 health bar
    inside_p2_bar_outline = (col >= P2_BAR_X && col < P2_BAR_X + BAR_WIDTH + 4 &&
                             row >= BAR_Y && row < BAR_Y + BAR_HEIGHT + 4);
    inside_p2_bar_fill = (col >= P2_BAR_X + 2 && col < P2_BAR_X + 2 + p2_fill &&
                          row >= BAR_Y + 2 && row < BAR_Y + BAR_HEIGHT + 2);
    
    inside_health_bar = inside_p1_bar_outline || inside_p2_bar_outline;
    
    // Color the health bars
    if (inside_p1_bar_fill)
        health_bar_rgb = 6'b001100;  // Green fill for P1
    else if (inside_p1_bar_outline)
        health_bar_rgb = 6'b111111;  // White outline for P1
    else if (inside_p2_bar_fill)
        health_bar_rgb = 6'b110000;  // Red fill for P2
    else if (inside_p2_bar_outline)
        health_bar_rgb = 6'b111111;  // White outline for P2
    else
        health_bar_rgb = 6'b000000;
end

// Stock indicators (small squares below health bar)
logic inside_stock_indicator;
logic [5:0] stock_rgb;

always_comb begin
    inside_stock_indicator = 0;
    stock_rgb = 6'b000000;
    
    // Player 1 stocks (3 small squares)
    if (row >= BAR_Y + BAR_HEIGHT + 8 && row < BAR_Y + BAR_HEIGHT + 18) begin
        if (stocks1 >= 1 && col >= P1_BAR_X && col < P1_BAR_X + 10) begin
            inside_stock_indicator = 1;
            stock_rgb = 6'b001100;  // Green
        end else if (stocks1 >= 2 && col >= P1_BAR_X + 15 && col < P1_BAR_X + 25) begin
            inside_stock_indicator = 1;
            stock_rgb = 6'b001100;
        end else if (stocks1 >= 3 && col >= P1_BAR_X + 30 && col < P1_BAR_X + 40) begin
            inside_stock_indicator = 1;
            stock_rgb = 6'b001100;
        end
    end
    
    // Player 2 stocks (3 small squares) -- Logic for P2 was missing/merged in original snippet, ensuring it acts correctly
    if (row >= BAR_Y + BAR_HEIGHT + 8 && row < BAR_Y + BAR_HEIGHT + 18) begin
        if (stocks2 >= 1 && col >= P2_BAR_X && col < P2_BAR_X + 10) begin
            inside_stock_indicator = 1;
            stock_rgb = 6'b110000;  // Red
        end else if (stocks2 >= 2 && col >= P2_BAR_X + 15 && col < P2_BAR_X + 25) begin
            inside_stock_indicator = 1;
            stock_rgb = 6'b110000;
        end else if (stocks2 >= 3 && col >= P2_BAR_X + 30 && col < P2_BAR_X + 40) begin
            inside_stock_indicator = 1;
            stock_rgb = 6'b110000;
        end
    end
end
// top-level locals
logic init_respawn;       // 1-cycle pulse at startup
logic init_done;

// Generate a single pulse on the first frame_tick after power-up/reset
always_ff @(posedge clk_out) begin
  if (!init_done && frame_rate) begin
    init_respawn <= 1'b1;
    init_done    <= 1'b1;
  end else begin
    init_respawn <= 1'b0;
  end
end
// health bar overlay on top of game graphics
// Game Over Text Logic
logic inside_game_over;
game_over_text u_game_over_text (
    .x(col),
    .y(row),
    .pixel_on(inside_game_over)
);

// Start Screen Text Logic
logic inside_start_screen;
start_screen_text u_start_screen (
    .x(col),
    .y(row),
    .pixel_on(inside_start_screen)
);

// health bar overlay on top of game graphics
logic [5:0] display_rgb;
always_comb begin
    case(current_state)
        STATE_START_SCREEN: begin
             if (inside_start_screen)
                display_rgb = 6'b111111; // White text
             else 
                display_rgb = 6'b000000; // Black background
        end
        STATE_PLAYING: begin
            if (inside_health_bar)
                display_rgb = health_bar_rgb;
            else if (inside_stock_indicator)
                display_rgb = stock_rgb;
            else
                display_rgb = final_rgb;
        end
        STATE_GAME_OVER: begin
            if (inside_game_over)
                display_rgb = 6'b111111; // White text
            else
                display_rgb = final_rgb; // Frozen game background
        end
        default: display_rgb = final_rgb;
    endcase
end


endmodule
