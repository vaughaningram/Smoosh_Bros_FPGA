module animation (
    input logic frame_tick
    // take in a state of some size,
    // output logic anim_frame,
    // output logic x_offset, y_offset (output the offsets in the sprite sheet to top.sv to draw there)
);

// logic HOLD_TIME  // going to be a mux of sorts that takes in anim_state and current frame #
// HOLD_TIME[anim_state][anim_frame] = count to hold for
// logic anim_frame // the curent frame of the animation we should be animating
// logic hit_box_active // going to be a mux that takes in animation and frame
// hit_box_active[anim_state][anim_frame]
always_ff @(posedge frame_tick) begin
    // if (curr_state == reset_state || next state != prev state) begin
    //   anim_frame <= 0;
    //   hit_box <= 0;
    // end else anim_frame <= anim_frame + 1;

end
// assign hit_box = hit_box_active;


endmodule