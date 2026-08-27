import os
from ftplib import FTP

# ==========================================
# 👇 YOUR CONFIRMED VALUES 👇
# ==========================================
FTP_HOST = "192.168.88.2"
FTP_PORT = 21
LOCAL_MUSIC_DIR = r"C:\Users\brigi\Desktop\New folder\Music" 
# ==========================================

def upload_directory_step_by_step(ftp, current_local_dir):
    try:
        items = os.listdir(current_local_dir)
    except Exception as e:
        print(f"❌ Could not read local directory {current_local_dir}: {e}")
        return

    for item in items:
        local_item_path = os.path.join(current_local_dir, item)
        
        if os.path.isdir(local_item_path):
            # Clean up the folder name slightly just in case
            clean_folder_name = item.replace(':', '').replace('*', '').replace('?', '')
            print(f"📁 Entering/Creating folder: {clean_folder_name}")
            
            try:
                ftp.mkd(clean_folder_name)
            except Exception:
                pass # Folder already exists
            
            try:
                ftp.cwd(clean_folder_name) # STEP INTO the folder on the phone
                upload_directory_step_by_step(ftp, local_item_path) # Dive recursively
                ftp.cwd("..") # STEP BACK OUT on the phone
            except Exception as e:
                print(f"⚠️ Failed to navigate folder {clean_folder_name}: {e}")
                try:
                    ftp.cwd("..")
                except:
                    pass
        else:
            # Skip hidden system clutter
            if item.lower() in ['desktop.ini', 'thumbs.db']:
                continue
                
            # Clean up the filename for the phone's fragile parser
            clean_file_name = item.replace(':', '').replace('*', '').replace('?', '').replace('：', ' ')
            
            print(f"🎵 Sending file: {clean_file_name}")
            try:
                with open(local_item_path, "rb") as f:
                    # Because we used cwd(), we just send the raw filename! No paths!
                    ftp.storbinary(f"STOR {clean_file_name}", f)
            except Exception as e:
                print(f"❌ Failed to send {item}: {e}")

try:
    print("🚀 Connecting to iPhone...")
    ftp = FTP()
    ftp.connect(FTP_HOST, FTP_PORT, timeout=15)
    ftp.login() 
    ftp.encoding = "utf-8"
    
    print("📂 Verifying local music directory...")
    if not os.path.exists(LOCAL_MUSIC_DIR):
        print(f"❌ CRITICAL: Path '{LOCAL_MUSIC_DIR}' does not exist!")
        input("\nPress Enter to close...")
        exit()
        
    os.chdir(LOCAL_MUSIC_DIR)
    
    print("⚡ Transferring folders and files via step-by-step navigation...")
    upload_directory_step_by_step(ftp, LOCAL_MUSIC_DIR)
    
    ftp.quit()
    print("✨ Sync Complete! Everything is perfectly organized.")
    input("\nPress Enter to close...")
except Exception as e:
    print(f"❌ Connection failed: {e}")
    input("\nPress Enter to close...")