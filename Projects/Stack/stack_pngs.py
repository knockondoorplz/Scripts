from PIL import Image
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_JPEG = "stacked.jpg"
OUTPUT_WEBP = "stacked.webp"

VALID_EXTENSIONS = {
    ".png", ".jpg", ".jpeg", ".JPEG",
    ".bmp", ".gif", ".heic",
    ".tif", ".tiff", ".dib",
}

# Collect all valid image files
image_files = sorted(
    f for f in os.listdir(SCRIPT_DIR)
    if os.path.splitext(f.lower())[1] in VALID_EXTENSIONS
)

if not image_files:
    print("No image files found.")
    exit(1)

print("Stacking files:")
for f in image_files:
    print(" -", f)

# Load images
images = [Image.open(os.path.join(SCRIPT_DIR, f)) for f in image_files]

# Compute final canvas size
widths = [img.width for img in images]
heights = [img.height for img in images]

total_height = sum(heights)
max_width = max(widths)

result = Image.new("RGB", (max_width, total_height), (255, 255, 255))

# Paste images vertically
y_offset = 0
for img in images:
    if img.mode != "RGB":
        img = img.convert("RGB")
    result.paste(img, (0, y_offset))
    y_offset += img.height

# Save JPEG
result.save(os.path.join(SCRIPT_DIR, OUTPUT_JPEG), "JPEG", quality=70)

# Save WebP (optional)
result.save(os.path.join(SCRIPT_DIR, OUTPUT_WEBP), "WEBP", quality=60)

print("Saved:", OUTPUT_JPEG, "and", OUTPUT_WEBP)
