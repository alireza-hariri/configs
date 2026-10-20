#!/usr/bin/env python3
"""add-ssh-server: Interactively add a new SSH host entry.

The entry goes to ~/.ssh/config.d/<name>.conf when ~/.ssh/config includes
that folder (see the ssh-config-d feature), otherwise it is appended to
~/.ssh/config.
"""

import glob
import os
import re
import sys
import shlex

CONFIG_DIR = os.path.expanduser("~/.ssh")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config")
CONFIG_D = os.path.join(CONFIG_DIR, "config.d")

# Separators accepted between a jump host and the destination.
JUMP_SEPARATORS = (" via ", "->", " jump ", " jumps through ", ";")


def parse_ssh_string(s):
    """Parse an SSH connection string.

    Accepts forms like:
        user@host[:port]
        user@host[:port] via jumper@jumphost[:jport]
        ssh [-J jumper@jumphost[:jport]] [-p port] [-l user] [user@]host

    Returns (user, host, port, jump) where any may be None.
    """
    s = s.strip()
    if not s:
        raise ValueError("empty connection string")

    user = host = port = jump = None

    # 1) Full ssh command line: strip the leading "ssh" and parse flags.
    if s.startswith(("ssh ", "ssh\t")):
        tokens = shlex.split(s)
        ssh_args = tokens[1:]
        destination = None
        i = 0
        while i < len(ssh_args):
            arg = ssh_args[i]
            if arg == "-J" and i + 1 < len(ssh_args):
                jump = ssh_args[i + 1]
                i += 2
            elif arg in ("-p", "-l") and i + 1 < len(ssh_args):
                value = ssh_args[i + 1]
                if arg == "-p":
                    port = value
                else:
                    user = value
                i += 2
            elif arg.startswith("-"):
                # Skip other options (and any value they take) conservatively.
                i += 1
            else:
                destination = arg
                i += 1
        if destination is None:
            raise ValueError("no destination found in ssh command")
        s = destination

    # 2) Optional jump separator: "<dest> via <jump>", "<dest>;<jump>", etc.
    for sep in JUMP_SEPARATORS:
        if sep in s:
            s, jump_str = (p.strip() for p in s.split(sep, 1))
            j_user, j_host, j_port = _parse_endpoint(jump_str)
            if not j_host:
                raise ValueError(f"could not parse jump endpoint: {jump_str!r}")
            jump = f"{j_user}@{j_host}" if j_user else j_host
            if j_port and j_port != "22":
                jump = f"{jump}:{j_port}"
            break

    # 3) Parse the destination into user / host / port.
    d_user, d_host, d_port = _parse_endpoint(s)
    if not d_host:
        raise ValueError(f"could not parse host from: {s!r}")

    user = user or d_user
    host = d_host
    port = port or d_port

    return user, host, port, jump


def _parse_endpoint(s):
    """Parse a [user@]host[:port] string. Host may be IPv6 wrapped in []."""
    m = re.match(
        r"^(?:(?P<user>[^@\s]+)@)?(?P<host>\[[^\]]+\]|[^:\s]+)(?::(?P<port>\d+))?$",
        s,
    )
    if not m:
        return None, None, None
    # ssh_config wants a bare IPv6 address in HostName, without brackets.
    return m.group("user"), m.group("host").strip("[]"), m.group("port")


def config_block_exists(name, config_text):
    """Return True if a Host block with this alias already exists."""
    for line in config_text.splitlines():
        m = re.match(r"^\s*Host\s+(.+?)\s*$", line)
        if not m:
            continue
        if name in m.group(1).split():
            return True
    return False


def read(path):
    try:
        with open(path, "r") as f:
            return f.read()
    except OSError:
        return ""


def uses_config_d(config_text):
    """True if ~/.ssh/config has an Include line for config.d/."""
    return re.search(r"^\s*Include\s+\S*config\.d/", config_text, re.M | re.I) is not None


def append_config(name, user, host, port, jump):
    os.makedirs(CONFIG_DIR, mode=0o700, exist_ok=True)

    main_text = read(CONFIG_FILE)
    for path in [CONFIG_FILE] + sorted(glob.glob(os.path.join(CONFIG_D, "*"))):
        if config_block_exists(name, read(path)):
            print(f"Error: a Host entry named '{name}' already exists in {path}")
            sys.exit(1)

    target = CONFIG_FILE
    if uses_config_d(main_text):
        os.makedirs(CONFIG_D, mode=0o700, exist_ok=True)
        target = os.path.join(CONFIG_D, f"{name}.conf")

    block_lines = [f"\nHost {name}", f"    HostName {host}"]
    if user:
        block_lines.append(f"    User {user}")
    if port:
        block_lines.append(f"    Port {port}")
    if jump:
        block_lines.append(f"    ProxyJump {jump}")

    block = "\n".join(block_lines) + "\n"

    with open(target, "a") as f:
        f.write(block)
    os.chmod(target, 0o600)

    print(f"\nAdded host '{name}' to {target}")


def main():
    name = input("Enter a name (alias) for this SSH host: ").strip()
    if not name:
        print("Error: name cannot be empty")
        sys.exit(1)
    if any(c.isspace() for c in name):
        print("Error: name must not contain whitespace")
        sys.exit(1)

    print("Enter the SSH connection string. Examples:")
    print("  user@host")
    print("  user@host:2222")
    print("  user@host:22 via jumper@jump.host:22")
    print("  ssh -J jumper@jump.host user@host:22")
    print("  ssh user@host -p 2222")

    s = input("> ").strip()
    if not s:
        print("Error: connection string cannot be empty")
        sys.exit(1)

    try:
        user, host, port, jump = parse_ssh_string(s)
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)

    print("\nParsed values:")
    print(f"  Host : {host}")
    print(f"  User : {user or '(default)'}")
    print(f"  Port : {port or '22'}")
    print(f"  Jump : {jump or '(none)'}")

    confirm = input("\nAdd this entry? [Y/n] ").strip().lower()
    if confirm in ("n", "no"):
        print("Cancelled.")
        sys.exit(0)

    append_config(name, user, host, port, jump)
    print(f"You can now connect with: ssh {name}")


if __name__ == "__main__":
    main()
