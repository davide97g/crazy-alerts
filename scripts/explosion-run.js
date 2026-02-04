#!/usr/bin/env node
const path = require('path');
const { spawn } = require('child_process');
if (process.platform !== 'darwin') { console.error('❌ This script only works on macOS'); process.exit(1); }
const scriptDir = __dirname;
const message = process.argv[2] || process.env.EXPLOSION_MESSAGE || '';
const env = { ...process.env, EXPLOSION_MESSAGE: message, EXPLOSION_DURATION: process.env.EXPLOSION_DURATION || '4', EXPLOSION_PARTICLE_COUNT: process.env.EXPLOSION_PARTICLE_COUNT || '60', EXPLOSION_FONT_SIZE: process.env.EXPLOSION_FONT_SIZE || '28' };
const child = spawn('swift', [path.join(scriptDir, 'explosion.swift')], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
