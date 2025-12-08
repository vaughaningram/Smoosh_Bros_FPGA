<div align="center">

# 🍄 **Smoosh Bros**

### A Super Smash Bros–style two-player fighting game built entirely in **SystemVerilog** on an **FPGA**  
**640×480 VGA • Hardware Sprites • Real-Time Physics • Fully Parallel Game Engine**

---

</div>

## Overview

**Smoosh Bros** is a fully hardware-accelerated fighting game implemented in **pure SystemVerilog**.  
There is **no CPU**, no firmware, and no software loop of any kind.

Every frame of gameplay is produced directly in FPGA logic:

- Movement & physics  
- Collision & platform logic  
- Hit detection  
- Shields  
- Health & stock tracking  
- Sprite animation  
- VGA rendering  

The entire game engine runs **fully in parallel**, synchronized to the VGA clock.

---

## Gameplay Features

### **Player Systems**
- Responsive two-player controls  
- Smooth horizontal movement with acceleration  
- Full jumping + falling animations  
- Attack system with active hit frames  
- Real-time health bars  
- Stock-based life system  
- Shield ability with decay, cooldown, and break  
- Accurate platform collision  
- Clean animation transitions:  
  *idle → walk → run → jump → fall → attack*

### **Rendering**
- **640×480 @ 60 Hz** VGA output  
- Hardware HSYNC/VSYNC generation  
- Background + platforms stored in ROM  
- Character sprites stored in block ROM  
- Alpha-style transparency masking  
- Pixel-accurate renderer composed in hardware  

---

## Controls

| Action       | Button |
|--------------|--------|
| Move Left    | Left   |
| Move Right   | Right  |
| Jump         | B      |
| Attack       | A      |
| Shield       | Custom mapped input |

NES-style digital controllers supported through hardware interface.

---

## Project Structure

Smoosh_Bros/
│
├── top.sv # Top-level game engine + VGA pipeline
│
├── pcs/
│ └── top.pcf # FPGA pin constraints
│
├── VGA/
│ ├── vga_controller.sv # VGA timing generator
│ └── vga_sync.sv
│
├── Sprites/
│ ├── char_rom.sv # Character sprites
│ ├── platform_rom.sv # Stage platforms
│ └── background_rom.sv # Background image
│
├── State Machines/
│ ├── movement_FSM.sv # Velocity, gravity, movement state machine
│ ├── attack_FSM.sv # Attack timing + hitbox activation
│ ├── shield_FSM.sv # Shield decay + cooldown logic
│ └── top_states.sv # Animation selector + master state coordination
│
└── Controllers/
└── nes_controller.sv # Controller interface + debouncing

---

## FPGA Pin Assignments

# VGA sync signals
set_io hsync 25
set_io vsync 23

# external clk 
set_io clk_in 20

set_io latch1 28
set_io latch2 43
set_io ctrl_clk1 38
set_io ctrl_clk2 45
set_io data1  42
set_io data2  36

---

## Build Instructions

### **1. Install the toolchain**

apio install system
apio install scons
apio install icestorm
apio install nextpnr-ice40
apio install oss-cad-suite

### **2. Build the project**

apio build

### **3. Upload to the FPGA**

apio upload

---

## How the Hardware Game Engine Works

Every frame, the game logic executes as a fully pipelined hardware system:

1. **Controller inputs** are sampled  
2. **Movement FSM** updates velocity, gravity, & position  
3. **Attack FSM** activates hitboxes and frame timing  
4. **Shield FSM** performs decay, break, and cooldown logic  
5. **Collision engine** resolves platforms & hit detection  
6. **Health/stock logic** updates player state  
7. **Animation state machine** chooses correct sprite frame  
8. **Renderer** selects pixels from background/platform/sprite/mask  
9. **VGA controller** outputs the final RGB pixel  

Everything runs **continuously and in parallel** — the FPGA *is* the game engine.

---

## Future Improvements

Planned extensions include:

- Directional hitboxes & variable damage  
- Special moves and projectiles  
- Additional platforms and stage layouts  
- Improved UI and hit effects  
- Hardware sound output  
- Win/results screen  

---

<div align="center">

Made by Vaughan, Andrew, Jonah, and Daniel 👾  

</div>
