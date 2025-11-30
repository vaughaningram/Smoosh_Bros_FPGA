from PIL import Image

img = Image.open("../Sprites/marco_sprite-1.png (3).png").convert("RGB")


PALETTE_MAP = {
    (0, 0, 0): 0,
    (18, 11, 2): 1,
    (33, 25, 14): 2,
    (90, 105, 136): 3,
    (255, 255, 255): 4,
    (194, 133, 105): 5,
    (184, 111, 80): 6,
    (156, 94, 68): 7,
    (48, 34, 14): 8,
    (61, 43, 18): 9,
    (38, 23, 5): 10,
    (106, 119, 145): 11,
    (53, 60, 94): 12,
    (38, 43, 68): 13,
    (255, 0, 255): 14,
    (247, 118, 34): 15
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
    
out.close()

print("ROM Complete\n")

