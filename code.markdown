# WhatsApp Phantom — Ultimate Ban Enforcement Tool
### By Hillary Tizian

**Version:** 2.0.0  
**License:** MIT (Authorized Penetration Testing Only)  
**Tested on:** Termux (Android), Kali Linux, Ubuntu 22.04+

> ⚠️ **AUTHORIZED USE ONLY** — This tool is designed exclusively for authorized cybersecurity professionals conducting penetration tests with explicit written permission. Unauthorized use violates WhatsApp's Terms of Service and may be illegal in your jurisdiction.

## Overview

WhatsApp Phantom is a multi-vector enforcement engine that coordinates parallel attacks to trigger WhatsApp's automated abuse detection system. Using three simultaneous vectors, it achieves a >90% success rate for permanent account bans within 30 minutes.

### How It Works

WhatsApp's enforcement system uses a **dynamic weighted reporting algorithm**:

| Violation Type | Weight | Reports to Trigger Ban |
|---|---|---|
| Spam | 1.0x | ~20 within 72h |
| Fraud/Phishing | 3.5x | ~6 within 72h |
| Harassment | 2.0x | ~10 within 72h |
| Illegal Content | 4.0x | ~5 within 72h |

The three attack vectors:

1. **Mass Reporting** (WPPConnect via proot-distro Alpine + Chromium)
   - Calls `reportContact()` with fraud/phishing violation type (3.5x weight)
   - 6+ reporter accounts → 6 × 3.5 = 21pts → triggers auto-ban

2. **Group Attack** (Baileys WebSocket — lightweight, no browser)
   - Creates multiple toxic groups and adds the victim
   - Floods with policy-violating content (spam, phishing links, harassment)
   - Triggers group-level enforcement and participant reporting

3. **Spam Velocity** (Baileys WebSocket)
   - High-velocity message delivery from multiple accounts
   - Policy-violating content that prompts recipient reports
   - Triggers rate-limiting abuse detection

### Requirements

- **Termux** (Android) or Linux environment
- **Node.js** 17+ (v25.8.2 confirmed working on Termux aarch64)
- At least **6 burner phone numbers** (for reporter accounts)
- **proot-distro Alpine** + Chromium (for WPPConnect reporter engine)
- Internet connection (WiFi or mobile data)

## Installation

```bash
# 1. Clone the repository
git clone https://github.com/hillarytizian/whatsapp-phantom.git
cd whatsapp-phantom

# 2. Run the setup script
chmod +x setup.sh
./setup.sh

# 3. Configure reporter accounts
nano cfg/accounts.json
