#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const assetsDir = path.join(projectRoot, 'assets');
const message = process.argv[2] || process.env.CLAP_MESSAGE || 'Well done!';
const env = { ...process.env, CLAP_MESSAGE: message, CLAP_DURATION: process.env.CLAP_DURATION || '4', CLAP_FONT_SIZE: process.env.CLAP_FONT_SIZE || '40', CLAP_ASSETS_DIR: process.env.CLAP_ASSETS_DIR || assetsDir };
const child = spawn('swift', [path.join(scriptDir, 'clap.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
