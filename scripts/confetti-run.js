#!/usr/bin/env node

const path = require('path');
const { spawn } = require('child_process');

// Defaults (env can override; inline args override both)
const DEFAULTS = {
  CONFETTI_PARTICLE_COUNT: '300',
  CONFETTI_DURATION: '6',
  CONFETTI_GRAVITY: '0.5',
  CONFETTI_VELOCITY: '20',
  CONFETTI_SIZE_MIN: '10',
  CONFETTI_SIZE_MAX: '50',
  CONFETTI_SPAWN_RATE: '70',
};

const INLINE_FLAGS = {
  '--particle-count': 'CONFETTI_PARTICLE_COUNT',
  '-c': 'CONFETTI_PARTICLE_COUNT',
  '--duration': 'CONFETTI_DURATION',
  '-d': 'CONFETTI_DURATION',
  '--gravity': 'CONFETTI_GRAVITY',
  '-g': 'CONFETTI_GRAVITY',
  '--velocity': 'CONFETTI_VELOCITY',
  '-v': 'CONFETTI_VELOCITY',
  '--size-min': 'CONFETTI_SIZE_MIN',
  '--size-max': 'CONFETTI_SIZE_MAX',
  '--spawn-rate': 'CONFETTI_SPAWN_RATE',
  '-r': 'CONFETTI_SPAWN_RATE',
};

/** Parse inline args (--key=value or --key value) into env overrides. */
const parseInlineArgs = () => {
  const overrides = {};
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const eq = arg.indexOf('=');
    if (eq > 0) {
      const key = arg.slice(0, eq);
      const value = arg.slice(eq + 1);
      const envKey = INLINE_FLAGS[key];
      if (envKey) overrides[envKey] = value;
      continue;
    }
    const envKey = INLINE_FLAGS[arg];
    if (envKey && argv[i + 1] !== undefined) {
      overrides[envKey] = argv[i + 1];
      i += 1;
    }
  }
  return overrides;
};

if (process.platform !== 'darwin') {
  console.error('❌ This script only works on macOS');
  process.exit(1);
}

const scriptDir = __dirname;
const swiftFile = path.join(scriptDir, 'confetti.swift');

const env = {
  ...process.env,
  ...Object.fromEntries(
    Object.entries(DEFAULTS).map(([k, v]) => [k, process.env[k] ?? v])
  ),
  ...parseInlineArgs(),
};

const child = spawn('swift', [swiftFile], { env, stdio: 'inherit' });
child.on('close', (code) => process.exit(code ?? 0));
