#!/bin/sh
# goinfre installer — POSIX sh, safe, idempotent
set -e

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

info()    { printf "${CYAN}[...]${NC} %s\n" "$1"; }
success() { printf "${GREEN}  ✔${NC}  %s\n" "$1"; }
warn()    { printf "${RED}[WARN]${NC} %s\n" "$1"; }
die()     { printf "${RED}[ERROR]${NC} %s\n" "$1"; exit 1; }

# ── Pre-flight checks ────────────────────────────────────────────────────────
command -v curl >/dev/null 2>&1 || die "curl is required but not found. Install it first."

if ! command -v python3 >/dev/null 2>&1; then
    warn "python3 not found — goinfre requires Python 3.11+."
    warn "Install python3 before running FixGoinfre."
fi

# ── 1. Download goinfre.py ────────────────────────────────────────────────────
INSTALL_DIR="$HOME/.local"
INSTALL_PATH="$INSTALL_DIR/goinfre.py"
DOWNLOAD_URL="https://raw.githubusercontent.com/Mohamed-El-Mouhib/Fixgoinfre/master/goinfre.py"

info "Downloading goinfre.py → $INSTALL_PATH"
mkdir -p "$INSTALL_DIR"
curl -fsSL "$DOWNLOAD_URL" -o "$INSTALL_PATH"
success "Downloaded goinfre.py"

# ── 2. Permissions ────────────────────────────────────────────────────────────
chmod +x "$INSTALL_PATH"
success "Set executable permissions"

# ── 3. Shell alias ────────────────────────────────────────────────────────────
ALIAS_LINE='alias FixGoinfre="python3 $HOME/.local/goinfre.py"'
FISH_ALIAS='alias FixGoinfre "python3 $HOME/.local/goinfre.py"'
RCFILE=""
ADDED=0

detect_rc() {
    case "$(basename "$SHELL")" in
        bash)
            RCFILE="$HOME/.bashrc"
            ;;
        zsh)
            RCFILE="$HOME/.zshrc"
            ;;
        fish)
            RCFILE="$HOME/.config/fish/config.fish"
            ;;
        *)
            RCFILE=""
            ;;
    esac
}

detect_rc

if [ -n "$RCFILE" ]; then
    # Ensure the rc file exists
    mkdir -p "$(dirname "$RCFILE")"
    touch "$RCFILE"

    # Check for existing alias to avoid duplicates
    if grep -qF "FixGoinfre" "$RCFILE" 2>/dev/null; then
        success "Alias FixGoinfre already present in $RCFILE"
        ADDED=1
    else
        case "$(basename "$SHELL")" in
            fish)
                printf '\n# goinfre package manager\n%s\n' "$FISH_ALIAS" >> "$RCFILE"
                ;;
            *)
                printf '\n# goinfre package manager\n%s\n' "$ALIAS_LINE" >> "$RCFILE"
                ;;
        esac
        success "Alias FixGoinfre added to $RCFILE"
        ADDED=1
    fi
else
    warn "Unknown shell: $SHELL"
    printf "${DIM}  Add this alias manually to your shell config:${NC}\n"
    printf "    %s\n" "$ALIAS_LINE"
fi

# ── 4. Done ───────────────────────────────────────────────────────────────────
printf "\n"
printf "${BOLD}${GREEN}━━━ goinfre installed ━━━${NC}\n"
printf "\n"
success "goinfre.py → $INSTALL_PATH"
if [ "$ADDED" = "1" ] && [ -n "$RCFILE" ]; then
    success "alias FixGoinfre added to $RCFILE"
    printf "\n"
    printf "${CYAN}  →${NC} Restart your shell or run: ${BOLD}source $RCFILE${NC}\n"
else
    printf "\n"
    printf "${CYAN}  →${NC} Add the alias to your shell config manually.\n"
fi
printf "${CYAN}  →${NC} Then just type: ${BOLD}FixGoinfre${NC}\n"
printf "\n"
