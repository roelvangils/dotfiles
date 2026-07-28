# macOS

## Keyboard shortcuts

`keyboard-shortcuts.json` holds 69 custom menu shortcuts across 20
applications, exported from the `NSUserKeyEquivalents` dictionaries macOS
keeps in each app's preference domain.

That dictionary is what System Settings › Keyboard › Keyboard Shortcuts ›
App Shortcuts writes, and what [Houdah
CustomShortcuts](https://www.houdah.com/customShortcuts/) edits — the app
itself stores nothing, so there is no separate file to migrate.

Restore on a new machine:

```sh
./restore-keyboard-shortcuts.py --dry-run   # check first
./restore-keyboard-shortcuts.py
```

Applications read the dictionary when they build their menus, so restart
anything already running.

Re-export from a machine that has the shortcuts:

```sh
python3 - <<'PY' > keyboard-shortcuts.json
import json, glob, os, plistlib
result = {}
def add(domain, path):
    try:
        data = plistlib.load(open(path, "rb"))
    except Exception:
        return
    if ke := data.get("NSUserKeyEquivalents"):
        result.setdefault(domain, {}).update(ke)
home = os.path.expanduser("~")
for p in glob.glob(f"{home}/Library/Preferences/*.plist"):
    add(os.path.basename(p)[:-6], p)
add("NSGlobalDomain", f"{home}/Library/Preferences/.GlobalPreferences.plist")
for p in glob.glob(f"{home}/Library/Containers/*/Data/Library/Preferences/*.plist"):
    add(os.path.basename(p)[:-6], p)
print(json.dumps(result, indent=2, ensure_ascii=False, sort_keys=True))
PY
```

### Notation

`@` command · `~` option · `^` control · `$` shift. Keys are menu paths, with
submenu levels separated by ESC (``); a bare item name matches any menu
item with that title, in any menu.
