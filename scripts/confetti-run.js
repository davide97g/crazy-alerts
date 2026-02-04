#!/usr/bin/env node

const path = require('path');
const { spawn } = require('child_process');

if (process.platform !== 'darwin') {
  console.error('❌ This script only works on macOS');
  process.exit(1);
}

const scriptDir = __dirname;
const swiftFile = path.join(scriptDir, 'confetti.swift');

const env = {
  ...process.env,
  CONFETTI_PARTICLE_COUNT: process.env.CONFETTI_PARTICLE_COUNT || '300',
  CONFETTI_DURATION: process.env.CONFETTI_DURATION || '6',
  CONFETTI_GRAVITY: process.env.CONFETTI_GRAVITY || '0.5',
  CONFETTI_VELOCITY: process.env.CONFETTI_VELOCITY || '20',
  CONFETTI_SIZE_MIN: process.env.CONFETTI_SIZE_MIN || '10',
  CONFETTI_SIZE_MAX: process.env.CONFETTI_SIZE_MAX || '50',
  CONFETTI_SPAWN_RATE: process.env.CONFETTI_SPAWN_RATE || '70',
};

const child = spawn('swift', [swiftFile], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
