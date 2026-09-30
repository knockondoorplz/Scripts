import os
import sys

# The actual logic that reads the file and appends it to stacktext.txt
def process_single_file(file_path):
    directory = os.path.dirname(file_path)
    output_path = os.path.join(directory, "stacktext.txt")
    
    # Simple check: Skip if it's our own log or binary
    if "stacktext.txt" in file_path: return
    
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    with open(output_path, "a", encoding="utf-8") as out:
        out.write(f"\n\n--- STACKED: {os.path.basename(file_path)} ---\n")
        out.write(content)

# This block is what triggers the work when AHK runs the command
if __name__ == "__main__":
    if len(sys.argv) > 1:
        target = sys.argv[1]
        if os.path.isfile(target):
            process_single_file(target)
        elif os.path.isdir(target):
            # Loop through all files in folder if it's a directory
            for root, _, files in os.walk(target):
                for file in files:
                    # Filter: Only text-like extensions
                    if file.endswith(('.txt', '.md', '.ahk', '.py', '.ps1', '.html', '.htm', '.css', '.js', '.json', '.csv', '.tsx', '.yaml', '.log', '.xlsx', '.rtf', '.odt', '.conf', '.bat', '.h', '.cpp')):
                        process_single_file(os.path.join(root, file))