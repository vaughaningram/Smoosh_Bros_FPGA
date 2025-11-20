from PIL import Image

img = Image.open("background.png").convert("RGB")

# w,h = img.size

w = 640
h = 480
TILE_SIZE = 8
TILE = 64

addr = 0

tiles_x = w // TILE_SIZE
tiles_y = h // TILE_SIZE

# print(f"Image size: {img.size}")

out = open("output.bin", "w")

def to6Bit(r,g,b):
    r_new = r >> 6
    g_new = g >> 6
    b_new = b >> 6

    val = (r_new << 4) | (g_new << 2) | b_new
    return val


for Ty in range(tiles_y):
    for Tx in range(tiles_x):
        rsum = 0
        gsum = 0
        bsum = 0
        for py in range(TILE_SIZE):
            for px in range(TILE_SIZE):
                y = Ty * TILE_SIZE + py
                x = Tx * TILE_SIZE + px 

                r, g, b = img.getpixel((x,y))
                rsum += r
                gsum += g
                bsum += b
                
        ravg = rsum // TILE
        gavg = gsum // TILE
        bavg = bsum // TILE
        
        val = to6Bit(ravg,gavg,bavg)
        out.write(f" 17'b{addr:017b} : data_comb = 6'b{val:06b};\n")

        addr += 1

out.close()

print("Color Compression Complete\n")
