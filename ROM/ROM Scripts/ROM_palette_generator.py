from PIL import Image

img = Image.open("6_Bit_Output.png").convert("RGB")

PALETTE_MAP = {
    (192,   0, 192): 0,  # (11,00,11)
    (  0,   0,   0): 1,  # (00,00,00)
    (192, 128, 128): 2,  # (11,10,10)
    ( 64,  64, 128): 3,  # (01,01,10)
    (  0,   0,  64): 4,  # (00,00,01)
}



# w,h = img.size

w = 30
h = 40
print(img.size)
print()
 

# print(f"Image size: {img.size}")

out = open("output.bin", "w")





for y in range(h):
    for x in range(w):
        r, g, b = img.getpixel((x, y))
        index = PALETTE_MAP[(r,g,b)]
        out.write(f"{index:X}\n")
        print(f"{index:X}")
    print("\n")
out.close()

print("ROM Complete\n")

