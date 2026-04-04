#!/usr/bin/env python3
import sys,os
launch_cmd =[
    "gamescope",
    "-w", "1920",
    "-h", "1080",
    "-S", "stretch"
]
args = sys.argv[1:]
game_args = []
while args:
    arg = args.pop(0)
    if arg == "--umu":
        os.environ["STEAM_COMPAT_DATA_PATH"] = os.path.expanduser("~/Games/umu/umu-default")
    elif arg == "--sdl":
        launch_cmd.extend(["--backend", "sdl"])
    elif arg == "--lang":
        os.environ["XKB_DEFAULT_LAYOUT"] = "us,ua"
        os.environ["XKB_DEFAULT_OPTIONS"] = "grp:caps_toggle"
    elif arg == "--grab":
        launch_cmd.append("--force-grab-cursor")
    else:
        game_args.append(arg)
        game_args.extend(args)
        break
launch_cmd.extend(["--", "gamemoderun"])
launch_cmd.extend(game_args)
os.execvp(launch_cmd[0], launch_cmd)