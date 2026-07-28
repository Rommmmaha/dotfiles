#!/usr/bin/env python3
print("\n[#] flatpak-gtk-override.py")
import configparser
import shutil
import subprocess
import sys


def is_flatpak_installed():
    return shutil.which("flatpak") is not None


def main():
    if not is_flatpak_installed():
        print("[!] Flatpak is not installed or not in your PATH.")
        sys.exit(1)
    print("[+] Flatpak is installed. Checking global user overrides...")
    try:
        result = subprocess.run(
            ["flatpak", "override", "--user", "--show"],
            capture_output=True,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        print(f"[!] Error while checking flatpak overrides: {e}")
        sys.exit(1)
    config = configparser.ConfigParser()
    config.read_string(result.stdout)
    existing_filesystems = []
    if config.has_section("Context") and config.has_option("Context", "filesystems"):
        fs_string = config.get("Context", "filesystems")
        existing_filesystems = [fs.strip() for fs in fs_string.split(";") if fs.strip()]
    required_overrides = ["xdg-config/gtk-3.0:ro", "xdg-config/gtk-4.0:ro"]
    missing_overrides = [fs for fs in required_overrides if fs not in existing_filesystems]
    if not missing_overrides:
        print("[+] All required GTK filesystem overrides are already present. Nothing to do.")
        return
    print(f"[+] Missing filesystem overrides detected: {missing_overrides}")
    print("[+] Adding missing overrides...")
    cmd = ["flatpak", "override", "--user"]
    for fs in missing_overrides:
        cmd.append(f"--filesystem={fs}")
    try:
        subprocess.run(cmd, check=True)
        print("[+] Successfully added the required overrides!")
    except subprocess.CalledProcessError as e:
        print(f"[!] Failed to add overrides. Command exited with error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
