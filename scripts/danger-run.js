#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const assetsDir = path.join(projectRoot, 'assets');
const message = process.argv[2] || process.env.DANGER_MESSAGE || 'Danger';
const env = { ...process.env, DANGER_MESSAGE: message, DANGER_DURATION: process.env.DANGER_DURATION || '8', DANGER_FONT_SIZE: process.env.DANGER_FONT_SIZE || '52', DANGER_ICON: process.env.DANGER_ICON || '⚠️', DANGER_ASSETS_DIR: process.env.DANGER_ASSETS_DIR || assetsDir };
const child = spawn('swift', [path.join(scriptDir, 'danger.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
