#!/bin/bash

ARTIST="$1"
ALBUM="$2"

if [ -z "$ALBUM" ] || [ "$ALBUM" == "Unknown" ]; then
    echo "????"
    exit 0
fi

# Tworzymy unikalny klucz dla cache
CACHE_FILE="/tmp/year_$(echo "$ALBUM" | tr -cd '[:alnum:]' | cut -c1-20).txt"

if [ -f "$CACHE_FILE" ]; then
    cat "$CACHE_FILE"
    exit 0
fi

# Uruchamiamy pobieranie w tle, by nie mrozić paska
(
    # Kodujemy znaki specjalne (np. &) do formatu URL
    Q_ALBUM=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$ALBUM'''))")
    Q_ARTIST=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$ARTIST'''))")

    # Szukamy grupy wydań (release-group), co lepiej oddaje rok pierwotnego wydania
    URL="https://musicbrainz.org/ws/2/release-group/?query=releasegroup:\"$Q_ALBUM\"%20AND%20artist:\"$Q_ARTIST\"&fmt=json"
    
    YEAR=$(curl -s --max-time 3 "$URL" | jq -r '.["release-groups"][0]."first-release-date"' 2>/dev/null | cut -d'-' -f1)

    if [[ "$YEAR" =~ ^[0-9]{4}$ ]]; then
        echo "$YEAR" > "$CACHE_FILE"
    else
        echo "????" > "$CACHE_FILE"
    fi
) &

echo "????"
