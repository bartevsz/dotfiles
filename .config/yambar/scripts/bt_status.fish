#!/usr/bin/fish
set power (bluetoothctl show | grep "Powered: yes")
if test -n "$power"
    set device (bluetoothctl info | grep "Name:" | cut -d' ' -f2-)
    if test -n "$device"
        # Tag zmieniony na bt_state
        echo "bt_state|string|ON <$device>"
    else
        echo "bt_state|string|ON"
    end
else
    echo "bt_state|string|OFF"
end
echo ""
