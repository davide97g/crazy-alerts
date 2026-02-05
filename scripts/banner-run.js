#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const message = process.argv[2] || process.env.BANNER_MESSAGE || 'Build in progress...';
const env = { ...process.env, BANNER_MESSAGE: message, BANNER_DURATION: process.env.BANNER_DURATION || '10', BANNER_SPEED: process.env.BANNER_SPEED || '80', BANNER_POSITION: process.env.BANNER_POSITION || 'bottom', BANNER_FONT_SIZE: process.env.BANNER_FONT_SIZE || '24' };
const child = spawn('swift', [path.join(scriptDir, 'banner.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
