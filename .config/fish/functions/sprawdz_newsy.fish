function sprawdz_newsy
    # Definicja źródeł
    set -l feeds \
        "https://policja.pl/dokumenty/rss/1-rss-1.rss" \
        "https://cbsp.policja.pl/dokumenty/rss/123-rss-1.rss" \
        "https://niebezpiecznik.pl/feed" \
        "https://zaufanatrzeciastrona.pl/feed" \
        "https://news.google.com/rss/search?q=Żyrardów&hl=pl&gl=PL&ceid=PL:pl"

    # Słowa kluczowe dla alertów ITSEC
    set -l alert_keywords "atak" "wyciek" "krytyczna" "vulnerability" "exploit" "haker" "ostrzeżenie"

    echo (set_color yellow)"--- RAPORT WYWIADOWCZY: OSTATNIE NAGŁÓWKI ---"(set_color normal)

    for url in $feeds
        echo (set_color blue)"Źródło: $url"(set_color normal)
        
        # Pobieranie tytułów
        set -l titles (curl -s $url | grep -oP '(?<=<title>).*?(?=</title>)' | sed '1d' | head -n 5)

        for title in $titles
            echo "  - $title"
            
            # Sprawdzanie słów kluczowych dla powiadomień (tylko dla ITSEC/Policji)
            for word in $alert_keywords
                if echo $title | grep -iq "$word"
                    notify-send --urgency=critical "ALERT WYWIADU" "Wykryto zagrożenie: $title"
                    break
                end
            end
        end
        echo ""
    end
end
