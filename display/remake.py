import re
from PIL import Image

WIDTH      = 640
HEIGHT     = 480
TILE_SIZE  = 8

tiles_x = WIDTH  // TILE_SIZE
tiles_y = HEIGHT // TILE_SIZE
total_tiles = tiles_x * tiles_y

pattern = re.compile(r"6'b([01]{6})")

values = []

with open("output.bin", "r") as f:
    for line in f:
        m = pattern.search(line)
        if m:
            bin_value = m.group(1)
            values.append(int(bin_value, 2))

# Sanity check
if len(values) < total_tiles:
    raise ValueError(f"ROM contains only {len(values)} tiles, but expected {total_tiles}")

img = Image.new("RGB", (WIDTH, HEIGHT))
pixels = img.load()

i = 0

for Ty in range(tiles_y):
    for Tx in range(tiles_x):

        v = values[i]      # 6-bit RGB
        i += 1

        # Extract 2-bit-per-channel RGB
        r2 = (v >> 4) & 0b11
        g2 = (v >> 2) & 0b11
        b2 = (v >> 0) & 0b11

        # Expand 2-bit → 8-bit color
        r = r2 * 85
        g = g2 * 85
        b = b2 * 85

        # Fill 16×16 tile
        for py in range(TILE_SIZE):
            for px in range(TILE_SIZE):
                x = Tx * TILE_SIZE + px
                y = Ty * TILE_SIZE + py
                pixels[x, y] = (r, g, b)

img.save("reconstructed.png")
img.show()
