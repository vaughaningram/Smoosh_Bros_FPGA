from PIL import Image

img = Image.open("dude_34_38.png").convert("RGB")

# w,h = img.size

w = 34
h = 38

addr = 4800


# print(f"Image size: {img.size}")

out = open("dude.bin", "w")

def to6Bit(r,g,b):
    r_new = r >> 6
    g_new = g >> 6
    b_new = b >> 6

    val = (r_new << 4) | (g_new << 2) | b_new
    return val


for y in range(h):
    for x in range(w):

        r, g, b = img.getpixel((x,y))
                
        
        val = to6Bit(r,g,b)
        out.write(f" 17'b{addr:017b} : data_comb = 6'b{val:06b};\n")

        addr += 1

out.close()

print("Sprite Compression Complete\n")
