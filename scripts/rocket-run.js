#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const assetsDir = path.join(projectRoot, 'assets');
const message = process.argv[2] || process.env.ROCKET_MESSAGE || 'Liftoff!';
const env = { ...process.env, ROCKET_MESSAGE: message, ROCKET_DURATION: process.env.ROCKET_DURATION || '5', ROCKET_FONT_SIZE: process.env.ROCKET_FONT_SIZE || '36', ROCKET_ASSETS_DIR: process.env.ROCKET_ASSETS_DIR || assetsDir };
const child = spawn('swift', [path.join(scriptDir, 'rocket.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
