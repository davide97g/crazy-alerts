#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const assetsDir = path.join(projectRoot, 'assets');
const message = process.argv[2] || process.env.KLAXON_MESSAGE || '';
const env = { ...process.env, KLAXON_MESSAGE: message, KLAXON_DURATION: process.env.KLAXON_DURATION || '6', KLAXON_FONT_SIZE: process.env.KLAXON_FONT_SIZE || '44', KLAXON_ASSETS_DIR: process.env.KLAXON_ASSETS_DIR || assetsDir };
const child = spawn('swift', [path.join(scriptDir, 'klaxon.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
