#!/usr/bin/env python3
import sys
import os
import json
import shutil
import subprocess
import collections.abc
import shlex
from copy import deepcopy
from typing import Dict, Any

CONFIG_PATH = os.path.expanduser("~/.config/r_game.json")
DEFAULT_CONFIG_FILE = {
    "apps": {
        "0": {"!env": {"STEAM_COMPAT_DATA_PATH": "~/Games/umu/umu-default"}},
    },
    "default": {
        "!env": {},
        "gamemoderun": {"enable": True},
        "gamescope": {
            "enable": True,
            "--nested-width": "1920",
            "--nested-height": "1080",
            "--scaler": "stretch",
            "--backend": "wayland",
            "--expose-wayland": True,
        },
    },
    "order": 'env LD_PRELOAD="" gamescope -- env -u LD_PRELOAD gamemoderun',
}


def deep_update(d: dict, u: dict) -> dict:
    for k, v in u.items():
        if isinstance(v, collections.abc.Mapping):
            d[k] = deep_update(d.get(k, {}), v)
        else:
            d[k] = v
    return d


def get_appid() -> str:
    """Extracts Steam AppID from environment or arguments."""
    if "SteamAppId" in os.environ:
        return os.environ["SteamAppId"]
    for arg in sys.argv:
        if "AppId=" in arg:
            return arg.split("AppId=")[1].split()[0].rstrip(",")
    return "unknown"


def load_config(appid: str) -> Dict[str, Any]:
    """Loads and merges the correct configuration for the given AppID."""
    active_config = {}
    if not os.path.exists(CONFIG_PATH):
        try:
            os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)
            with open(CONFIG_PATH, "w") as f:
                json.dump(DEFAULT_CONFIG_FILE, f, indent=4)
        except Exception as e:
            print(
                f"Warning: Could not create default config file: {e}", file=sys.stderr
            )
        user_data = DEFAULT_CONFIG_FILE
    else:
        try:
            with open(CONFIG_PATH, "r") as f:
                user_data = json.load(f)
        except Exception as e:
            print(f"Error reading {CONFIG_PATH}: {e}", file=sys.stderr)
            user_data = DEFAULT_CONFIG_FILE
    if "order" in user_data:
        active_config["order"] = user_data["order"]
    if "default" in user_data:
        deep_update(active_config, user_data["default"])
    if appid != "unknown" and "apps" in user_data and appid in user_data["apps"]:
        deep_update(active_config, user_data["apps"][appid])
    return active_config


def send_notification(title: str, message: str) -> None:
    if shutil.which("notify-send"):
        subprocess.run(["notify-send", title, message])
    else:
        print(f"--- {title} ---\n{message}")


def main() -> None:
    args = sys.argv[1:]
    appid = get_appid()
    debug_mode = False
    if "--debug" in args:
        args.remove("--debug")
        debug_mode = True
    if not args:
        print("Error: No game command detected.", file=sys.stderr)
        sys.exit(1)
    config = load_config(appid)
    env = os.environ.copy()
    env_cfg = config.get("!env", {})
    for k, v in env_cfg.items():
        val = str(v)
        if val.startswith("~/"):
            val = os.path.expanduser(val)
        env[k] = val
    launch_cmd = []
    order_val = config.get("order", "")
    order = order_val.split() if isinstance(order_val, str) else list(order_val)
    for tool in order:
        tool_cfg = config.get(tool)
        if tool_cfg is None:
            launch_cmd.append(tool)
            continue
        if tool_cfg.get("enable", True) is False:
            continue
        launch_cmd.append(tool)
        for k, v in tool_cfg.items():
            if k == "enable":
                continue
            if isinstance(v, bool):
                if v is True:
                    launch_cmd.append(k)
            elif v == "":
                launch_cmd.append(k)
            else:
                launch_cmd.extend([k, str(v)])
    launch_cmd.extend(args)
    postfix = config.get("postfix", "")
    if postfix:
        if isinstance(postfix, str):
            launch_cmd.extend(shlex.split(postfix))
        elif isinstance(postfix, list):
            launch_cmd.extend(postfix)
    if debug_mode:
        env_str = ",".join([f'"{k}":"{v}"' for k, v in env_cfg.items()])
        msg = (
            f"AppID Detected: {appid}\n"
            f"Env: {env_str}\n"
            f"Command:\n{' '.join(launch_cmd)}"
        )
        send_notification("Game Wrapper Debug", msg)
        print(f"\n[DEBUG ENV SETTINGS]\nenv: {env_str}")
        print(f"[DEBUG LAUNCH CMD]\n{' '.join(launch_cmd)}\n")
        sys.exit(0)
    if not launch_cmd:
        print("Error: Final launch command is empty.", file=sys.stderr)
        sys.exit(1)
    try:
        os.execvpe(launch_cmd[0], launch_cmd, env)
    except Exception as e:
        print(f"Error launching game: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
