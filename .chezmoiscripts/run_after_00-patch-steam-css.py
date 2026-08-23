#!/usr/bin/env python3
print("\n[#] patch-steam-css.py")
import colorsys
import re
import shutil
import sys
from pathlib import Path

ROOT_DIR = Path.home() / ".local/share/Steam/steamui/css"
BACKUP_DIR = ROOT_DIR / "backup"
HIDE_CLASS = "_17uEBe5Ri8TMsnfELvs8-N"
HIDE_ELEMENT = True
NORMALIZE_COLORS_TO_HEX = True
RECOLOR_MAP = {
    "#151616": "#000000",
    "#151f25": "#000000",
    "#171d25": "#000000",
    "#1c1d22": "#000000",
    "#1c232c": "#000000",
    "#1d1d1d": "#000000",
    "#1e2025": "#000000",
    "#20242b": "#000000",
    "#212329": "#000000",
    "#22252b": "#000000",
    "#222b35": "#000000",
    "#23262e": "#000000",
    "#23272d": "#000000",
    "#24282f": "#000000",
    "#25272d": "#111111",
    "#25282e": "#111111",
    "#252e38": "#000000",
    "#272c35": "#000000",
    "#292f3b": "#111111",
    "#2a2d34": "#000000",
    "#2a2e36": "#111111",
    "#2b3942": "#000000",
    "#2c3037": "#111111",
    "#2c323d": "#000000",
    "#2d333c": "#000000",
    "#313d53": "#000000",
    "#3a3e46": "#111111",
    "#3d4450": "#222222",
    "#3e4047": "#111111",
    "#434953": "#000000",
    "#4a515c": "#111111",
}
HIDE_OLD = f"}}.{HIDE_CLASS}{{box-sizing:border-box"
HIDE_NEW = f"}}.{HIDE_CLASS}{{display:none"
COLOR_TOKEN_RE = re.compile(
    r"#(?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{4}|[0-9a-fA-F]{3})\b"
    r"|\b(?:rgba?|hsla?)\([^()]*\)",
    re.IGNORECASE,
)


def _expand_hex(h):
    return "".join(c * 2 for c in h) if len(h) in (3, 4) else h


def parse_hex(h):
    h = _expand_hex(h)
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    a = int(h[6:8], 16) if len(h) == 8 else 255
    return r, g, b, a


def _channel(token, is_alpha=False):
    token = token.strip()
    if token.endswith("%"):
        frac = float(token[:-1]) / 100.0
        return frac if is_alpha else round(frac * 255)
    val = float(token)
    return val if is_alpha else round(val)


def parse_function(func, args_str):
    func = func.lower()
    main_part, alpha_part = args_str.split("/", 1) if "/" in args_str else (args_str, None)
    parts = [p for p in re.split(r"[\s,]+", main_part.strip()) if p]
    if func.startswith("hsl"):
        h = (float(parts[0].rstrip("deg")) % 360) / 360.0
        s = _channel(parts[1], is_alpha=True)
        l = _channel(parts[2], is_alpha=True)
        r, g, b = (round(c * 255) for c in colorsys.hls_to_rgb(h, l, s))
    else:
        r, g, b = _channel(parts[0]), _channel(parts[1]), _channel(parts[2])
    if alpha_part is not None:
        a_frac = _channel(alpha_part, is_alpha=True)
        a = round(a_frac * 255) if a_frac <= 1 else round(a_frac)
    elif len(parts) == 4:
        a_frac = _channel(parts[3], is_alpha=True)
        a = round(a_frac * 255) if a_frac <= 1 else round(a_frac)
    else:
        a = 255
    return r, g, b, max(0, min(255, a))


def color_to_hex(r, g, b, a=255):
    r, g, b, a = (max(0, min(255, c)) for c in (r, g, b, a))
    channels = [f"{c:02x}" for c in (r, g, b)] if a == 255 else [f"{c:02x}" for c in (r, g, b, a)]
    if all(ch[0] == ch[1] for ch in channels):
        return "#" + "".join(ch[0] for ch in channels)
    return "#" + "".join(channels)


def make_color_replacer(color_map, normalize):
    def _replace(m):
        token = m.group(0)
        if token.startswith("#"):
            r, g, b, a = parse_hex(token[1:])
        else:
            func, rest = token.split("(", 1)
            r, g, b, a = parse_function(func, rest[:-1])
        target = color_map.get((r, g, b))
        if target is not None:
            return color_to_hex(target[0], target[1], target[2], a)
        return color_to_hex(r, g, b, a) if normalize else token

    return _replace


def build_color_map():
    color_map = {}
    for old_spec, new_spec in RECOLOR_MAP.items():
        old_r, old_g, old_b, _ = parse_hex(old_spec.strip().lstrip("#"))
        new_r, new_g, new_b, _ = parse_hex(new_spec.strip().lstrip("#"))
        color_map[(old_r, old_g, old_b)] = (new_r, new_g, new_b)
    return color_map


def sync_backup():
    if not ROOT_DIR.exists():
        print(f"[!] Root directory not found: {ROOT_DIR}")
        sys.exit(1)
    root_files = {p.name for p in ROOT_DIR.iterdir() if p.is_file()}
    if BACKUP_DIR.exists():
        backup_files = {p.name for p in BACKUP_DIR.iterdir() if p.is_file()}
        if root_files != backup_files:
            shutil.rmtree(BACKUP_DIR)
    if not BACKUP_DIR.exists():
        BACKUP_DIR.mkdir(parents=True, exist_ok=True)
        for name in root_files:
            shutil.copy2(ROOT_DIR / name, BACKUP_DIR / name)


def process_file(backup_path: Path, root_path: Path, color_map: dict):
    source_bytes = backup_path.read_bytes()
    source_size = len(source_bytes)
    css = source_bytes.decode("utf-8", errors="ignore")
    hidden = False
    if HIDE_ELEMENT and HIDE_OLD in css:
        css = css.replace(HIDE_OLD, HIDE_NEW, 1)
        hidden = True
    colors_modified = 0
    if NORMALIZE_COLORS_TO_HEX or color_map:
        css, colors_modified = COLOR_TOKEN_RE.subn(make_color_replacer(color_map, NORMALIZE_COLORS_TO_HEX), css)
    patched_bytes = css.encode("utf-8")
    if len(patched_bytes) > source_size:
        diff = len(patched_bytes) - source_size
        print(f"[!] {backup_path.name}: Patched content is {diff}B larger than original. Skipped.")
        return
    elif len(patched_bytes) < source_size:
        patched_bytes += b" " * (source_size - len(patched_bytes))
    root_path.write_bytes(patched_bytes)
    status = []
    if hidden:
        status.append("hidden class")
    if colors_modified:
        status.append(f"{colors_modified} colors")
    detail = f" ({', '.join(status)})" if status else ""
    print(f"[+] Patched {backup_path.name}{detail}")


def main():
    sync_backup()
    color_map = build_color_map()
    backup_files = [p for p in BACKUP_DIR.iterdir() if p.is_file()]
    for backup_file in backup_files:
        process_file(backup_file, ROOT_DIR / backup_file.name, color_map)


if __name__ == "__main__":
    main()
