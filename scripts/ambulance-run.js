#!/usr/bin/env node

const path = require('path');
const { spawn } = require('child_process');

if (process.platform !== 'darwin') {
  console.error('❌ This script only works on macOS');
  process.exit(1);
}

const scriptDir = __dirname;
const swiftFile = path.join(scriptDir, 'ambulance.swift');

const message = process.argv[2] || process.env.AMBULANCE_MESSAGE || 'Test CNT-T5431 failed';
const env = {
  ...process.env,
  AMBULANCE_MESSAGE: message,
  AMBULANCE_DURATION: process.env.AMBULANCE_DURATION || '14',
  AMBULANCE_FONT_SIZE: process.env.AMBULANCE_FONT_SIZE || '20',
  AMBULANCE_BORDER_INSET: process.env.AMBULANCE_BORDER_INSET || '12',
};

const child = spawn('swift', [swiftFile], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
