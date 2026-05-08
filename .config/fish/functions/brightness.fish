function brightness --argument-names dir

    set dev amdgpu_bl1
    set max 64764

    # log / audio skala
    set steps 1 2.4 4.9 8.7 14.2 22.1 33.4 49.1 70.6 100

    set state_file /tmp/brightness_idx

    # init (start w „środku skali”)
    if not test -e $state_file
        echo 6 > $state_file
    end

    set idx (cat $state_file)

    # sterowanie jak gałka
    switch $dir
        case up
            set idx (math $idx + 1)
        case down
            set idx (math $idx - 1)
    end

    # clamp
    test $idx -lt 1; and set idx 1
    test $idx -gt 10; and set idx 10

    echo $idx > $state_file

    set target_pct $steps[$idx]
    set target (math "$max * $target_pct / 100")

    set cur (brightnessctl -d $dev g)

    # smooth ramp
    set frames 18

    for i in (seq 1 $frames)

        set t (math "$i / $frames")
        set eased (math "$t * $t * (3 - 2 * $t)")

        set value (math "$cur + ($target - $cur) * $eased")

        brightnessctl -d $dev set (math "round($value)") > /dev/null

        sleep 0.01
    end

end
