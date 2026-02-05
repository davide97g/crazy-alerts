#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const assetsDir = path.join(projectRoot, 'assets');
const message = process.argv[2] || process.env.REMINDER_MESSAGE || 'Stand up';
const env = { ...process.env, REMINDER_MESSAGE: message, REMINDER_DURATION: process.env.REMINDER_DURATION || '6', REMINDER_FONT_SIZE: process.env.REMINDER_FONT_SIZE || '56', REMINDER_ASSETS_DIR: process.env.REMINDER_ASSETS_DIR || assetsDir };
const child = spawn('swift', [path.join(scriptDir, 'reminder.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
