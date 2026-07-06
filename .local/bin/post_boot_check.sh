#!/bin/sh
# ==============================================================================
# post_boot_check.sh
#
# Weryfikacja stanu systemu PO restarcie z nowym fullroot apkovl.
# Uruchamiać w już zbootowanym Alpine (nie w Live ISO), najlepiej jako
# użytkownik mbartoszewski. Część testów wymaga sudo (moduły, service).
#
# Użycie:
#   sh post_boot_check.sh            # pełny raport
#   sh post_boot_check.sh --quiet    # tylko podsumowanie na końcu
#
# ==============================================================================

set -u

QUIET=0
[ "${1:-}" = "--quiet" ] && QUIET=1

TARGET_USER="mbartoszewski"
EXPECTED_HOME="/home/${TARGET_USER}"
EXPECTED_SHELL="/usr/bin/fish"
EXPECTED_GROUPS="wheel audio input video seat"
WIFI_SSID="T-Mobile_Swiatlowod_5GHz_79F0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

ok()   { PASS=$((PASS + 1)); [ "$QUIET" = 1 ] || printf "${GREEN}[ OK ]${NC} %s\n" "$1"; }
bad()  { FAIL=$((FAIL + 1)); printf "${RED}[FAIL]${NC} %s\n" "$1"; }
wrn()  { WARN=$((WARN + 1)); [ "$QUIET" = 1 ] || printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
sect() { [ "$QUIET" = 1 ] || printf "\n${BLUE}=== %s ===${NC}\n" "$1"; }

# --------------------------- 1. TOŻSAMOŚĆ UŻYTKOWNIKA ------------------------

check_user() {
    sect "1. Użytkownik"

    CUR_USER=$(whoami)
    if [ "$CUR_USER" = "$TARGET_USER" ]; then
        ok "Zalogowano jako ${TARGET_USER}"
    else
        wrn "Bieżący użytkownik to '${CUR_USER}', nie '${TARGET_USER}' (uruchom jako ${TARGET_USER} dla pełnego testu)"
    fi

    if [ -d "$EXPECTED_HOME" ]; then
        ok "Katalog domowy istnieje: ${EXPECTED_HOME}"
    else
        bad "Brak katalogu domowego: ${EXPECTED_HOME}"
    fi

    USER_SHELL=$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f7)
    if [ "$USER_SHELL" = "$EXPECTED_SHELL" ]; then
        ok "Powłoka poprawna: ${EXPECTED_SHELL}"
    else
        bad "Powłoka nieprawidłowa: '${USER_SHELL}' (oczekiwano ${EXPECTED_SHELL})"
    fi

    USER_GROUPS=$(id -nG "$TARGET_USER" 2>/dev/null || echo "")
    for g in $EXPECTED_GROUPS; do
        if echo "$USER_GROUPS" | grep -qw "$g"; then
            ok "Grupa obecna: ${g}"
        else
            bad "Brak grupy: ${g}"
        fi
    done

    # Sprawdzenie czy nie ma śladów starego loginu
    if grep -rq "mateuszb" "$EXPECTED_HOME"/.config/fish/fish_variables 2>/dev/null; then
        bad "Znaleziono ślad starego loginu 'mateuszb' w fish_variables"
    else
        ok "Brak śladów starego loginu w fish_variables"
    fi
}

# --------------------------- 2. BINARKI --------------------------------------

check_binaries() {
    sect "2. Kluczowe binarki"

    for bin in Hyprland ghostty yambar mako swaybg nmcli nmtui fish stow grim slurp thunar nnn fzf; do
        if command -v "$bin" >/dev/null 2>&1; then
            ok "Dostępne: ${bin} ($(command -v "$bin"))"
        else
            bad "Brak w PATH: ${bin}"
        fi
    done
}

# --------------------------- 3. USŁUGI (OpenRC) ------------------------------

check_services() {
    sect "3. Usługi OpenRC"

    if ! command -v rc-status >/dev/null 2>&1; then
        wrn "rc-status niedostępny - pomijam sprawdzanie usług"
        return
    fi

    RC_OUT=$(rc-status default 2>/dev/null || rc-status 2>/dev/null || echo "")

    for svc in dbus networkmanager polkit; do
        if echo "$RC_OUT" | grep -q "$svc"; then
            if echo "$RC_OUT" | grep "$svc" | grep -q "started"; then
                ok "Usługa działa: ${svc}"
            else
                bad "Usługa w runlevelu, ale NIE działa: ${svc}"
            fi
        else
            wrn "Usługa nieobecna w runlevelu 'default': ${svc} (może być pod inną nazwą, np. polkit-elogind)"
        fi
    done

    # elogind/polkit-elogind bywa pod inną nazwą
    if echo "$RC_OUT" | grep -qi "elogind"; then
        ok "elogind/polkit-elogind obecny w runlevelu"
    fi
}

# --------------------------- 4. SIEĆ -----------------------------------------

