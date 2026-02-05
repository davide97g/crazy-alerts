#!/usr/bin/env node

const path = require('path');
const { spawn } = require('child_process');

if (process.platform !== 'darwin') {
  console.error('❌ This script only works on macOS');
  process.exit(1);
}

const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const swiftFile = path.join(scriptDir, 'siren.swift');
const assetsDir = path.join(projectRoot, 'assets');

const message = process.argv[2] || process.env.SIREN_MESSAGE || 'Alert';
const env = {
  ...process.env,
  SIREN_MESSAGE: message,
  SIREN_DURATION: process.env.SIREN_DURATION || '10',
  SIREN_FONT_SIZE: process.env.SIREN_FONT_SIZE || '48',
  SIREN_ASSETS_DIR: process.env.SIREN_ASSETS_DIR || assetsDir,
};

const child = spawn('swift', [swiftFile], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
