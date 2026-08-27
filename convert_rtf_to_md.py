import os
import subprocess

pandoc = r"C:\Users\brigi\AppData\Local\Pandoc\pandoc.exe"

folder = r"C:\Users\brigi\Desktop\Pages"

for file in os.listdir(folder):
    if file.endswith(".rtf"):
        rtf = os.path.join(folder, file)
        md = os.path.join(folder, file.replace(".rtf", ".md"))

        subprocess.run([
            pandoc,
            rtf,
            "-f","rtf",
            "-t","gfm",
            "-o",md
        ])