#!/usr/bin/env node

/**
 * crazy-alerts — main entry point.
 * Run with -h or --help to list all commands and brief descriptions.
 */

const COMMANDS = [
  { name: 'ambulance', description: 'Moving ambulance (🚑) and message at bottom of screen' },
  { name: 'banner', description: 'Scrolling ticker at top or bottom' },
  { name: 'checkmark', description: 'Big green checkmark with optional message and success sound' },
  { name: 'clap', description: '👏 and message, success sound' },
  { name: 'confetti', description: 'Full-screen confetti animation on all displays' },
  { name: 'countdown', description: 'Full-screen countdown (e.g. 5, 4, 3, 2, 1, Go!)' },
  { name: 'danger', description: 'Dark overlay, ⚠️ or 💀, message, looping alarm' },
  { name: 'dnd', description: 'Dim overlay + "Do not disturb" (or custom message)' },
  { name: 'explosion', description: 'Single particle burst from center; optional message' },
  { name: 'fire', description: 'Full-screen flame effect with message' },
  { name: 'klaxon', description: 'Red/black full-screen flash with short repeating beeps' },
  { name: 'matrix', description: 'Falling green characters; optional centered message' },
  { name: 'pill', description: 'Small centered pill badge' },
  { name: 'pomodoro', description: '"Time for a break" + ☕, gentle sound' },
  { name: 'rainbow', description: 'Slow rainbow gradient + message' },
  { name: 'reminder', description: 'Big message, optional sound' },
  { name: 'rocket', description: '🚀 moving up, message, success sound' },
  { name: 'siren', description: 'Full-screen red pulsing alert with optional message and looping alarm' },
  { name: 'strobe', description: 'White/red alternating full-screen flash' },
  { name: 'typewriter', description: 'Message types out with blinking cursor; beep at end' },
];

const isHelp = (arg) => arg === '-h' || arg === '--help';

const path = require('path');
const showHelp = () => {
  const pkg = require(path.join(__dirname, '..', 'package.json'));
  console.log(`crazy-alerts v${pkg.version} — macOS overlay alerts from the terminal\n`);
  console.log('Usage: crazy-alerts -h | crazy-alerts <command> [args...]\n');
  console.log('Commands:\n');
  const maxName = Math.max(...COMMANDS.map((c) => c.name.length));
  for (const { name, description } of COMMANDS) {
    console.log(`  ${name.padEnd(maxName)}  ${description}`);
  }
  console.log('\nRun a command directly, e.g.: ambulance "Done" | confetti | siren "Alert"');
  console.log('See USAGE.md for options and environment variables.\n');
};

const main = () => {
  const arg = process.argv[2];
  if (!arg || isHelp(arg)) {
    showHelp();
    process.exit(0);
  }
  // If user ran "crazy-alerts <command> ...", we could forward to the command;
  // for now we only handle -h and suggest running the command directly.
  const known = COMMANDS.some((c) => c.name === arg);
  if (known) {
    console.log(`Run the command directly: ${arg} [message or options]\n`);
    process.exit(0);
  }
  showHelp();
  process.exit(0);
};

main();
