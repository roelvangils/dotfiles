// setwall.swift — set the wallpaper of the CURRENTLY FOCUSED space.
//
// Compiled on demand by set-wallpapers.sh into ./bin/setwall; there is no
// build step to remember and no Homebrew dependency (sindresorhus/macos-wallpaper
// wraps this exact API if you would rather carry a formula instead).
//
// The whole per-space trick lives in one API detail: setDesktopImageURL applies
// to the active space on the given screen, NOT to all spaces. So the caller
// focuses a space, runs this, and repeats. There is no API that addresses a
// space by index — hence the focus dance in the shell script.
//
// macOS 14+ moved wallpaper state into com.apple.wallpaper's Index.plist, which
// nests base64 bplists inside the outer plist and needs WallpaperAgent bounced
// to reload. Editing that directly was evaluated and rejected. The old
// `System Events -> picture of desktop` AppleScript route is dead on 26/27.
//
// Usage: setwall <absolute-path-to-image> [fit|fill]
//
//   fill (default) — scale until the screen is covered, cropping the overflow.
//                    Right for wallpapers that match the display ratio.
//   fit            — scale until the WHOLE frame is visible, padding the
//                    remainder with black. Right for cinema stills: 2001 is
//                    2.20:1 on a 16:9 panel, so `fill` would crop ~19% off the
//                    sides and destroy Kubrick's one-point-perspective framing.
//                    `fit` gives you real letterbox bars instead.

import AppKit

func err(_ s: String) { FileHandle.standardError.write((s + "\n").data(using: .utf8)!) }

let args = CommandLine.arguments
guard args.count > 1 else {
    err("usage: setwall <image> [fit|fill]")
    exit(64)
}

let mode = args.count > 2 ? args[2] : "fill"
guard mode == "fit" || mode == "fill" else {
    err("setwall: mode must be 'fit' or 'fill', got '\(mode)'")
    exit(64)
}

let path = args[1]
guard FileManager.default.fileExists(atPath: path) else {
    err("setwall: no such file: \(path)")
    exit(66)
}
guard let screen = NSScreen.main else {
    err("setwall: no main screen")
    exit(69)
}

// scaleProportionallyUpOrDown in BOTH cases — the difference is allowClipping.
// With clipping the image grows until no gap remains and the overflow is cut;
// without it, it stops as soon as the whole frame fits and fillColor paints the
// leftover. That single bool is the entire fill/fit distinction.
var options: [NSWorkspace.DesktopImageOptionKey: Any] = [
    .imageScaling: NSNumber(value: NSImageScaling.scaleProportionallyUpOrDown.rawValue),
    .allowClipping: mode == "fill",
]
// Black rather than the desktop's accent/average colour, so letterboxed stills
// read as cinema bars instead of as a mismatched border.
if mode == "fit" { options[.fillColor] = NSColor.black }

do {
    try NSWorkspace.shared.setDesktopImageURL(URL(fileURLWithPath: path), for: screen, options: options)
} catch {
    err("setwall: \(error.localizedDescription)")
    exit(70)
}

// Deliberately NOT reading desktopImageURL back to confirm: it returns the
// PREVIOUS value for a moment after a successful set, so an inline check
// reports a stale path and looks like a failure. Verify on next focus instead.
