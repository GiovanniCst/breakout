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
    print("DifficultyManager: Current level updated to: ", current_level_number)

func reset_difficulty():
    current_ball_speed = GameParameters.DEFAULT_BALL_SPEED
    current_paddle_scale = GameParameters.DEFAULT_PADDLE_SCALE
    current_brick_health_range = GameParameters.BRICK_HEALTH_RANGE
    current_brick_density = GameParameters.BRICK_DENSITY
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

    # Example: If player clears levels too fast, increase ball speed
    if player_level_clear_time < 30.0: # Arbitrary threshold
        current_ball_speed = min(current_ball_speed * 1.1, GameParameters.MAX_BALL_SPEED)
    elif player_level_clear_time > 60.0:
        current_ball_speed = max(current_ball_speed * 0.9, GameParameters.MIN_BALL_SPEED)

    # Example: If player loses too many lives, make paddle larger
    if player_lives_lost > 1:
        current_paddle_scale = min(current_paddle_scale * 1.05, GameParameters.MAX_PADDLE_SCALE)
    elif player_lives_lost == 0:
        current_paddle_scale = max(current_paddle_scale * 0.95, GameParameters.MIN_PADDLE_SCALE)

    # Example: Adjust brick health range based on accuracy
    if player_bricks_hit_accuracy > 0.8:
        current_brick_health_range.y = min(current_brick_health_range.y + 1, 5) # Max health 5
    elif player_bricks_hit_accuracy < 0.5:
        current_brick_health_range.y = max(current_brick_health_range.y - 1, 1) # Min health 1


    print("Difficulty adjusted: Ball Speed: %s, Paddle Scale: %s, Brick Health: %s, Brick Density: %s, Current Level: %s" % [current_ball_speed, current_paddle_scale, current_brick_health_range, current_brick_density, current_level_number])


func get_level_parameters() -> Dictionary:
    return {
        "ball_speed": current_ball_speed,
        "paddle_scale": current_paddle_scale,
        "brick_health_range": current_brick_health_range,
        "brick_density": current_brick_density,
        "level_number": current_level_number
    }