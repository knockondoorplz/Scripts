from PIL import Image
import os
import sys

VALID_EXTENSIONS = (
    ".png", ".jpg", ".jpeg", ".bmp", ".gif", ".heic", ".tif", ".tiff", ".dib",
)
OUTPUT_NAME = "stacked.png"


def gather_targets(args):
    """Turn the raw argv (folders and/or individually selected files) into
    an ordered list of image paths to stack."""
    paths = []
    for target in args:
        if os.path.isfile(target):
            # Explicitly selected -> stack it, no extension filter, no question
            paths.append(target)
        elif os.path.isdir(target):
            # Folder mode -> only grab approved image types, alphabetically
            for f in sorted(os.listdir(target)):
                if f.lower().endswith(VALID_EXTENSIONS) and f != OUTPUT_NAME:
                    paths.append(os.path.join(target, f))
    return paths


def main():
    if len(sys.argv) < 2:
        print("No files passed.")
        return

    image_paths = gather_targets(sys.argv[1:])
    if not image_paths:
        print("No image files found.")
        return

    output_dir = os.path.dirname(image_paths[0])
    output_path = os.path.join(output_dir, OUTPUT_NAME)

    print("Stacking files:")
    for p in image_paths:
        print(" -", os.path.basename(p))

    images = [Image.open(p) for p in image_paths]
    max_width = max(img.width for img in images)
    total_height = sum(img.height for img in images)

    result = Image.new("RGBA", (max_width, total_height))
    y_offset = 0
    for img in images:
        result.paste(img, (0, y_offset))
        y_offset += img.height

    result.save(output_path)
    print("Saved:", output_path)


if __name__ == "__main__":
    main()
