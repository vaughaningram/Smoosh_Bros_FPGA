from PIL import Image

IMAGE = "../Backgrounds/Layer 2_background_1.png"
OUTPUT = "collision_bitmap_Output.txt"

img = Image.open(IMAGE).convert("RGB")
w = 640
h = 480

out = open(OUTPUT, "w")

pixel_data = list(img.getdata())
for r, g, b in pixel_data:
   if ((r,g,b) == (255,255,255)) : out.write("0\n")
   else : out.write("1\n")


out.close()