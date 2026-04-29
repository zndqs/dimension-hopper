# Dimension Hopper

A **knowledge lock puzzle game** where your understanding of space is the only key you need.

## 🎮 Core Gameplay

This is not a "find key to open door" game. This is a "understand the rule to open door" game.

**Play the Demo: "Three Doors"** — A complete, 10-minute puzzle experience.

---

## 🚪 Door 1: Edge Alignment Teleport

Two parallel walls stand before an abyss. One near. One far.

When they align perfectly in your view, they become one. Press SPACE to teleport through.

**Teaches you:** Two objects in 3D space can become one in 2D perspective.

## 🔑 Door 2: Perspective Fusion

A key floats in the air. A lock sits on a wall. They are in different places.

When they overlap perfectly in your view, they fuse. Press SPACE to unlock the door.

**Teaches you:** The relationship between two objects is more important than the objects themselves.

## 👤 Door 3: Shadow History

An empty room. Nothing but you. But you were here. And you left a shadow.

Your past movements are recorded and played back as a semi-transparent shadow. When you stand where you once stood, facing the same direction, you resonate with your past self.

Press SPACE to merge with your shadow and time travel.

**"You yourself are the key."**

---

## 👂 Pure Procedural Audio System

All sounds are **generated procedurally** — no audio files needed. Your cognitive progress directly shapes the sound.

| Sound Layer | Description |
|-------------|-------------|
| **Alignment Carrier** | Continuous sine wave that rises in frequency as you approach perfect alignment (110Hz → 880Hz) |
| **Overtone Harmonics** | 3rd harmonic fades in near perfect alignment — crystal resonance feeling |
| **Teleport Sweep** | Exponential frequency sweep (100Hz → 8kHz) when dimension hopping |
| **Fusion Chord** | A major triad arpeggio (A C# E) that plays when you successfully fuse key and lock |
| **Shadow Resonance** | Deep subsonic hum (E1 41.2Hz) + high whistling overtone (D7 2469.4Hz) |
| **Grain Texture** | Subtle noise that intensifies with all alignment types |

## ✨ Full-Screen Post-Processing Shader

| Effect | Description |
|--------|-------------|
| **Alignment Glow** | Screen gets brighter the closer you are to perfect alignment |
| **Vignette Pulse** | Dark edges contract inwards as you approach alignment |
| **RGB Chromatic Aberration** | Teleport triggers a brief RGB channel separation |
| **White Flash** | Bright white pulse at the moment of dimension hop |
| **Blue Wave Distortion** | Fusion creates subtle horizontal wave patterns |
| **CRT Scanlines** | Shadow alignment adds retro CRT-style scanline effect |
| **Radial Tunnel Effect** | Time travel pulls everything toward center + heavy distortion |
| **Film Grain** | Subtle grain effect intensifies with all alignment types |

## 🎯 Design Philosophy

**Knowledge Lock Games** are about:
- **No external knowledge required** — everything you need is in the game
- **No inventory** — your brain is the only tool
- **"Aha!" moments** — pure pleasure of sudden understanding
- **Player's mind is the true character** — your perspective is what changes, not the world

## 🎨 Art Style

- **Minimalist pure white architecture**
- **Pure black** interactive objects
- **Glowing semi-transparent blue** shadow
- **No textures, no decorations**
- **Visual feedback maps directly to cognitive progress**

## 🕹️ Controls

- **WASD** - Move
- **Mouse** - Look around
- **SPACE** - Activate aligned/fused/shadow objects

## 🚀 How to Play

1. Download **Godot 4.2.2** (or later 4.x version)
2. Clone this repository
3. Open the project folder in Godot
4. Press **F5** to play

## 📦 Project Structure

```
dimension-hopper/
├── project.godot          # Project config
├── game.gd               # Main game logic (3 puzzles in a linear progression)
├── game.tscn             # Demo level "Three Doors"
├── shadow_history.gd     # Shadow history + time travel mechanism
├── audio_system.gd       # Procedural audio synthesis engine (7 oscillators)
├── post_process.gdshader # Full-screen post effects (8 visual layers)
├── default_env.tres      # Environment settings
└── README.md
```

## 🧠 Technical Accomplishments (v1.0 Demo)

✅ **Three complete knowledge lock mechanisms:**
1. **Edge Alignment Teleport** — screen space pixel distance detection
2. **Perspective Fusion** — key + lock 2D overlap in view space
3. **Shadow History** — 4D alignment (position + rotation + time), with time travel erasure

✅ **Zero resource files** — no textures, no models, no audio files.
   Everything is code-generated. 100% pure knowledge.

✅ **Unified Audio-Visual Feedback Pipeline:**
- 7 oscillators generating 48kHz stereo sound at runtime
- 8 visual effect layers in full-screen shader
- All effects driven by the same underlying "alignment intensity" value
- Audio and visuals are not separate decorations — they are the mechanism itself

✅ **Complete 10-minute puzzle experience**
- Three separate rooms, each teaching one mechanism
- Linear but non-coercive progression
- All doors open independently
- Final gate opens after the third door

---

*"The key is not in the world. The key is in how you see the world."*

---

*"You yourself are the key."*
