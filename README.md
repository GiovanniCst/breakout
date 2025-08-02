# Godot Breakout Game (WIP)

This is a work-in-progress project for learning Godot Engine. It's a simple Breakout-style game.

## How to Run

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/GiovanniCst/breakout.git
    ```
2.  **Open in Godot Engine:**
    *   Open Godot Engine.
    *   Click "Import" and select the `project.godot` file from the cloned repository.
    *   Once imported, open the `main.tscn` scene.
3.  **Run the game:**
    *   Press F5 or click the "Play" button in the Godot editor.

## Implemented Features

*   **Paddle Movement:** Control the paddle horizontally using the 'A' and 'D' keys.
*   **Ball Mechanics:**
    *   Launch the ball by pressing the **Spacebar**.
    *   The ball bounces off walls and the paddle.
    *   If the ball goes out of bounds (below the paddle), it respawns on top of the paddle, waiting for a new launch.
*   **Brick Destruction:** Bricks are destroyed when hit by the ball.
*   **Global Game State Management:** Implemented a global `GameManager` (Autoload Singleton) to centralize game state, including score, lives, current level, and high score.

## Todo / Future Features

This section outlines planned features and areas for development. Tasks are grouped to suggest potential independent work streams for multiple contributors.

### Game Core Enhancements (Main Scene Logic)

*   **Scoring System:**
    *   Score tracking is now managed by `GameManager`.
    *   Display the score on the UI (requires UI elements).
*   **Lives System:**
    *   Lives tracking is now managed by `GameManager`.
    *   Display remaining lives on the UI.
    *   Implement "Game Over" condition when lives run out.
*   **Win Condition:**
    *   Detect when all bricks are destroyed in `main.gd`.
    *   Implement a "Win" screen/condition.

### Level Design & Assets (Scene & Asset Management)

*   **Multiple Levels:**
    *   Create additional level scenes (`level_2.tscn`, `level_3.tscn`, etc.).
    *   Implement level loading/progression in `main.gd`.
*   **Different Brick Types:**
    *   **Multi-Hit Bricks:** Implement bricks that require 2 hits to destroy, with visual changes (e.g., cracked appearance) after the first hit.
    *   **Unbreakable Bricks:** Implement bricks that cannot be destroyed by the ball.
    *   **Special Bricks:** (e.g., exploding bricks, bricks that drop power-ups).
    *   (Potentially) Create new brick scenes and scripts (`multi_hit_brick.gd`, `special_brick.gd`).
*   **Sound Effects:**
    *   Add sound effects for ball bounce, brick destruction, paddle hit.
*   **Background Music:**
    *   Integrate background music for gameplay.

### Gameplay Mechanics (Ball & Paddle Interactions)

*   **Power-ups:**
    *   Design and implement various power-ups that drop from destroyed bricks:
        *   **Score Bonuses:** (+50, +10, +100, +250, +500)
        *   **Ball Speed Modifiers:** (Slow, Fast)
        *   **Multi-Ball:** Spawns additional balls.
        *   **Laser/Fireball Paddle:** Allows the paddle to shoot projectiles.
        *   **Paddle Size Modifiers:** (Enlarge, Shrink)
        *   **Sticky Paddle:** Ball sticks to the paddle until launched again.
        *   **Extra Life:** Grants an additional life.
        *   **Bonus Star:** Provides a special bonus.
        *   **Floor/Shield:** Prevents the ball from going out of bounds temporarily.
        *   **Special Ball Types:** (e.g., different visual balls, or balls with special properties)
    *   Create new scenes and scripts for power-up items.
    *   Implement logic for power-up activation and duration.
*   **Ball Speed Progression:**
    *   Ball speed progression is now managed by `GameManager` based on destroyed bricks.

### User Interface (UI/UX Development)

*   **Start Screen:**
    *   Create a main menu/start screen scene.
*   **Game Over Screen:**
    *   Design and implement a "Game Over" screen.
*   **Win Screen:**
    *   Design and implement a "Win" screen.
*   **Pause Menu:**
    *   Create a pause menu for in-game pausing.

Feel free to explore the code and contribute!