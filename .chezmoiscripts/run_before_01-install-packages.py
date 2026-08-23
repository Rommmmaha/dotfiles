#!/usr/bin/env python3
print("\n[#] install-packages.py")
import subprocess
from pathlib import Path

PKG_DIR = Path.home() / ".local/share/chezmoi/.packages"


def run(cmd, check=True, capture=True):
    try:
        r = subprocess.run(cmd, capture_output=capture, check=check, text=True)
        return r.stdout.strip().splitlines() if capture else ""
    except subprocess.CalledProcessError:
        return []


def read_pkgs(filename):
    path = PKG_DIR / filename
    return [l.strip() for l in path.read_text().splitlines() if l.strip()] if path.exists() else []


def missing_pacman(pkgs):
    lines = run(["pacman", "-Q"])
    installed = {l.split()[0] for l in lines} if lines else set()
    return [p for p in pkgs if p not in installed]


def missing_flatpak(pkgs):
    lines = run(["flatpak", "list", "--columns=application"])
    installed = set(lines) if lines else set()
    return [p for p in pkgs if p not in installed]


def install_pacman(pkgs):
    if pkgs:
        subprocess.run(["sudo", "pacman", "-S", "--needed", "--noconfirm", *pkgs], check=True)


def install_aur(pkgs):
    if pkgs:
        subprocess.run(["yay", "-S", "--needed", "--noconfirm", *pkgs], check=True)


def install_flatpak(pkgs):
    if pkgs:
        subprocess.run(["flatpak", "install", "-y", *pkgs], check=True)


def main():
    pacman_pkgs = read_pkgs("packages.txt")
    mp = missing_pacman(pacman_pkgs)
    if mp:
        print(f"[!] Installing missing packages: {' '.join(mp)}")
        install_pacman(mp)

    aur_pkgs = read_pkgs("aur.txt")
    ma = missing_pacman(aur_pkgs)
    if ma:
        print(f"[!] Installing missing AUR: {' '.join(ma)}")
        install_aur(ma)

    flatpak_pkgs = read_pkgs("flatpak.txt")
    mf = missing_flatpak(flatpak_pkgs)
    if mf:
        print(f"[!] Installing missing flatpak: {' '.join(mf)}")
        install_flatpak(mf)

    if not any([mp, ma, mf]):
        print("[+] All packages already installed")


if __name__ == "__main__":
    main()
