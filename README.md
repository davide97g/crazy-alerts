# crazy-alerts

macOS-only CLI: show an **ambulance-style alert** (🚑 message + 🚨) or **full-screen confetti** from the terminal. Uses native Swift overlays; works during screen sharing.

## Install

```bash
npm install -g crazy-alerts
```

## Commands

### `ambulance`

Shows a moving ambulance + message at the bottom of the screen.

```bash
ambulance "Test failed"
ambulance "Build failed"
# or with env
AMBULANCE_MESSAGE="Deploy done" ambulance
```

Optional env: `AMBULANCE_DURATION`, `AMBULANCE_FONT_SIZE`, `AMBULANCE_BORDER_INSET`.

### `confetti`

Full-screen confetti celebration.

```bash
confetti
# optional env
CONFETTI_PARTICLE_COUNT=500 CONFETTI_DURATION=10 confetti
```

Optional env: `CONFETTI_PARTICLE_COUNT`, `CONFETTI_DURATION`, `CONFETTI_GRAVITY`, `CONFETTI_VELOCITY`, `CONFETTI_SIZE_MIN`, `CONFETTI_SIZE_MAX`, `CONFETTI_SPAWN_RATE`.

## Requirements

- **macOS** (Darwin)
- **Node.js** ≥ 14
- **Swift** (included with Xcode / Xcode Command Line Tools)

## License

MIT
