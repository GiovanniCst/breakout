# game_parameters.gd
# This script defines core game parameters for level generation and difficulty.

extends Resource

# Ball Parameters
const DEFAULT_BALL_SPEED = 450.0
const MIN_BALL_SPEED = 450.0
const MAX_BALL_SPEED = 1000.0
const BALL_SPEED_INCREASE_RATE_PER_LEVEL = 0.05 # Example: 5% additional speed increase per level
const BASE_BALL_SPEED_INCREASE_PER_LEVEL = 20.0 # How much base ball speed increases per level

# Paddle Parameters
const DEFAULT_PADDLE_SCALE = 1.0 # Assuming 1.0 is default size
const MIN_PADDLE_SCALE = 0.7
const MAX_PADDLE_SCALE = 1.3

# Brick Parameters
const BRICK_HEALTH_RANGE = Vector2(1, 3) # Min and Max hits for a brick
const BRICK_DENSITY = 0.7 # Percentage of grid cells that will contain a brick
const BASE_UNBREAKABLE_BRICKS = 1 # Starting number of unbreakable bricks
const DEFAULT_BRICK_ROWS = 1 # Default number of brick rows
const MAX_BRICK_ROWS = 9 # Maximum number of brick rows

# Power-up Parameters
const POWERUP_SPAWN_RATE = 0.15 # 15% chance for a power-up to drop from a brick

var is_god_mode_active = false

# --- Placeholder for Difficulty Manager related parameters (to be refined) ---
# Player Performance Metrics (examples)
# - Time to clear level
# - Lives lost
# - Bricks hit accuracy

# Difficulty Scaling Logic (examples)
# - Adjust ball speed based on performance
# - Adjust paddle size based on performance
# - Adjust brick health range based on performance