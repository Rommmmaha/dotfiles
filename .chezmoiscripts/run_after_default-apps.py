#!/usr/bin/env python3
print("\n[#] run_after_default-apps.py")
import subprocess
import shutil
from pathlib import Path

APPS = {
    "text": "code.desktop",
    "image": "com.interversehq.qView.desktop",
    "browser": "zen.desktop",
    "media": "mpv.desktop",
    "file_manager": "org.kde.dolphin.desktop",
}
CUSTOM_OVERRIDES = {
    "inode/directory": APPS["file_manager"],
    "application/xml": APPS["text"],
    "application/json": APPS["text"],
    "application/x-zerosize": APPS["text"],
    "application/x-shellscript": APPS["text"],
    "text/html": APPS["browser"],
    "application/pdf": APPS["browser"],
    "application/x-bzpdf": APPS["browser"],
    "application/x-gzpdf": APPS["browser"],
    "application/x-lzpdf": APPS["browser"],
    "application/x-xzpdf": APPS["browser"],
    "x-scheme-handler/http": APPS["browser"],
    "x-scheme-handler/https": APPS["browser"],
}


def run(cmd):
    try:
        subprocess.run(cmd, shell=True, check=True, capture_output=True)
    except subprocess.CalledProcessError:
        pass


def get_system_mimetypes(prefix):
    mimetypes = []
    mime_file = Path("/usr/share/mime/types")
    if mime_file.exists():
        with open(mime_file, "r") as f:
            for line in f:
                if line.startswith(prefix):
                    mimetypes.append(line.strip())
    return mimetypes


def nuke_configs():
    print("[-] Nuking old configs and caches...")
    home = Path.home()
    files_to_remove = [
        home / ".config/mimeapps.list",
        home / ".local/share/applications/mimeapps.list",
    ]
    for f in files_to_remove:
        if f.exists():
            f.unlink()
    cache_dir = home / ".cache"
    for folder in cache_dir.glob("ksycoca*"):
        if folder.is_dir():
            shutil.rmtree(folder)
        else:
            folder.unlink()
    dolphin_cache = cache_dir / "dolphin"
    if dolphin_cache.exists():
        shutil.rmtree(dolphin_cache)


def rebuild():
    print("[+] Building fresh associations list...")
    associations = {}
    for mime in get_system_mimetypes("image/"):
        associations[mime] = APPS["image"]
    for mime in get_system_mimetypes("text/"):
        associations[mime] = APPS["text"]
    for category in ["video/", "audio/"]:
        for mime in get_system_mimetypes(category):
            associations[mime] = APPS["media"]
    for mime, app in CUSTOM_OVERRIDES.items():
        associations[mime] = app
    mimeapps_path = Path.home() / ".config/mimeapps.list"
    with open(mimeapps_path, "w") as f:
        f.write("[Default Applications]\n")
        for mime, app in sorted(associations.items()):
            f.write(f"{mime}={app}\n")
        f.write("\n[Added Associations]\n")
        for mime, app in sorted(associations.items()):
            f.write(f"{mime}={app};\n")
    print("[+] Finalizing with system tools...")
    run(f"xdg-settings set default-web-browser {APPS['browser']}")
    run("update-desktop-database ~/.local/share/applications")
    if shutil.which("kbuildsycoca6"):
        run("kbuildsycoca6 --noincremental")


if __name__ == "__main__":
    nuke_configs()
    rebuild()
    print("[!] SUCCESS: Default applications reset.")
