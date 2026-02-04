#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const message = process.argv[2] || process.env.MATRIX_MESSAGE || '';
const env = { ...process.env, MATRIX_MESSAGE: message, MATRIX_DURATION: process.env.MATRIX_DURATION || '8', MATRIX_FONT_SIZE: process.env.MATRIX_FONT_SIZE || '14', MATRIX_COLUMNS: process.env.MATRIX_COLUMNS || '40' };
const child = spawn('swift', [path.join(scriptDir, 'matrix.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
