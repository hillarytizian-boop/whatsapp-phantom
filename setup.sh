#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════╗
# ║     WHATSAPP PHANTOM v3.0 - AUTOMATED SETUP SCRIPT                  ║
# ║     Developed by Hillary Tizian                                     ║
# ╚══════════════════════════════════════════════════════════════════════╝

R="\033[1;31m"
G="\033[1;32m"
Y="\033[1;33m"
B="\033[1;34m"
M="\033[1;35m"
C="\033[1;36m"
W="\033[1;37m"
D="\033[0m"

clear
echo -e "${R}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       WHATSAPP PHANTOM - SETUP SCRIPT            ║"
echo "  ║       Developed by Hillary Tizian                ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${D}\n"

# ─── Spinner ───
spinner() {
    local pid=$!
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        echo -ne "\r ${C}${spin:$i:1}${D} $1"
        sleep 0.08
    done
    echo -e "\r ${G}✓${D} $1 ${G}complete${D}   "
}

echo -e " ${Y}[*] Starting installation of WhatsApp Phantom dependencies...${D}\n"

# Phase 1: System packages
echo -e " ${B}[1/5]${D} Updating system packages..."
pkg update -y &>/dev/null && pkg upgrade -y &>/dev/null
echo -e " ${G}  ✓ System updated${D}\n"

echo -e " ${B}[2/5]${D} Installing core dependencies..."
pkg install -y nodejs curl wget git python3 jq toilet 2>/dev/null &
spinner "Installing core packages"

echo -e " ${B}[3/5]${D} Installing Chromium browser..."
pkg install -y tur-repo 2>/dev/null
pkg install -y chromium 2>/dev/null &
spinner "Installing Chromium (this may take a while)"

# Phase 2: Node.js dependencies
echo -e " ${B}[4/5]${D} Setting up Node.js environment..."
cd ~/whatsapp-phantom 2>/dev/null || cd "$(dirname "$0")"

# Install puppeteer-core (not full puppeteer to save space)
npm init -y &>/dev/null
npm install puppeteer-core @wppconnect/wa-js 2>/dev/null &
spinner "Installing Node.js modules"

# Phase 3: Verify
echo -e " ${B}[5/5]${D} Verifying installation..."
sleep 1

# Check critical deps
DEPS_OK=0
for cmd in node npm chromium-browser; do
    if command -v $cmd &>/dev/null; then
        echo -e " ${G}  ✓ $cmd detected${D}"
        ((DEPS_OK++))
    else
        echo -e " ${R}  ✗ $cmd NOT found${D}"
    fi
done

echo ""
if [ $DEPS_OK -ge 2 ]; then
    echo -e " ${G}╔══════════════════════════════════════════════════╗${D}"
    echo -e " ${G}║${D}        INSTALLATION COMPLETE!                   ${G}║${D}"
    echo -e " ${G}╚══════════════════════════════════════════════════╝${D}"
    echo ""
    echo -e " ${W}To launch the tool, run:${D}"
    echo -e " ${C}  ./phantom.sh${D}"
    echo ""
    echo -e " ${Y}Note: First launch may require QR code scan.${D}"
    echo -e " ${Y}Make sure your phone has WhatsApp installed.${D}"
else
    echo -e " ${R}╔══════════════════════════════════════════════════╗${D}"
    echo -e " ${R}║${D}     Some dependencies failed to install.        ${R}║${D}"
    echo -e " ${R}║${D}     Try running: pkg install chromium nodejs    ${R}║${D}"
    echo -e " ${R}╚══════════════════════════════════════════════════╝${D}"
fi

echo ""
