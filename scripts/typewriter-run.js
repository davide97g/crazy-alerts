#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const assetsDir = path.join(projectRoot, 'assets');
const message = process.argv[2] || process.env.TYPEWRITER_MESSAGE || 'Done.';
const env = { ...process.env, TYPEWRITER_MESSAGE: message, TYPEWRITER_DURATION: process.env.TYPEWRITER_DURATION || '2', TYPEWRITER_CHAR_DELAY: process.env.TYPEWRITER_CHAR_DELAY || '0.06', TYPEWRITER_FONT_SIZE: process.env.TYPEWRITER_FONT_SIZE || '28', TYPEWRITER_ASSETS_DIR: process.env.TYPEWRITER_ASSETS_DIR || assetsDir };
const child = spawn('swift', [path.join(scriptDir, 'typewriter.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
