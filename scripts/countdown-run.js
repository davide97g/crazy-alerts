#!/usr/bin/env node

const path = require('path');
const { spawn } = require('child_process');

if (process.platform !== 'darwin') {
  console.error('❌ This script only works on macOS');
  process.exit(1);
}

const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const swiftFile = path.join(scriptDir, 'countdown.swift');
const assetsDir = path.join(projectRoot, 'assets');

const firstArg = process.argv[2];
const secondArg = process.argv[3];
const firstAsNum = firstArg != null ? parseInt(firstArg, 10) : NaN;
const isStartNum = !isNaN(firstAsNum) && String(firstAsNum) === String(firstArg).trim();
const startVal = process.env.COUNTDOWN_START || (isStartNum ? String(firstAsNum) : '5');
const messageVal = process.env.COUNTDOWN_MESSAGE || (isStartNum ? secondArg || '' : firstArg || '');
const env = {
  ...process.env,
  COUNTDOWN_START: startVal,
  COUNTDOWN_MESSAGE: messageVal,
  COUNTDOWN_DURATION_AFTER_ZERO: process.env.COUNTDOWN_DURATION_AFTER_ZERO || '2',
  COUNTDOWN_SOUND_AT_ZERO: process.env.COUNTDOWN_SOUND_AT_ZERO ?? '1',
  COUNTDOWN_FONT_SIZE: process.env.COUNTDOWN_FONT_SIZE || '160',
  COUNTDOWN_ASSETS_DIR: process.env.COUNTDOWN_ASSETS_DIR || assetsDir,
};

const child = spawn('swift', [swiftFile], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
