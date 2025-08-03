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
	*   Ball follows paddle before launch.
	*   Ball acceleration based on destroyed bricks.
*   **Brick Destruction:** Bricks are destroyed when hit by the ball.
*   **Multi-Hit Bricks:** Bricks require 2 hits to destroy, with a visual change (cracked appearance) after the first hit.
*   **Automatic Brick Population:** Bricks are automatically populated with random non-cracked sprites.
*   **Unbreakable Tiles:**
	*   Randomly spawned between the breakable tile wall and the paddle.
	*   Use textures from `assets/PNG/22-Breakout-Tiles.png` to `assets/PNG/30-Breakout-Tiles.png`.
	*   Are scaled to 0.15 by default (can be adjusted in the scene).
	*   Are not destroyed by the ball, acting as static obstacles.
	*   Collision avoidance ensures they do not overlap during spawning.
	*   The number of unbreakable tiles spawned is related to the game level (1-2 for levels 1-2, 3-7 for higher levels).
*   **Sound Effects:** Added sound effects for brick hits and destruction.
*   **Global Game State Management:** Implemented a global `GameManager` (Autoload Singleton) to centralize game state, including score, lives, current level, and high score.
*   **UI Enhancements:**
	*   UI hearts now update correctly.
	*   Explicit UI initialization from `main.gd`.
	*   Game Over message "Sei morto definitivamente" displayed when lives run out.
	*   Game resets to level 1 after game over with lives replenished.
*   **Paddle Animation:** Implemented paddle animation.

## Todo / Future Features

This section outlines planned features and areas for development. Tasks are grouped to suggest potential independent work streams for multiple contributors.

### Game Core Enhancements (Main Scene Logic)

*   **Win Condition:**
	*   Detect when all bricks are destroyed in `main.gd`.
	*   Implement a "Win" screen/condition.

### Level Design & Assets (Scene & Asset Management)

*   **Multiple Levels:**
	*   Create additional level scenes (`level_2.tscn`, `level_3.tscn`, etc.).
	*   Implement level loading/progression in `main.gd`.
*   **Different Brick Types:**
	*   **Special Bricks:** (e.g., exploding bricks, bricks that drop power-ups).
	*   (Potentially) Create new brick scenes and scripts (`multi_hit_brick.gd`, `special_brick.gd`).
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
