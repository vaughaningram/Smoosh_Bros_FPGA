<div align="center">
Smoosh Bros
A Super Smash Bros style two player fighting game built entirely in SystemVerilog and running on an FPGA

640x480 VGA • Sprite Rendering • Hardware Physics • Real Time Animations

</div>
Overview

Smoosh Bros is a hardware accelerated fighting game implemented with pure SystemVerilog logic.
There is no CPU and no software loop.
Every frame of gameplay, physics, animation, collision, health, and rendering is computed in FPGA hardware.

Gameplay Features
Player Systems

Responsive two player controls

Horizontal movement with acceleration

Jumping with full jump and fall animations

Attack system with active hit detection

Real time health bars

Stock based life system

Shield ability with decay and cooldown

Accurate platform collision

Smooth animation transitions for idle, walk, run, jump, fall, and attack

Rendering

640x480 VGA output at 60 Hz

Hardware generated sync signals

Background, platform, and character sprites stored in ROM

Transparent pixel masking for clean outlines

Full hardware pipeline for color selection and priority layering

Controls
Action	Button
Move Left	Left
Move Right	Right
Jump	B
Attack	A
Shield	Custom mapped input
Shield System

The shield is controlled by a simple FSM.
It activates on a button press, drains gradually, and enters a cooldown period when released or depleted.
During cooldown it regenerates to full and becomes usable again.

Project Structure
Smoosh_Bros/
│
├── top.sv                        Main top level module for VGA and game logic
│
├── pcs/
│   └── top.pcf                   Pin constraint file
│
├── VGA/
│   ├── vga_controller.sv         VGA timing generator
│   └── vga_sync.sv
│
├── Sprites/
│   ├── char_rom.sv               Character sprite ROM
│   ├── platform_rom.sv           Platform sprite ROM
│   └── background_rom.sv         Background ROM
│
├── State Machines/
│   ├── movement_FSM.sv           Movement logic
│   ├── attack_FSM.sv             Attack timing and hitbox control
│   ├── shield_FSM.sv             Shield logic
│   └── top_states.sv             Animation and state mux
│
└── Controllers/
    └── nes_controller.sv         NES style controller interface

FPGA Pin Assignments
set_io clk_in 20
set_io clk_out 34

set_io rgb[5] 37
set_io rgb[4] 31
set_io rgb[3] 35
set_io rgb[2] 32
set_io rgb[1] 27
set_io rgb[0] 26

set_io hsync 25
set_io vsync 23

Build Instructions
Install the open source FPGA toolchain
apio install system
apio install scons
apio install icestorm
apio install nextpnr-ice40
apio install oss-cad-suite

Build the project
apio build

Upload to the FPGA
apio upload

Engine Pipeline

Each frame, the following occurs inside hardware:

Controller inputs are sampled

Movement FSM updates velocity and position

Attack FSM activates hitboxes

Shield FSM updates shield state

Collision and hit detection update health and stocks

Animation selection chooses the correct sprite frame

Renderer decides each pixel based on priority and masking

VGA controller outputs the final display signal

All of this runs continuously with no processor involved.

Future Improvements

Larger hitbox system

Special moves and projectiles

Multiple stages or platform layouts

UI improvements

Audio support

Win or results screen