check_network() {
    sect "4. Sieć"

    if command -v nmcli >/dev/null 2>&1; then
        DEV_STATUS=$(nmcli device status 2>/dev/null || echo "")
        if echo "$DEV_STATUS" | grep -qE "^wlan0"; then
            ok "Interfejs wlan0 wykryty przez NetworkManager"
        else
            bad "wlan0 nie widoczny w 'nmcli device status'"
        fi
        if echo "$DEV_STATUS" | grep -qE "^eth0"; then
            ok "Interfejs eth0 wykryty przez NetworkManager"
        else
            wrn "eth0 nie widoczny (OK jeśli nie podłączony kablem)"
        fi

        ACTIVE_CONN=$(nmcli -t -f NAME connection show --active 2>/dev/null || echo "")
        if echo "$ACTIVE_CONN" | grep -q "$WIFI_SSID"; then
            ok "Aktywne połączenie z siecią domową: ${WIFI_SSID}"
        else
            bad "Brak aktywnego połączenia z '${WIFI_SSID}' (aktywne: ${ACTIVE_CONN:-brak})"
        fi
    else
        bad "nmcli niedostępny - nie można zweryfikować sieci"
    fi

    # Test realnej łączności
    if command -v ping >/dev/null 2>&1; then
        if ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
            ok "Łączność z internetem działa (ping 1.1.1.1)"
        else
            bad "Brak łączności z internetem (ping 1.1.1.1 nieudany)"
        fi
    fi
}

# --------------------------- 5. GIT / SSH / DOTFILES -------------------------

check_git_ssh() {
    sect "5. Git, SSH, dotfiles"

    if [ -d "${EXPECTED_HOME}/.ssh" ]; then
        ok "Katalog .ssh istnieje"
        if ls "${EXPECTED_HOME}"/.ssh/id_ed25519* >/dev/null 2>&1; then
            ok "Klucz ED25519 obecny"
        else
            bad "Brak klucza ED25519 w .ssh"
        fi
    else
        bad "Brak katalogu .ssh"
    fi

    if command -v ssh >/dev/null 2>&1; then
        SSH_OUT=$(ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 -T git@github.com 2>&1 || true)
        if echo "$SSH_OUT" | grep -q "successfully authenticated"; then
            ok "Uwierzytelnienie SSH do GitHuba działa"
        else
            bad "SSH do GitHuba nie potwierdził uwierzytelnienia: ${SSH_OUT}"
        fi
    else
        bad "Brak polecenia ssh"
    fi

    DOTFILES="${EXPECTED_HOME}/dotfiles"
    if [ -d "${DOTFILES}/.git" ]; then
        ok "Repozytorium dotfiles istnieje"

        BRANCH=$(git -C "$DOTFILES" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
        if [ "$BRANCH" = "main" ]; then
            ok "Repozytorium na gałęzi main"
        else
            wrn "Repozytorium na gałęzi '${BRANCH}', nie 'main'"
        fi

        if [ -z "$(git -C "$DOTFILES" status --porcelain 2>/dev/null)" ]; then
            ok "Working tree czysty"
        else
            wrn "Working tree ma niezacommitowane zmiany"
        fi
    else
        bad "Brak repozytorium .git w ${DOTFILES}"
    fi

    # Symlinki Stow
    for link in .config .local; do
        if [ -L "${EXPECTED_HOME}/${link}" ]; then
            ok "Symlink Stow OK: ${link} -> $(readlink "${EXPECTED_HOME}/${link}")"
        else
            bad "Brak symlinku Stow: ${link}"
        fi
    done
}

# --------------------------- 6. MOUNTY BTRFS ---------------------------------

check_btrfs_mounts() {
    sect "6. Mounty BTRFS"

    if ! command -v findmnt >/dev/null 2>&1; then
        wrn "findmnt niedostępny - pomijam"
        return
    fi

    BTRFS_MOUNTS=$(findmnt -t btrfs -o TARGET,SOURCE,OPTIONS -n 2>/dev/null || echo "")
    if [ -z "$BTRFS_MOUNTS" ]; then
        wrn "Nie wykryto żadnych mountów BTRFS - sprawdź ręcznie czy to oczekiwane"
    else
        [ "$QUIET" = 1 ] || echo "$BTRFS_MOUNTS" | while read -r line; do
            info_line="  $line"
            printf "%s\n" "$info_line"
        done
        ok "Wykryto mounty BTRFS ($(echo "$BTRFS_MOUNTS" | wc -l) wpis(ów)) - zweryfikuj ręcznie listę subwolumenów"
    fi

    # Sprawdzenie czy partycja stanu jest zamontowana
    if mount | grep -q "on /mnt/alpine-state "; then
        ok "Partycja stanu zamontowana w /mnt/alpine-state"
    else
        wrn "Partycja stanu niezamontowana w /mnt/alpine-state (może być zamontowana gdzie indziej po boocie)"
    fi
}

# --------------------------- 7. AUDIO ----------------------------------------

check_audio() {
    sect "7. Audio (PipeWire)"

    for proc in pipewire wireplumber; do
        if pgrep -x "$proc" >/dev/null 2>&1; then
            ok "Proces działa: ${proc}"
        else
            wrn "Proces nie działa: ${proc} (normalne jeśli sesja graficzna jeszcze nie wystartowała)"
        fi
    done
}

# --------------------------- URUCHOMIENIE ------------------------------------

check_user
check_binaries
check_services
check_network
check_git_ssh
check_btrfs_mounts
check_audio

sect "PODSUMOWANIE"
printf "${GREEN}OK: %d${NC}   ${YELLOW}WARN: %d${NC}   ${RED}FAIL: %d${NC}\n" "$PASS" "$WARN" "$FAIL"

if [ "$FAIL" -eq 0 ]; then
    printf "\n${GREEN}System wygląda na gotowy do pracy.${NC}\n"
    exit 0
else
    printf "\n${RED}Wykryto %d krytyczny(ch) problem(ów) - system NIE jest w pełni gotowy.${NC}\n" "$FAIL"
    exit 1
fi
