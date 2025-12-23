import subprocess
import json
import time
import sys


def get_open_window_classes():
    try:
        result = subprocess.run(
            ["hyprctl", "clients", "-j"], capture_output=True, text=True, check=True
        )
        clients = json.loads(result.stdout)
        return {client["class"] for client in clients if client["class"]}
    except Exception as e:
        print(f"Error getting clients: {e}", file=sys.stderr)
        return set()


def move_window(window_class, workspace):
    print(f"Moving {window_class} to workspace {workspace}...")
    try:
        cmd = f"dispatch movetoworkspacesilent {workspace},class:^({window_class})$"
        subprocess.run(["hyprctl", "--batch", cmd], check=False)
    except Exception as e:
        print(f"Failed to move {window_class}: {e}", file=sys.stderr)


def main():
    subprocess.run(["hyprctl", "dispatch", "workspace", "2"], check=False)

    STATE_WAITING_FIRST = 0
    STATE_SEEN_FIRST = 1
    STATE_FIRST_GONE = 2

    rules = [
        {
            "classes": ["Vivaldi-stable", "vivaldi-snapshot"],
            "workspace": 3
        },
        {
            "classes": ["org.telegram.desktop", "org.ayugram.desktop"],
            "workspace": 1
        },
        {
            "classes": ["discord"],
            "workspace": 1,
            "wait_for_reopen": True,
            "state": STATE_WAITING_FIRST
        },
        {
            "classes": ["kitty"],
            "workspace": 10
        },
        {
            "classes": ["com.saivert.pwvucontrol", "org.pulseaudio.pavucontrol"],
            "workspace": 10,
        },
    ]

    while rules:
        current_windows = get_open_window_classes()

        for rule in rules[:]:
            found_class = next((cls for cls in rule["classes"] if cls in current_windows), None)
            if rule.get("wait_for_reopen"):
                state = rule.get("state", STATE_WAITING_FIRST)

                if state == STATE_WAITING_FIRST:
                    if found_class:
                        rule["state"] = STATE_SEEN_FIRST

                elif state == STATE_SEEN_FIRST:
                    if not found_class:
                        rule["state"] = STATE_FIRST_GONE

                elif state == STATE_FIRST_GONE:
                    if found_class:
                        move_window(found_class, rule["workspace"])
                        rules.remove(rule)

            else:
                if found_class:
                    move_window(found_class, rule["workspace"])
                    rules.remove(rule)

        time.sleep(0.5)


if __name__ == "__main__":
    main()