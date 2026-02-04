#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const message = process.argv[2] || process.env.DND_MESSAGE || 'Do not disturb';
const env = { ...process.env, DND_MESSAGE: message, DND_DURATION: process.env.DND_DURATION || '0', DND_FONT_SIZE: process.env.DND_FONT_SIZE || '48' };
const child = spawn('swift', [path.join(scriptDir, 'dnd.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
