# IMPORTANT INTEGRITY NOTICE:
#
# I have no desire to learn in-depth bash scripting, and
# as such this entire script is vibe coded.


#!/usr/bin/env bash
set -euo pipefail

cursor=$(hyprctl cursorpos -j)
cx=$(echo "$cursor" | jq '.x')
cy=$(echo "$cursor" | jq '.y')

monitor=$(hyprctl monitors -j | jq '[.[] | select(.focused==true)][0]')
mon_x=$(echo "$monitor" | jq '.x')
mon_y=$(echo "$monitor" | jq '.y')
scale=$(echo "$monitor" | jq '.scale')
mon_w=$(awk -v w="$(echo "$monitor" | jq '.width')" -v s="$scale" 'BEGIN{printf "%d", w/s}')
mon_h=$(awk -v h="$(echo "$monitor" | jq '.height')" -v s="$scale" 'BEGIN{printf "%d", h/s}')
ws_id=$(echo "$monitor" | jq '.activeWorkspace.id')

gaps_out=$(hyprctl getoption general:gaps_out -j | jq -r '.int // 0')
gaps_in=$(hyprctl getoption general:gaps_in -j | jq -r '.int // 0')
gap=$(( gaps_in / 2 ))

layout=$(hyprctl getoption general:layout -j | jq -r '.str')

# every tiled window on the active workspace
clients=$(hyprctl clients -j | jq --argjson ws "$ws_id" \
  '[.[] | select(.workspace.id==$ws and .floating==false)]')

# whichever one the cursor is physically inside right now
hovered=$(echo "$clients" | jq -c --argjson cx "$cx" --argjson cy "$cy" '
  [.[] | select(
    ($cx >= .at[0]) and ($cx < (.at[0] + .size[0])) and
    ($cy >= .at[1]) and ($cy < (.at[1] + .size[1]))
  )] | .[0] // empty')

if [ -z "$hovered" ] || [ "$hovered" = "null" ]; then
  # nothing under the cursor: workspace is empty, or you're over a gap.
  # the next window will fill the whole tile, so just center rofi.
  pkill rofi || rofi -show drun -theme-str \
    "window {anchor: center; location: center; width: 40%; height: 50%; margin: ${gaps_out}px;}"
  exit 0
fi

hx=$(echo "$hovered" | jq '.at[0]')
hy=$(echo "$hovered" | jq '.at[1]')
hw=$(echo "$hovered" | jq '.size[0]')
hh=$(echo "$hovered" | jq '.size[1]')

if [ "$layout" = "dwindle" ]; then
  force_split=$(hyprctl getoption dwindle:force_split -j | jq -r '.int')

  if [ "$hw" -ge "$hh" ]; then vertical=true; else vertical=false; fi

  if [ "$force_split" = "1" ]; then
    side="first"
  elif [ "$force_split" = "2" ]; then
    side="second"
  else
    # smart split (default): Hyprland decides based on cursor position.
    # ASSUMPTION: the new window opens on the side AWAY from the cursor.
    # If it opens backwards for you, swap "second"/"first" on the next two lines.
    if $vertical; then
      center_x=$(( hx + hw / 2 ))
      if [ "$cx" -lt "$center_x" ]; then side="first"; else side="second"; fi
    else
      center_y=$(( hy + hh / 2 ))
      if [ "$cy" -lt "$center_y" ]; then side="first"; else side="second"; fi
    fi
  fi

  if $vertical; then
    new_w=$(( hw / 2 )); new_h=$hh
    if [ "$side" = "first" ]; then new_gx=$hx; else new_gx=$(( hx + hw / 2 )); fi
    new_gy=$hy
  else
    new_w=$hw; new_h=$(( hh / 2 ))
    new_gx=$hx
    if [ "$side" = "first" ]; then new_gy=$hy; else new_gy=$(( hy + hh / 2 )); fi
  fi

elif [ "$layout" = "master" ]; then
  orientation=$(hyprctl getoption master:orientation -j | jq -r '.str')
  mfact=$(hyprctl getoption master:mfact -j | jq -r '.float')
  # master's regions are fixed at the monitor level, not nested per-window
  case "$orientation" in
    left)   new_w=$(awk -v w="$mon_w" -v m="$mfact" 'BEGIN{printf "%d", w*(1-m)}'); new_h=$mon_h; new_gx=$(( mon_x + mon_w - new_w )); new_gy=$mon_y ;;
    right)  new_w=$(awk -v w="$mon_w" -v m="$mfact" 'BEGIN{printf "%d", w*(1-m)}'); new_h=$mon_h; new_gx=$mon_x; new_gy=$mon_y ;;
    top)    new_h=$(awk -v h="$mon_h" -v m="$mfact" 'BEGIN{printf "%d", h*(1-m)}'); new_w=$mon_w; new_gx=$mon_x; new_gy=$(( mon_y + mon_h - new_h )) ;;
    bottom) new_h=$(awk -v h="$mon_h" -v m="$mfact" 'BEGIN{printf "%d", h*(1-m)}'); new_w=$mon_w; new_gx=$mon_x; new_gy=$mon_y ;;
    *)      new_w=$(awk -v w="$mon_w" -v m="$mfact" 'BEGIN{printf "%d", w*(1-m)}'); new_h=$mon_h; new_gx=$mon_x; new_gy=$mon_y ;;
  esac
else
  # unknown/other layout: just fill the hovered window's box
  new_w=$hw; new_h=$hh; new_gx=$hx; new_gy=$hy
fi

# convert from global compositor coords to monitor-relative for rofi
rel_x=$(( new_gx - mon_x ))
rel_y=$(( new_gy - mon_y ))

pkill rofi || rofi -show drun -theme-str \
  "window {anchor: northwest; location: northwest; x-offset: ${rel_x}px; y-offset: ${rel_y}px; width: ${new_w}px; height: ${new_h}px; margin: ${gap}px;}"


#pkill rofi || rofi -show drun -theme-str \
#  "window {anchor: northwest; location: northwest; x-offset: ${rel_x}px; y-offset: ${rel_y}px; width: ${new_w}px; height: ${new_h}px; margin: ${gap}px;}" &
#
#kitty & sleep 0.5; hyprctl dispatch movewindowpixel exact $(hyprctl cursorpos | tr -d ',')
