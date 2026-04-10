#!/usr/bin/env python3
import subprocess
import re
import time
import sys
def run_command(command, capture_output=True, text=True):
    return subprocess.run(command, capture_output=capture_output, text=text, check=True)
def find_device():
    avahi_command = [
        "avahi-browse",
        "--resolve",
        "--terminate",
        "_adb-tls-connect._tcp",
    ]
    result = run_command(avahi_command)
    output = result.stdout
    match = re.search(
        r"=.*?IPv4.*?\n.*?address = \[([^\]]+)\].*?\n.*?port = \[(\d+)\]",
        output,
        re.DOTALL,
    )
    if not match:
        return None
    ip_address = match.group(1)
    port = match.group(2)
    print(f"--> Found device at {ip_address}:{port}")
    return f"{ip_address}:{port}"
def connect_adb(address):
    run_command(["adb", "disconnect"])
    adb_command = ["adb", "connect", address]
    result = run_command(adb_command)
    output = result.stdout
    if "connected to" in output or "already connected to" in output:
        return True
    else:
        raise ConnectionError(f"Failed to connect with ADB. Output: {output}")
def start_scrcpy():
    scrcpy_command = ["scrcpy", "--no-window", "--no-video", "--audio-bit-rate", "8M"]
    subprocess.run(scrcpy_command)
    print("-> scrcpy has been closed.")
def main():
    while True:
        try:
            print("Step 1:\tSearching for device with avahi-browse...")
            device_address = None
            while device_address is None:
                device_address = find_device()
                time.sleep(1)
            print(f"Step 2:\tConnecting with 'adb connect {device_address}'...")
            if connect_adb(device_address):
                print(f"-> Successfully connected to {device_address}")
            print("Step 3:\tStarting scrcpy...")
            start_scrcpy()
        except Exception as e:
            print(f"\nERROR: {e}", file=sys.stderr)
if __name__ == "__main__":
    main()