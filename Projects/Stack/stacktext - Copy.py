import os
import sys

def stack_files(directory):
    output_filename = "stacktext.txt"
    script_name = os.path.basename(__file__)
    
    output_path = os.path.join(directory, output_filename)
    
    # Define what we want
    valid_exts = {'.txt', '.md', '.html', '.css', '.js', '.json', '.py', '.ps1', '.ahk', '.yaml', '.log'}
    
    with open(output_path, "w", encoding="utf-8") as out:
        out.write("# stacktext\n\n")
        
        for root, dirs, files in os.walk(directory):
            for file in sorted(files):
                # 1. EXCLUSIONS: Skip the output file, this script, and any .lnk shortcuts
                if file == output_filename or file == script_name:
                    continue
                if file.lower().endswith('.lnk'):
                    continue
                
                # 2. Only process if it matches our list
                _, ext = os.path.splitext(file)
                if ext.lower() in valid_exts:
                    file_path = os.path.join(root, file)
                    rel_path = os.path.relpath(file_path, directory)
                    
                    try:
                        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                            content = f.read()
                            out.write(f"\n\n--- STACKED: {rel_path} ---\n")
                            out.write(content)
                            print(f"STACKED: {file}")
                    except Exception as e:
                        out.write(f"\n[ERROR STACKING {rel_path}: {e}]\n")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        stack_files(sys.argv[1])
    else:
        print("Usage: python stacktext.py <folder_path>")