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

## Todo / Future Features

This section outlines planned features and areas for development. Tasks are grouped to suggest potential independent work streams for multiple contributors.

### Game Core Enhancements (Main Scene Logic)

*   **Scoring System:**
    *   Implement score tracking in `main.gd`.
    *   Display the score on the UI (requires UI elements).
*   **Lives System:**
    *   Implement lives tracking in `main.gd`.
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
    *   Implement multi-hit bricks (e.g., requiring 2-3 hits to destroy).
    *   Implement special bricks (e.g., exploding bricks, bricks that drop power-ups).
    *   (Potentially) Create new brick scenes and scripts (`multi_hit_brick.gd`, `special_brick.gd`).
*   **Sound Effects:**
    *   Add sound effects for ball bounce, brick destruction, paddle hit.
*   **Background Music:**
    *   Integrate background music for gameplay.

### Gameplay Mechanics (Ball & Paddle Interactions)

*   **Power-ups:**
    *   Design and implement various power-ups (e.g., longer paddle, multi-ball, ball speed boost).
    *   Create new scenes and scripts for power-up items.
    *   Implement logic for power-up activation and duration.
*   **Ball Speed Progression:**
    *   Increase ball speed over time or based on score/level progression.

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