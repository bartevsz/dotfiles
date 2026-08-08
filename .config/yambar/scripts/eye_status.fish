#!/usr/bin/env fish

if test -e /tmp/hyprsunset-eye
    echo 'eye|string|EYE 4200'
else
    echo 'eye|string|EYE OFF'
end

echo ''
