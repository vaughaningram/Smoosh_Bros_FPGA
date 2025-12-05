from PIL import Image

img = Image.open("platform_tests.png").convert("RGB")


PALETTE_MAP = {
    (255, 255, 255): 0,
    (  0,  0,   0): 1,
}



# w,h = img.size

w = 100
h = 9
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

