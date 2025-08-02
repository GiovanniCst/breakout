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

## Future Plans (To be implemented)

*   Scoring system.
*   Multiple lives for the player.
*   Different types of bricks (e.g., multi-hit bricks).
*   Power-ups (e.g., longer paddle, multi-ball).
*   Level progression.
*   Game over and win conditions.

Feel free to explore the code and contribute!