from PIL import Image

img = Image.open("6_Bit_Output.png").convert("RGB")

PALETTE_MAP = {
    (192,   0, 192): 0,  # (11,00,11)
    (  0,   64,   0): 1,  # (00,01,00)
    (0, 128, 0): 2,  # (00,10,00)
    ( 128,  192, 0): 3,  # (10,11,00)
    (  0,   0,  0): 4,  # (00,00,00)
    (192,192,192): 5, # (11,11,11)
    (192,192,0): 6,#  (11,11,00)
    (192,128,00): 7 # (11,10,00)
}



# w,h = img.size

w,h = img.size
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

