#!/bin/bash
# Focus an iPad Simulator window and force Landscape Right before Run.
set -u
LOG="/Users/bbhanda1/Desktop/Personal/Personal Projects/taptotalker-ios/.cursor/debug-244308.log"
TS=$(python3 -c 'import time; print(int(time.time()*1000))')
mkdir -p "$(dirname "$LOG")"

BOOTED=$(xcrun simctl list devices | awk '/Booted/{print}' | tr '\n' ';' || true)

printf '%s\n' "{\"sessionId\":\"244308\",\"runId\":\"post-fix\",\"hypothesisId\":\"ORIENT\",\"location\":\"scheme.preAction\",\"message\":\"sim landscape pre-action start\",\"timestamp\":$TS,\"data\":{\"booted\":\"$BOOTED\"}}" >> "$LOG" || true

# Bring Simulator forward, focus an iPad window, then set Landscape Right.
osascript <<'EOF' 2>/dev/null || true
tell application "Simulator" to activate
delay 0.25
tell application "System Events"
  tell process "Simulator"
    set frontmost to true
    delay 0.15

    -- Prefer focusing an iPad simulator window when several are open.
    try
      set ipadWindows to every window whose name contains "iPad"
      if (count of ipadWindows) > 0 then
        set w to item 1 of ipadWindows
        perform action "AXRaise" of w
        set value of attribute "AXMain" of w to true
      end if
    end try
    delay 0.15

    try
      click menu item "Landscape Right" of menu "Orientation" of menu item "Orientation" of menu "Device" of menu bar 1
    end try
    delay 0.2
    -- Second click helps when the first is ignored during window focus changes.
    try
      click menu item "Landscape Right" of menu "Orientation" of menu item "Orientation" of menu "Device" of menu bar 1
    end try
  end tell
end tell
EOF

TS2=$(python3 -c 'import time; print(int(time.time()*1000))')
printf '%s\n' "{\"sessionId\":\"244308\",\"runId\":\"post-fix\",\"hypothesisId\":\"ORIENT\",\"location\":\"scheme.preAction\",\"message\":\"sim landscape pre-action done\",\"timestamp\":$TS2,\"data\":{\"ok\":true}}" >> "$LOG" || true
