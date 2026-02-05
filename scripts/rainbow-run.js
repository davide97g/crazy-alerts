#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const message = process.argv[2] || process.env.RAINBOW_MESSAGE || 'All green';
const env = { ...process.env, RAINBOW_MESSAGE: message, RAINBOW_DURATION: process.env.RAINBOW_DURATION || '6', RAINBOW_FONT_SIZE: process.env.RAINBOW_FONT_SIZE || '42' };
const child = spawn('swift', [path.join(scriptDir, 'rainbow.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
