#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const assetsDir = path.join(projectRoot, 'assets');
const message = process.argv[2] || process.env.POMODORO_MESSAGE || 'Time for a break';
const env = { ...process.env, POMODORO_MESSAGE: message, POMODORO_DURATION: process.env.POMODORO_DURATION || '8', POMODORO_FONT_SIZE: process.env.POMODORO_FONT_SIZE || '44', POMODORO_ASSETS_DIR: process.env.POMODORO_ASSETS_DIR || assetsDir };
const child = spawn('swift', [path.join(scriptDir, 'pomodoro.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
