# Word Catcher (Trivia Falling Words Game)

An arcade trivia game built with **Godot 4.7**. Questions are displayed in a prominent card at the bottom of the screen while words fall from above. Steer your catcher cart left and right to catch the correct answer and dodge the distractors!

---

## 🎮 How to Play

1. **Read the Question** displayed in the card at the bottom of the screen.
2. **Watch the Falling Words**: One word is the correct answer, while the others are tricky distractors.
3. **Catch the Correct Word**:
   - Earn **+100 points** multiplied by your active combo streak (`x1.5`, `x2.0`, `x2.5`...).
   - Triggers celebration chimes, particle bursts, and floating points feedback.
   - Clears the remaining words and loads the next question.
4. **Avoid Distractors & Misses**:
   - Catching a wrong word costs **1 Heart ❤️** and resets your streak.
   - Letting the correct word fall off the screen also costs **1 Heart ❤️**.
5. **Game Over**: When all 3 hearts are lost, your final score is tallied against your high score.

---

## 🕹️ Controls

| Action | Keyboard / Mouse |
| :--- | :--- |
| **Move Left / Right** | `A` / `D` or `←` / `→` Arrow Keys |
| **Speed Boost** | `Shift` or `Space` (Hold) |
| **Mouse Steering** | Move mouse horizontally across the screen |
| **Pause / Resume** | `Esc` or `P` |
| **Restart Game** | `R` (on Game Over or Pause screen) |

---

## 🚀 Architecture & File Structure

```text
GameFallingObjects/
├── project.godot               # Project configuration, resolution (1152x648), input map, autoloads
├── scenes/
│   ├── main.tscn               # Root scene: starfield background, camera with shake, HUD, player
│   ├── player.tscn             # Player catcher Area2D, collision shape, and procedural visualizer
│   ├── falling_word.tscn       # Falling word Area2D, rounded pill container, label, and burst particles
│   └── hud.tscn                # CanvasLayer HUD: bottom question card, top status bar, pause & game over overlays
├── scripts/
│   ├── main.gd                 # Game loop, wave spawner, lane allocator, score/streak manager
│   ├── player.gd               # Player movement, kinematic acceleration, bounds clamping, catch triggers
│   ├── player_visual.gd        # Procedural vector drawing: glowing rim, animated thrusters, catch flash
│   ├── falling_word.gd         # Word physics, wave drift, adaptive collision bounds, catch & poof animations
│   ├── hud.gd                  # Bottom question display, animated score count-up, hearts, floating text popups
│   ├── question_database.gd    # 35+ trivia questions across Science, Space, Animals, Geography, Math, Tech
│   └── sound_manager.gd        # Procedural 16-bit audio synthesizer (arpeggio, buzzer, streak bell, fanfares)
└── tests/
    └── test_gameplay.gd        # Automated headless integration test verifying spawning, catch logic, and damage
```

---

## 🔊 Procedural Audio Synthesizer

The game includes a standalone procedural audio synthesizer in `scripts/sound_manager.gd`. It generates 16-bit WAV audio streams on startup:
- **Correct catch**: Ascending 4-note bell chime with exponential decay.
- **Wrong catch**: Harsh downward sawtooth buzzer.
- **Streak combo**: High shimmering arpeggio.
- **Missed word**: Falling tone pitch drop.
- **Game over**: Sad 4-note minor cadence.
- **UI clicks & speed boost**: Subtle audio cues.

No external `.wav` or `.mp3` files are required!

---

## 🧪 Running the Game

### From Godot Editor:
1. Open Godot Engine.
2. Import / open `d:\magisterij_1_letnik\skupinsko\GameFallingObjects`.
3. Press **F5** (or click the **Play** button in the top-right corner).

### From Command Line:
```powershell
& "C:\Users\bumba\Desktop\Godot_v4.7.2-stable_win64.exe" --path .
```