# crazy-alerts

macOS-only CLI: show an **ambulance-style alert** (🚑 message + animated siren) or **full-screen confetti** from the terminal. Uses native Swift overlays; works during screen sharing.

## Install

```bash
npm install -g crazy-alerts
```

## Commands

### `ambulance`

Shows a moving ambulance + message at the bottom of the screen, with an animated siren GIF (and a copy in the top-right corner). An alarm sound plays for the duration (system sound or optional `assets/alarm.wav`).

```bash
ambulance "Test failed"
ambulance "Build failed"
# or with env
AMBULANCE_MESSAGE="Deploy done" ambulance
```

Optional env: `AMBULANCE_DURATION`, `AMBULANCE_FONT_SIZE`, `AMBULANCE_BORDER_INSET`, `AMBULANCE_ASSETS_DIR`. Assets (siren GIF, optional alarm) live in `assets/` and are included in the package.

### `confetti`

Full-screen confetti celebration with a success sound (system “Hero” or optional `assets/success.wav`).

```bash
confetti
# inline overrides (override env and defaults)
confetti --particle-count=500 --duration=10
confetti -c 500 -d 8 --gravity=0.3
# or env
CONFETTI_PARTICLE_COUNT=500 CONFETTI_DURATION=10 confetti
```

Optional **inline flags**: `--particle-count` / `-c`, `--duration` / `-d`, `--gravity` / `-g`, `--velocity` / `-v`, `--size-min`, `--size-max`, `--spawn-rate` / `-r`. Optional **env**: `CONFETTI_PARTICLE_COUNT`, `CONFETTI_DURATION`, `CONFETTI_GRAVITY`, `CONFETTI_VELOCITY`, `CONFETTI_SIZE_MIN`, `CONFETTI_SIZE_MAX`, `CONFETTI_SPAWN_RATE`. Inline args override env; env overrides defaults.

## Requirements

- **macOS** (Darwin)
- **Node.js** ≥ 14
- **Swift** (included with Xcode / Xcode Command Line Tools)

## License

MIT
