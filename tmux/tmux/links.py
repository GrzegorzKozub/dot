#!/usr/bin/env python3

import re
import subprocess

dim: list[str] = subprocess.check_output(
    (
        "tmux",
        "display",
        "-p",
        "#{pane_height},#{pane_width},#{scroll_position},",
    ),
    text=True,
).split(",")

height: int = int(dim[0])
width: int = int(dim[1])
scroll: int = int(dim[2]) if dim[2] else 0

content: str = subprocess.check_output(
    (
        "tmux",
        "capture-pane",
        "-p",
        "-J",
        "-S",
        f"{-scroll}",
        "-E",
        f"{height - scroll - 1}",
    ),
    text=True,
)

links: list[str] = re.findall(r"https?://[^\s)]+", content)
unique: list[str] = list(dict.fromkeys(links))

print("\n".join(unique))
