#!/usr/bin/env node

const path = require('path');
const { spawn } = require('child_process');

if (process.platform !== 'darwin') {
  console.error('❌ This script only works on macOS');
  process.exit(1);
}

const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const swiftFile = path.join(scriptDir, 'fire.swift');
const assetsDir = path.join(projectRoot, 'assets');

const message = process.argv[2] || process.env.FIRE_MESSAGE || "Everything's on fire";
const env = {
  ...process.env,
  FIRE_MESSAGE: message,
  FIRE_DURATION: process.env.FIRE_DURATION || '8',
  FIRE_PARTICLE_COUNT: process.env.FIRE_PARTICLE_COUNT || '80',
  FIRE_FONT_SIZE: process.env.FIRE_FONT_SIZE || '36',
  FIRE_ASSETS_DIR: process.env.FIRE_ASSETS_DIR || assetsDir,
};

const child = spawn('swift', [swiftFile], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
