
module movement_FSM #(
    parameter WIDTH = 0,
    parameter HEIGHT = 0,
    parameter INITIAL_X = 0,
    parameter INITIAL_Y = 0
    )(
    input logic clk,
    input logic frame_rate,
    input logic button_up,
    input logic button_down,
    input logic button_left,
    input logic button_right,
    output logic [9:0] x_pos,
    output logic [9:0] y_pos,
    output logic facing_right,
    output movement_state move_state
);
localparam int GRAVITY = 1;
localparam int MAX_FALL_SPEED = 10;
localparam int PLATFORM_Y = 410;
localparam int PLATFORM_X = 20;
localparam int JUMP_VELOCITY = -12;
localparam int RUN_VELOCITY = 6;
localparam int WALK_VELOCITY = 3;
// gravity 
logic signed [9:0] y_vel = 0;
// Compute next Y before committing
logic signed [9:0] next_y;
assign next_y = new_y + y_vel;
// for double jumps
logic can_jump_extra = 0;
logic is_running = 0;
logic prev_button_up = 0;
logic prev_button_right = 0;
logic prev_button_left = 0;
logic button_right_pulse;
logic button_left_pulse;
logic button_pulse;
// is colliding with platform
logic touching_platform;
logic [9:0] new_x = INITIAL_X;
logic [9:0] new_y = INITIAL_Y;
logic [3:0] gravity_count;
// timer for run
logic [4:0]run_time = 0;
// timer to avoiding switchin anim took quickly
logic [20:0]idle_time = 0;



 always_ff @(posedge clk) begin
    if (frame_rate) begin
               prev_button_left <= button_left;
        prev_button_right <= button_right;
        prev_button_up <= button_up;
        button_left_pulse <= button_left && !prev_button_left;
        button_right_pulse <= button_right && !prev_button_right;
        button_pulse <= button_up && !prev_button_up;

        if (button_right || button_left) begin
            idle_time <= 0;
            move_state <= WALK;
        end else begin
            if(idle_time < 4) begin
                idle_time <= idle_time + 1;
            end else begin
                move_state <= IDLE;
            end
        end

         // Stop running when no buttons pressed
        if (!button_left && !button_right) begin 
            is_running <= 0; 
        end else begin
            // decrement timer
            if (run_time != 0) begin
                run_time <= run_time -1;
            end
            if (button_right_pulse || button_left_pulse) begin
                if (run_time == 0 || !touching_platform) begin
                    run_time <= 15;
                end else begin
                    is_running <= 1;
                    run_time <= 0;
                end
            end
        end
    
    // Apply movement based on which button is held
    if (button_right && new_x < 610) begin
        facing_right <= 1;
        if (is_running) begin
            new_x <= new_x + RUN_VELOCITY;
        end else begin 
            new_x <= new_x + WALK_VELOCITY;
        end
    end else if (button_left && new_x > 0) begin
        facing_right <= 0;
        if (is_running) begin
            new_x <= new_x - RUN_VELOCITY;
        end else begin 
            new_x <= new_x - WALK_VELOCITY;
        end
    end
            

      // snap so bottom of sprite equals top of platform
      if (touching_platform) begin
        new_y <= PLATFORM_Y - 2*HEIGHT;
        end else begin
            new_y <= next_y;
        end

      // Jump 
      if (button_pulse && touching_platform) begin
        can_jump_extra <= 1;
        y_vel <= JUMP_VELOCITY;
      end else if (!touching_platform && button_pulse && can_jump_extra) begin
                can_jump_extra <= 0;
                 y_vel <= JUMP_VELOCITY;
      end else if (!touching_platform) begin
        if (gravity_count == 1) begin
          gravity_count <= 0;
          if (y_vel < MAX_FALL_SPEED)
            y_vel <= y_vel + 1;
        end else begin
          gravity_count <= gravity_count + 1;
        end
      end else begin
        y_vel         <= 0;
        gravity_count <= 0;
      end
    end
 end
assign x_pos = new_x;
assign y_pos = new_y;

main_plt_collision  #(
      .WIDTH(WIDTH),
      .HEIGHT(HEIGHT)
      ) player1_main_collision (
        .x_pos(x_pos),
        .y_pos(y_pos),
        .next_y(next_y),
        .touching_platform(touching_platform)
    );

endmodule