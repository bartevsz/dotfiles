#!/usr/bin/env fish

set state "$XDG_RUNTIME_DIR/hyprsunset-eye"

if test -e "$state"
    hyprctl hyprsunset identity >/dev/null
    rm -f "$state"
else
    hyprctl hyprsunset temperature 4200 >/dev/null
    touch "$state"
end
