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
- Background and platform graphics from ROM  
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

```text
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

### **Install the open source FPGA toolchain**

```bash
apio install system
apio install scons
apio install icestorm
apio install nextpnr-ice40
apio install oss-cad-suite

---

## **Build Instructions**

### **Build the project**
```bash
apio build
Upload to the FPGA
bash
Copy code
apio upload
How the Game Engine Works
Each frame, the hardware performs:

Controller inputs are sampled

Movement FSM updates velocity and position

Attack FSM activates hitboxes

Shield FSM updates shield state

Collision and hit detection update health and stocks

Animation logic selects the correct sprite frame

Renderer decides each pixel from background, platforms, and both characters

VGA controller outputs the final pixel

All game logic runs continuously in hardware with no processor.

Future Work
Expanded hitbox and damage system

Special moves and projectiles

Additional platform layouts

Improved UI elements

Sound output system

Win or results screen

yaml
Copy code

---

# ⚠️ Important  
The triple backticks inside the code above will break if pasted normally into ChatGPT…  
so here is the same content WITHOUT markdown fences, so you can see the structure:

---

## **Build Instructions**

### **Build the project**
```bash
apio build
Upload to the FPGA
bash
Copy code
apio upload
How the Game Engine Works
Each frame, the hardware performs:

Controller inputs are sampled

Movement FSM updates velocity and position

Attack FSM activates hitboxes

Shield FSM updates shield state

Collision and hit detection update health and stocks

Animation logic selects the correct sprite frame

Renderer decides each pixel from background, platforms, and both characters

VGA controller outputs the final pixel

All game logic runs continuously in hardware with no processor.

Future Work
Expanded hitbox and damage system

Special moves and projectiles

Additional platform layouts

Improved UI elements

Sound output system

Win or results screen

