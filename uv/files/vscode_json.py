#!/usr/bin/env python3
"""Merge or un-merge VS Code settings.json / keybindings.json.

  vscode_json.py merge-settings TARGET SRC STATE
  vscode_json.py revert-settings TARGET SRC STATE
  vscode_json.py merge-keys TARGET SRC STATE
  vscode_json.py revert-keys TARGET SRC STATE

STATE records what was there before, so revert only undoes our own keys
and leaves anything the user changed since then alone. VS Code files are
JSON with comments; comments are dropped when the file is rewritten (the
apply step keeps a full backup).
"""
import json
import os
import sys


def strip_jsonc(text):
    """Remove // and /* */ comments and trailing commas, outside strings."""
    out, i, n, in_str = [], 0, len(text), False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == "\\":
                out.append(text[i + 1 : i + 2])
                i += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True
            out.append(c)
        elif text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
            continue
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = n if end < 0 else end + 2
            continue
        else:
            out.append(c)
        i += 1
    s = "".join(out)
    # Second pass, again skipping strings: drop commas right before } or ].
    res, in_str, i = [], False, 0
    while i < len(s):
        c = s[i]
        if in_str:
            res.append(c)
            if c == "\\":
                res.append(s[i + 1 : i + 2])
                i += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True
            res.append(c)
        elif c == ",":
            j = i + 1
            while j < len(s) and s[j] in " \t\r\n":
                j += 1
            if j < len(s) and s[j] in "}]":
                i += 1
                continue
            res.append(c)
        else:
            res.append(c)
        i += 1
    return "".join(res)


def load(path, default):
    try:
        with open(path, encoding="utf-8") as f:
            text = f.read()
    except FileNotFoundError:
        return default
    text = strip_jsonc(text).strip()
    return json.loads(text) if text else default


def save(path, data):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, path)


def merge_settings(target, src, state_path):
    cur, ours = load(target, {}), load(src, {})
    state = load(state_path, {})  # key -> {"had": bool, "old": value}
    for k, v in ours.items():
        if k not in state:
            state[k] = {"had": k in cur, "old": cur.get(k)}
        cur[k] = v
    save(target, cur)
    save(state_path, state)
    print(f"  set {len(ours)} settings in {target}")


def revert_settings(target, src, state_path):
    cur, ours, state = load(target, {}), load(src, {}), load(state_path, {})
    skipped = []
    for k, prev in state.items():
        if k in cur and k in ours and cur[k] != ours[k]:
            skipped.append(k)  # changed by the user since; leave it
            continue
        if prev["had"]:
            cur[k] = prev["old"]
        else:
            cur.pop(k, None)
    save(target, cur)
    print(f"  restored {len(state) - len(skipped)} settings in {target}")
    for k in skipped:
        print(f"  kept '{k}': you changed it after install")


def merge_keys(target, src, state_path):
    cur, ours = load(target, []), load(src, [])
    state = load(state_path, {"added": []})
    for entry in ours:
        if entry not in cur:
            cur.append(entry)
            if entry not in state["added"]:
                state["added"].append(entry)
    save(target, cur)
    save(state_path, state)
    print(f"  {len(state['added'])} keybinding(s) added to {target}")


def revert_keys(target, src, state_path):
    cur, state = load(target, []), load(state_path, {"added": []})
    cur = [e for e in cur if e not in state["added"]]
    save(target, cur)
    print(f"  removed {len(state['added'])} keybinding(s) from {target}")


if __name__ == "__main__":
    cmd, target, src, state = sys.argv[1:5]
    {
        "merge-settings": merge_settings,
        "revert-settings": revert_settings,
        "merge-keys": merge_keys,
        "revert-keys": revert_keys,
    }[cmd](target, src, state)
