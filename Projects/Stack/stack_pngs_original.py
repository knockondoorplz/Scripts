from PIL import Image
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_FILE = "stacked.png"
VALID_EXTENSIONS = {
    ".png",
    ".jpg",
    ".jpeg",
    ".JPEG",
    ".bmp",
    ".gif",
    ".heic",
    ".tif",
    ".tiff",
    ".dib",
}

png_files = sorted(
    f for f in os.listdir(SCRIPT_DIR)
    if f.lower().endswith(".png") and f != OUTPUT_FILE
)

if not png_files:
    print("No PNG files found.")
    exit(1)

print("Stacking files:")
for f in png_files:
    print(" -", f)

images = [Image.open(os.path.join(SCRIPT_DIR, f)) for f in png_files]

widths = [img.width for img in images]
heights = [img.height for img in images]

total_height = sum(heights)
max_width = max(widths)

result = Image.new("RGBA", (max_width, total_height))

y_offset = 0
for img in images:
    result.paste(img, (0, y_offset))
    y_offset += img.height

result.save(os.path.join(SCRIPT_DIR, OUTPUT_FILE))

print("Saved:", OUTPUT_FILE)
