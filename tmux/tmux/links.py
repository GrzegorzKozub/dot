#!/usr/bin/env python3

# usage: links.py [pane x y [hyperlink]]
#
# without arguments, print unique links in the visible part of the current pane (links.sh)
#
# positional arguments:
#   pane       tmux pane id, e.g. %3
#   x y        pane cell under the mouse; opens the link there (ctrl+click binding in tmux.conf)
#   hyperlink  OSC 8 link under the mouse, opened as is when given

import re
import subprocess
import sys
import unicodedata

URL = re.compile(r"https?://[^\s<>\"'`)\]]*[^\s<>\"'`)\].,;:!?]")


def tmux(*args: str) -> str:
    return subprocess.check_output(("tmux", *args), text=True)


def visible(pane: str | None) -> tuple[list[str], int]:
    target = ("-t", pane) if pane else ()
    dim = tmux(
        "display", "-p", *target, "#{pane_height} #{pane_width} #{scroll_position}"
    )
    height, width, scroll = (int(value or 0) for value in dim.rstrip("\n").split(" "))
    content = tmux(
        "capture-pane",
        "-p",
        "-J",
        *target,
        "-S",
        f"{-scroll}",
        "-E",
        f"{height - scroll - 1}",
    )
    return content.removesuffix("\n").split("\n"), width


def cells(char: str) -> int:
    if unicodedata.combining(char) or char in "\u200b\u200d\ufe0f":
        return 0
    return 2 if unicodedata.east_asian_width(char) in "WF" else 1


def at(lines: list[str], width: int, x: int, y: int) -> str | None:
    row = 0
    for line in lines:
        widths = [cells(char) for char in line]
        rows = max(1, -(-sum(widths) // width))
        if y < row + rows:
            col = (y - row) * width + x
            for match in URL.finditer(line):
                start = sum(widths[: match.start()])
                end = start + sum(widths[match.start() : match.end()])
                if start <= col < end:
                    return match.group()
            return None
        row += rows
    return None


if len(sys.argv) == 1:
    lines, _ = visible(None)
    print("\n".join(dict.fromkeys(URL.findall("\n".join(lines)))))
else:
    pane, x, y, *hyperlink = sys.argv[1:]
    link = hyperlink[0] if hyperlink else at(*visible(pane), int(x), int(y))
    if link:
        _ = subprocess.run(
            ("xdg-open", link),
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
