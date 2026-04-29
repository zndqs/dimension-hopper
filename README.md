# Dimension Hopper

A **knowledge lock puzzle game** where your understanding of space is the only key you need.

## 🎮 Core Gameplay

This is not a "find key to open door" game. This is a "understand the rule to open door" game.

### Mechanism 1: Edge Alignment Teleport
Two parallel walls stand before an abyss. When they align perfectly in your view, they become one. Press SPACE to teleport through.

### Mechanism 2: Perspective Fusion
A key floats in the air. A lock sits on a wall. When they overlap perfectly in your view, they fuse. Press SPACE to unlock the door.

## 👂 Audio System (v0.4)

All sounds are **generated procedurally** — no audio files needed. Your cognitive progress directly shapes the sound.

| Sound Layer | Description |
|-------------|-------------|
| **Alignment Carrier** | Continuous sine wave that rises in frequency as you approach perfect alignment (110Hz → 880Hz) |
| **Overtone Harmonics** | 3rd harmonic fades in near perfect alignment — crystal resonance feeling |
| **Teleport Sweep** | Exponential frequency sweep (100Hz → 8kHz) when dimension hopping |
| **Fusion Chord** | A major triad arpeggio (A C# E) that plays when you successfully fuse key and lock |
| **Grain Texture** | Subtle noise that intensifies with alignment |

## ✨ Visual Effects

| Effect | Description |
|--------|-------------|
| **Alignment Glow** | Screen gets brighter the closer you are to perfect alignment |
| **Vignette Pulse** | Dark edges contract inwards as you approach alignment |
| **RGB Chromatic Aberration** | Teleport triggers a brief RGB channel separation |
| **White Flash** | Bright white pulse at the moment of dimension hop |
| **Blue Wave Distortion** | Fusion creates subtle horizontal wave patterns |
| **Film Grain** | Subtle grain effect intensifies with alignment |

## 🎯 Design Philosophy

**Knowledge Lock Games** are about:
- **No external knowledge required** — everything you need is in the game
- **No inventory** — your brain is the only tool
- **"Aha!" moments** — pure pleasure of sudden understanding
- **Player's mind is the true character** — your perspective is what changes, not the world

## 🎨 Art Style

- **Minimalist pure white architecture**
- **Pure black** interactive objects
- **No textures, no decorations**
- **Soft global illumination only**
- **Visual feedback maps directly to cognitive progress**

## 🕹️ Controls

- **WASD** - Move
- **Mouse** - Look around
- **SPACE** - Activate aligned/fused objects

## 🚀 How to Run

1. Download **Godot 4.2.2** (or later 4.x version)
2. Open this project folder
3. Press **F5** to play

## 📦 Project Structure

```
dimension-hopper/
├── project.godot          # Project config
├── game.gd               # Main game logic (2 mechanisms + shader + audio control)
├── game.tscn             # Main 3D scene
├── audio_system.gd       # Procedural audio synthesis engine (5 oscillators)
├── post_process.gdshader # Full-screen post effects
├── default_env.tres      # Environment settings
└── README.md
```

## 🧠 Current Features (v0.4)

✅ **Two complete knowledge lock mechanisms:**
1. Edge Alignment Teleport (screen space pixel distance detection)
2. Perspective Fusion (key + lock overlap in view)

✅ **Full-screen Post-processing Shader**
- Alignment glow + vignette
- RGB chromatic aberration on teleport
- Blue tint + wave distortion on fusion
- Subtle film grain

✅ **Pure Procedural Audio Synthesis**
- 48kHz stereo generation at runtime
- No audio files, 100% code-generated sound
- Sine wave carrier maps to cognitive progress
- Major triad arpeggio on successful fusion
- Exponential sweep on teleport

✅ **First-person movement**
✅ **Clean minimalist aesthetic**

## 🔮 Roadmap

- [ ] **Mechanism 3: Shadow History** (your past actions' shadows interact with present)
- [ ] **3-5 complete levels with compound puzzles**
- [ ] **Steam store page**

---

*"The key is not in the world. The key is in how you see the world."*
