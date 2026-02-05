#!/usr/bin/env node

const path = require('path');
const { spawn } = require('child_process');

if (process.platform !== 'darwin') {
  console.error('❌ This script only works on macOS');
  process.exit(1);
}

const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const swiftFile = path.join(scriptDir, 'checkmark.swift');
const assetsDir = path.join(projectRoot, 'assets');

const message = process.argv[2] || process.env.CHECKMARK_MESSAGE || 'Done';
const env = {
  ...process.env,
  CHECKMARK_MESSAGE: message,
  CHECKMARK_DURATION: process.env.CHECKMARK_DURATION || '4',
  CHECKMARK_FONT_SIZE: process.env.CHECKMARK_FONT_SIZE || '32',
  CHECKMARK_ASSETS_DIR: process.env.CHECKMARK_ASSETS_DIR || assetsDir,
};

const child = spawn('swift', [swiftFile], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
