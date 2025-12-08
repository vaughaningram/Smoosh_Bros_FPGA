<div align="center">

# **Smoosh Bros**

### Super Smash Bros style two player fighting game built entirely in SystemVerilog and running on an FPGA  
**640x480 VGA • Sprite Rendering • Hardware Physics • Real Time Animations**

</div>

---

## **Overview**

Smoosh Bros is a hardware accelerated fighting game implemented with pure SystemVerilog logic.  
There is no CPU and no software loop.  
Every frame of gameplay, physics, animation, collision, health, and rendering is computed directly in FPGA hardware.

---

## **Gameplay Features**

### **Player Systems**
- Responsive two player controls  
- Horizontal movement with acceleration  
- Jumping with full jump and fall animations  
- Attack system with active hit detection  
- Real time health bars  
- Stock based life system  
- Shield ability with decay and cooldown  
- Accurate platform collision  
- Smooth animation transitions for idle, walk, run, jump, fall, and attack  

### **Rendering**
- 640x480 VGA output at 60 Hz  
- Hardware generated sync signals  
- Background and platform graphics stored in ROM  
- Character sprites stored in block ROM  
- Transparent masking for clean sprite edges  

---

## **Controls**

| Action | Button |
|--------|--------|
| Move Left | Left |
| Move Right | Right |
| Jump | B |
| Attack | A |
| Shield | Custom mapped input |

---

## **Project Structure**

Smoosh_Bros/
├── top.sv Main top level module for VGA and game logic
│
├── pcs/
│ └── top.pcf Pin constraint file
│
├── VGA/
│ ├── vga_controller.sv VGA timing generator
│ └── vga_sync.sv
│
├── Sprites/
│ ├── char_rom.sv Character sprite ROM
│ ├── platform_rom.sv Platform sprite ROM
│ └── background_rom.sv Background ROM
│
├── State Machines/
│ ├── movement_FSM.sv Movement logic
│ ├── attack_FSM.sv Attack timing and hitbox control
│ ├── shield_FSM.sv Shield decay and cooldown logic
│ └── top_states.sv Animation and state selection
│
└── Controllers/
└── nes_controller.sv Controller interface and debouncing

---

## **FPGA Pin Assignments**

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

---

## **Build Instructions**

### Install the toolchain

apio install system
apio install scons
apio install icestorm
apio install nextpnr-ice40
apio install oss-cad-suite

### Build the project

apio build

### Upload to the FPGA

apio upload

---

## **How the Game Engine Works**

Each frame, the hardware performs:

1. Controller inputs are sampled  
2. Movement FSM updates velocity and position  
3. Attack FSM activates hitboxes  
4. Shield FSM updates shield state  
5. Collision and hit detection update health and stocks  
6. Animation logic selects the correct sprite frame  
7. Renderer outputs the correct pixel from sprites, platforms, or background  
8. VGA controller drives the final pixel to the display  

All logic runs continuously at full hardware speed.

---

## **Future Work**

- Expanded hitbox and damage system  
- Special moves and projectiles  
- Additional platform layouts  
- Improved UI  
- Sound output  
- Win or results screen  

---
