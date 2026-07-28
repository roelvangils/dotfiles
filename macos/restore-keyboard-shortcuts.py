#!/usr/bin/env python3
"""Restore per-application menu shortcuts from keyboard-shortcuts.json.

macOS stores custom menu shortcuts as an NSUserKeyEquivalents dictionary in
each application's own preference domain. CustomShortcuts and System Settings
› Keyboard › Keyboard Shortcuts › App Shortcuts are both front ends for that
same dictionary, so restoring it here is equivalent to re-entering everything
by hand.

Keys are menu paths. Modern macOS separates submenu levels with ESC (\\x1b);
older entries are a bare item name, which matches any menu item with that
title. Values use the classic modifier notation: @ command, ~ option,
^ control, $ shift.

Entries are added one at a time so an application's existing shortcuts are
merged rather than replaced.
"""

import argparse
import json
import pathlib
import subprocess
import sys

HERE = pathlib.Path(__file__).resolve().parent
DEFAULT_SOURCE = HERE / "keyboard-shortcuts.json"


def readable(key: str) -> str:
    """Render a menu path with ESC separators as Menu › Item."""
    return " › ".join(part for part in key.split("\x1b") if part)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", nargs="?", type=pathlib.Path, default=DEFAULT_SOURCE)
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="print what would be written without changing anything",
    )
    args = parser.parse_args()

    shortcuts = json.loads(args.source.read_text())
    written = 0

    for domain, entries in sorted(shortcuts.items()):
        # NSGlobalDomain applies to every application; defaults spells it -g.
        target = "-g" if domain == "NSGlobalDomain" else domain

        print(f"\n{domain}")
        for key, value in sorted(entries.items()):
            if not value:
                # An empty value means the shortcut was cleared, not set.
                continue
            print(f"  {readable(key):<40} {value}")
            if not args.dry_run:
                subprocess.run(
                    ["defaults", "write", target, "NSUserKeyEquivalents",
                     "-dict-add", key, value],
                    check=True,
                )
            written += 1

    if args.dry_run:
        print(f"\n{written} shortcuts would be written.")
        return 0

    # cfprefsd caches preferences; without this the changes only appear later.
    subprocess.run(["killall", "cfprefsd"], stderr=subprocess.DEVNULL)
    print(f"\n{written} shortcuts written. Restart the affected apps to pick them up.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
