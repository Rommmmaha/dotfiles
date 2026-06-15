#!/usr/bin/env python3
print("\n[#] patch-steam-css.py")
import sys
from pathlib import Path

STEAM_CSS = Path.home() / ".local/share/Steam/steamui/css/chunk~2dcc5aaf7.css"
HIDE_CLASS = "_17uEBe5Ri8TMsnfELvs8-N"

OLD_RULE = f"}}.{HIDE_CLASS}{{box-sizing:border-box"
NEW_RULE = f"}}.{HIDE_CLASS}{{display:none;--x:none"

if not STEAM_CSS.exists():
    print(f"[!] Target file does not exist: {STEAM_CSS}")
    sys.exit(0)

css = STEAM_CSS.read_text(errors="ignore")
occurrences = css.count(OLD_RULE)

if occurrences == 0:
    print(f"[!] Pattern not found in {STEAM_CSS.name}")
    sys.exit(0)

patched_css = css.replace(OLD_RULE, NEW_RULE)
STEAM_CSS.write_text(patched_css, newline="\r\n")
print(f"[+] Patched {occurrences} occurrence(s) in {STEAM_CSS.name}")
