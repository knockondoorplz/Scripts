import os
import sys

if len(sys.argv) < 2:
    print("No directory argument passed.")
    print("Usage: python stacktext.py <folder>")
    input("Press Enter to exit...")
    sys.exit(1)

SCRIPT_DIR = sys.argv[1]

print("ARG:", SCRIPT_DIR)
print("CWD:", os.getcwd())
print("SCRIPT FILE:", __file__)
print("Running in:", SCRIPT_DIR)



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
    ".csv",
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
print("---- scanning ----")

files_found = 0
all_seen = 0

with open(os.path.join(SCRIPT_DIR, OUTPUT_FILE), "w", encoding="utf-8") as out:
    out.write("# stacktext\n\n")

    for root, dirs, files in os.walk(SCRIPT_DIR):
        for file in sorted(files):
            all_seen += 1
            print("Saw file:", file)

            if file in {OUTPUT_FILE, os.path.basename(__file__)}:
                print("Skipped (self/output):", file)
                continue

            ext = os.path.splitext(file)[1].lower()
            print("Extension:", ext)

            if ext in VALID_EXTENSIONS:
                print("STACKING:", file)
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

print("---- done ----")
print("Total seen:", all_seen)
print("Files stacked:", files_found)
print("Output:", OUTPUT_FILE)