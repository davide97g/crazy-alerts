#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const message = process.argv[2] || process.env.PILL_MESSAGE || 'Deploy started';
const env = { ...process.env, PILL_MESSAGE: message, PILL_DURATION: process.env.PILL_DURATION || '5', PILL_FONT_SIZE: process.env.PILL_FONT_SIZE || '20' };
const child = spawn('swift', [path.join(scriptDir, 'pill.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
