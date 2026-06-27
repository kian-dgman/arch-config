#!/bin/bash

LAPTOP_MON="eDP-1"
LAPTOP_CONF="3072x1920@120.00, 0x0, 1.6"

# A helper function that lists all monitors EXCEPT the laptop monitor.
# If this returns anything, it means an external display is connected.
check_external_monitors() {
  hyprctl monitors all | awk '/Monitor/ {print $2}' | grep -v "^$LAPTOP_MON$"
}

# Initial check when the script starts
if [ -n "$(check_external_monitors)" ]; then
  # At least one external monitor is connected: turn off the laptop screen
  hyprctl keyword monitor "$LAPTOP_MON, disable"
else
  # No external monitors: ensure the laptop screen is on
  hyprctl keyword monitor "$LAPTOP_MON, $LAPTOP_CONF"
fi

# Listen to the Hyprland socket
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do

  # When ANY monitor is plugged in
  if [[ "$line" == "monitoradded>>"* ]]; then
    # Extract the monitor name from the event line (removes "monitoradded>>")
    ADDED_MON="${line#monitoradded>>}"

    # If the monitor that was just added is NOT the laptop screen
    if [[ "$ADDED_MON" != "$LAPTOP_MON" ]]; then
      ACTIVE_WS=$(hyprctl activeworkspace | awk '/workspace ID/ {print $3}')

      hyprctl keyword monitor "$LAPTOP_MON, disable"
      sleep 0.2
      hyprctl dispatch workspace "$ACTIVE_WS"
    fi

  # When ANY monitor is unplugged
  elif [[ "$line" == "monitorremoved>>"* ]]; then
    # Extract the monitor name from the event line
    REMOVED_MON="${line#monitorremoved>>}"

    # If the monitor that was just removed is NOT the laptop screen
    if [[ "$REMOVED_MON" != "$LAPTOP_MON" ]]; then

      # Check if there are any OTHER external monitors still connected
      if [ -z "$(check_external_monitors)" ]; then
        ACTIVE_WS=$(hyprctl activeworkspace | awk '/workspace ID/ {print $3}')

        hyprctl keyword monitor "$LAPTOP_MON, $LAPTOP_CONF"
        sleep 0.2
        hyprctl dispatch workspace "$ACTIVE_WS"
      fi
    fi
  fi
done
