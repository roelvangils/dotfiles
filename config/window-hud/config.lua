-- Window-mode HUD configuration.
--
-- Read by the Hammerspoon HUD (mouse-drag.lua in ~/.hammerspoon). This file is
-- symlinked to ~/.config/window-hud/config.lua; edits apply on the next summon
-- of the HUD (Hammerspoon watches this file and reloads it automatically).
--
-- Return a table of options. Unknown / missing keys fall back to defaults.

return {
    -- Apps to hide from the "Open" and "Minimized" inventory sections, listed by
    -- BUNDLE ID. Handy for always-on utilities that are technically visible but
    -- just clutter the list. They still appear under "Hidden" if ever hidden.
    --
    -- Find an app's bundle id with:  osascript -e 'id of app "AppName"'
    excludeApps = {
        "com.superduper.superwhisper", -- superwhisper
        "me.damir.dropover-mac",       -- Dropover
    },
}
