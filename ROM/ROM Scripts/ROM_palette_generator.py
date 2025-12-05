from PIL import Image

img = Image.open("../Sprites/Koop_Walk_6bit-1.png.png").convert("RGB")


PALETTE_MAP = {
    (192,   0, 192): 0,
    (  0,  64,   0): 1,
    (  0, 128,   0): 2,
    (128, 192,   0): 3,
    (  0,   0,   0): 4,
    (192, 192, 192): 5,
    (192, 192,   0): 6,
    (192, 192, 128): 7,
    (128, 128,   0): 8,
    (192, 128,   0): 9
}



# w,h = img.size

w = 69
h = 60
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

