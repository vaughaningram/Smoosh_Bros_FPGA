from PIL import Image

IMAGE = "../ROM Scripts/image-1.png.png"
OUTPUT = "6_Bit_Output.png"

img = Image.open(IMAGE).convert("RGB")

pixel_data = list(img.getdata())

new_img_data = []
for r, g, b in pixel_data:
    # shifting 6 bits to the right to convert to 6bit RGB then 6 bitd to the left
    # to get back to standard 8 bit rgb for png
    print(r, g, b)
    # appending data
    new_img_data.append(((r >> 6) << 6,(g >>6) << 6 ,(b >> 6) << 6))

# saving image
new_img = Image.new(img.mode, img.size)
new_img.putdata(new_img_data)
new_img.save(OUTPUT)


