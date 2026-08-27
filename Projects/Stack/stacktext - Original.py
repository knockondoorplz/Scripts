import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_FILE = "stacktext.txt"
VALID_EXTENSIONS = {
    ".txt",
    ".md",
    ".html",
    ".htm",
    ".css",
    ".js",
    ".json",
    ".py",
    ".ps1",
    ".ahk",
    ".tsx",
    ".yaml",
    ".log",
    ".reg",
    ".xlsx",
    ".rtf",
    ".odt",
}

print("Running in:", SCRIPT_DIR)

files_found = 0

with open(os.path.join(SCRIPT_DIR, OUTPUT_FILE), "w", encoding="utf-8") as out:
    out.write("# stacktext\n\n")

    for root, dirs, files in os.walk(SCRIPT_DIR):
        for file in sorted(files):
            if file in {OUTPUT_FILE, os.path.basename(__file__)}:
                continue

            ext = os.path.splitext(file)[1].lower()
            if ext in VALID_EXTENSIONS:
                files_found += 1

                path = os.path.join(root, file)
                rel_path = os.path.relpath(path, SCRIPT_DIR)

                out.write("\n\n----\n")
                out.write(f"## FILE: {rel_path}\n")
                out.write("----\n\n")

                try:
                    with open(path, "r", encoding="utf-8", errors="ignore") as f:
                        out.write(f.read())
                except Exception as e:
                    out.write(f"[ERROR READING FILE: {e}]\n")

print("Done.")
print("Files stacked:", files_found)
print("Output:", OUTPUT_FILE)
