import os
import sys
import win32gui
import win32com.client
from mutagen import File


AUDIO_EXTENSIONS = {
    ".mp3",
    ".flac",
    ".wav",
    ".m4a",
    ".ogg",
    ".aac"
}


def get_active_explorer_path():

    shell = win32com.client.Dispatch("Shell.Application")

    print("\nExplorer windows:\n")

    windows = []

    for i, window in enumerate(shell.Windows()):
        try:
            path = window.Document.Folder.Self.Path
            windows.append(path)
            print(f"{i}: {path}")
        except:
            pass

    print()

    return windows[-1] if windows else None


def get_audio_files(folder):
    files = []

    for root, dirs, filenames in os.walk(folder):
        for filename in filenames:
            ext = os.path.splitext(filename)[1].lower()

            if ext in AUDIO_EXTENSIONS:
                files.append(
                    os.path.join(root, filename)
                )

    return files


def update_library(root_folder):

    print("Scanning:", root_folder)
    print()

    for current_folder, dirs, files in os.walk(root_folder):

        audio_files = [
            f for f in files
            if os.path.splitext(f)[1].lower() in AUDIO_EXTENSIONS
        ]

        if not audio_files:
            continue

        album = os.path.basename(current_folder)
        artist = os.path.basename(
            os.path.dirname(current_folder)
        )

        print("=" * 50)
        print("Artist:", artist)
        print("Album :", album)
        print()

        for filename in audio_files:

            path = os.path.join(
                current_folder,
                filename
            )

            try:
                print(path)
                audio = File(path, easy=True)
                print(current_folder)
                if audio is None:
                    continue

                audio["artist"] = artist
                audio["album"] = album

                print("Saving...", filename)

                audio.save()

                print("Done")

                print("✓", filename)

            except Exception as e:
                print("FAILED:", filename)
                print(e)


if __name__ == "__main__":

    if len(sys.argv) > 1:
        folder = sys.argv[1]
    else:
        folder = get_active_explorer_path()

    if not folder:
        print("No folder found.")
        input()
        exit()

    update_library(folder)

    print()
    print("DONE.")
    input()