# difficulty_manager.gd
# This script manages dynamic difficulty adjustments based on player performance.

extends Node
class_name DifficultyManager

# Reference to game parameters
const GameParameters = preload("res://scripts/game_parameters.gd")

# Current game parameters, which will be adjusted dynamically
var current_ball_speed = GameParameters.DEFAULT_BALL_SPEED
var current_paddle_scale = GameParameters.DEFAULT_PADDLE_SCALE
var current_brick_health_range = GameParameters.BRICK_HEALTH_RANGE
var current_brick_density = GameParameters.BRICK_DENSITY
var current_brick_rows = GameParameters.DEFAULT_BRICK_ROWS # New: Track current brick rows
var current_unbreakable_bricks = GameParameters.BASE_UNBREAKABLE_BRICKS # New: Track current unbreakable bricks
var current_level_number = 1 # Track current level for difficulty adjustments

# Player performance metrics (placeholders)
var player_level_clear_time = 0.0
var player_lives_lost = 0
var player_bricks_hit_accuracy = 0.0 # Example: (bricks hit / total shots)

var game_manager_ref: Node # Reference to the GameManager singleton

func _ready():
    # Initialize with default parameters
    reset_difficulty()

func set_game_manager_reference(game_manager: Node):
    game_manager_ref = game_manager
    if not game_manager_ref.is_connected("level_updated", update_level_number):
        game_manager_ref.connect("level_updated", update_level_number)

func update_level_number(new_level: int):
    current_level_number = new_level
    # Calculate base ball speed for the new level
    current_ball_speed = GameParameters.DEFAULT_BALL_SPEED + (GameParameters.BASE_BALL_SPEED_INCREASE_PER_LEVEL * (current_level_number - 1))
    current_ball_speed = min(current_ball_speed, GameParameters.MAX_BALL_SPEED) # Cap at max speed
    print("DifficultyManager: Current level updated to: ", current_level_number, ". Base ball speed for level: ", current_ball_speed)

func reset_difficulty():
    current_ball_speed = GameParameters.DEFAULT_BALL_SPEED # Reset to default for level 1
    current_paddle_scale = GameParameters.DEFAULT_PADDLE_SCALE
    current_brick_health_range = GameParameters.BRICK_HEALTH_RANGE
    current_brick_density = GameParameters.BRICK_DENSITY
    current_brick_rows = GameParameters.DEFAULT_BRICK_ROWS
    current_unbreakable_bricks = GameParameters.BASE_UNBREAKABLE_BRICKS
    current_level_number = 1

func update_player_performance(clear_time: float, lives_lost: int, accuracy: float):
    player_level_clear_time = clear_time
    player_lives_lost = lives_lost
    player_bricks_hit_accuracy = accuracy
    _adjust_difficulty()

func _adjust_difficulty():
    # This is the core dynamic difficulty logic.
    # It will adjust `current_ball_speed`, `current_paddle_scale`, etc.
    # based on `player_level_clear_time`, `player_lives_lost`, `player_bricks_hit_accuracy`.

    # Adjust ball speed based on player performance and level
    var speed_increase_multiplier = 1.0 + (GameParameters.BALL_SPEED_INCREASE_RATE_PER_LEVEL * current_level_number)
    var speed_decrease_multiplier = 1.0 - (GameParameters.BALL_SPEED_INCREASE_RATE_PER_LEVEL * current_level_number * 0.5) # Less aggressive decrease

    if player_level_clear_time < 30.0: # Arbitrary threshold for fast clear
        current_ball_speed = min(current_ball_speed * speed_increase_multiplier, GameParameters.MAX_BALL_SPEED)
    elif player_level_clear_time > 60.0: # Arbitrary threshold for slow clear
        current_ball_speed = max(current_ball_speed * speed_decrease_multiplier, GameParameters.MIN_BALL_SPEED)

    # Adjust paddle scale based on player lives lost
    if player_lives_lost > 1:
        current_paddle_scale = min(current_paddle_scale * 1.05, GameParameters.MAX_PADDLE_SCALE)
    elif player_lives_lost == 0:
        current_paddle_scale = max(current_paddle_scale * 0.95, GameParameters.MIN_PADDLE_SCALE)

    # Adjust brick health range based on accuracy
    if player_bricks_hit_accuracy > 0.8:
        current_brick_health_range.y = min(current_brick_health_range.y + 1, 5) # Max health 5
    elif player_bricks_hit_accuracy < 0.5:
        current_brick_health_range.y = max(current_brick_health_range.y - 1, 1) # Min health 1

    # New: Increase brick density with level progression
    # Cap density at a maximum (e.g., 0.9 for 90% density)
    current_brick_density = min(GameParameters.BRICK_DENSITY + (current_level_number * 0.05), 0.9)

    # New: Increase number of brick rows with level progression
    current_brick_rows = min(GameParameters.DEFAULT_BRICK_ROWS + floor((current_level_number - 1) / 2.0), GameParameters.MAX_BRICK_ROWS)

    # New: Increase number of unbreakable bricks with level progression
    # New: Increase number of unbreakable bricks with level progression (slower, capped at 5)
    current_unbreakable_bricks = min(GameParameters.BASE_UNBREAKABLE_BRICKS + floor((current_level_number - 1) / 2.0), 5)

    print("Difficulty adjusted: Level: %s, Ball Speed: %s, Paddle Scale: %s, Brick Health: %s, Brick Density: %s, Brick Rows: %s, Unbreakable Bricks: %s" % [current_level_number, current_ball_speed, current_paddle_scale, current_brick_health_range, current_brick_density, current_brick_rows, current_unbreakable_bricks])


func get_level_parameters() -> Dictionary:
    return {
        "ball_speed": current_ball_speed,
        "paddle_scale": current_paddle_scale,
        "brick_health_range": current_brick_health_range,
        "brick_density": current_brick_density,
        "brick_rows": current_brick_rows, # New
        "unbreakable_bricks": current_unbreakable_bricks, # New
        "level_number": current_level_number
    }