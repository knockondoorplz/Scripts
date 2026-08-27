import os

FOLDER = r"C:\Users\brigi\Desktop\New folder"

for root, dir, files in os.walk(FOLDER):
    for filename in files:
        if filename.endswith(".txt"):
            old_path = os.path.join(root, filename)
            
            name, ext = os.path.splitext(filename)
            new_filename = name + ".md"
            new_path = os.path.join(root, new_filename)
            
            os.rename(old_path, new_path)

print("Recursive conversion complete.")