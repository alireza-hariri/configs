#!/usr/bin/env python3

"""create-desktop: make a ~/.local/share/applications launcher for a program."""

import os
import shlex
import subprocess
import sys

def main():
    app_path = os.path.abspath(os.path.expanduser(input("Enter full path to application: ").strip()))
    if not os.path.exists(app_path):
        print(f"Error: '{app_path}' does not exist.")
        sys.exit(1)

    app_name = os.path.basename(app_path)
    name = input(f"Enter application name [{app_name}]: ").strip() or app_name

    icon = input("Enter path to icon image (png/svg) or leave blank for none: ").strip()
    if icon:
        icon = os.path.abspath(os.path.expanduser(icon))
    if icon and not os.path.exists(icon):
        print(f"Warning: '{icon}' not found, proceeding without icon.")
        icon = ""

    categories = input("Enter categories (e.g. Utility;Development;) [Utility;]: ").strip() or "Utility;"
    if not categories.endswith(";"):
        categories += ";"

    desktop_dir = os.path.expanduser("~/.local/share/applications")
    os.makedirs(desktop_dir, exist_ok=True)

    safe_name = name.replace(" ", "-").lower()
    desktop_file = os.path.join(desktop_dir, f"{safe_name}.desktop")

    lines = [
        "[Desktop Entry]",
        "Type=Application",
        f"Name={name}",
        # Quoted, so paths with spaces work.
        f"Exec={shlex.quote(app_path)}",
        "Terminal=false",
        f"Categories={categories}",
    ]
    if icon:
        lines.append(f"Icon={icon}")

    with open(desktop_file, "w") as f:
        f.write("\n".join(lines) + "\n")

    os.chmod(desktop_file, 0o755)
    print(f"\nCreated: {desktop_file}")
    # Make it show up in the app menu right away.
    for cmd in (["update-desktop-database", desktop_dir], ["kbuildsycoca6"]):
        try:
            subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        except FileNotFoundError:
            pass

if __name__ == "__main__":
    main()
