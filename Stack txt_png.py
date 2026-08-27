import os

ROOT_DIR = r"H:\Jason's Files\!NTY1T10XYZ\!!!\oon\Ambition\Projects\Personal\ReflectionGPT"
OUTPUT_FILE = "ReflectionGPT_FULL_EXPORT.md"

VALID_EXTENSIONS = {".md", ".txt"}

with open(OUTPUT_FILE, "w", encoding="utf-8") as out:
    out.write("# ReflectionGPT — Full Text Export\n\n")

    for root, dirs, files in os.walk(ROOT_DIR):
        for file in files:
            ext = os.path.splitext(file)[1].lower()
            if ext in VALID_EXTENSIONS:
                path = os.path.join(root, file)
                rel_path = os.path.relpath(path, ROOT_DIR)

                out.write("\n\n")
                out.write("----\n")
                out.write(f"## FILE: {rel_path}\n")
                out.write("----\n\n")

                try:
                    with open(path, "r", encoding="utf-8", errors="ignore") as f:
                        out.write(f.read())
                except Exception as e:
                    out.write(f"[ERROR READING FILE: {e}]\n")

print("Done. Output:", OUTPUT_FILE)
