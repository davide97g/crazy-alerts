#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const message = process.argv[2] || process.env.STROBE_MESSAGE || '';
const env = { ...process.env, STROBE_MESSAGE: message, STROBE_DURATION: process.env.STROBE_DURATION || '5', STROBE_FONT_SIZE: process.env.STROBE_FONT_SIZE || '40' };
const child = spawn('swift', [path.join(scriptDir, 'strobe.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
