#!/usr/bin/env fish

set dev amdgpu_bl1
set max 64764

set cur (brightnessctl -d $dev g 2>/dev/null)
set pct (math "round($cur / $max * 100)")

set bar ""
for i in (seq 1 10)
    if test $i -le (math "round($pct / 10)")
        set bar "▮$bar"
    else
        set bar "▯$bar"
    end
end

notify-send -h int:value:$pct "Brightness" "$bar  $pct%"
