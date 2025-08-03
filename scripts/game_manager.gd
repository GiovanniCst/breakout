extends Node

# Reference to game parameters
const GameParametersClass = preload("res://scripts/game_parameters.gd")
var game_parameters_ref: Resource

# Game State Variables
var score = 0
var lives = 3
var current_level = 1
var high_score = 0
var bricks_destroyed_this_level = 0 # Track bricks destroyed per level
var total_breakable_bricks_in_level = 0 # Track total breakable bricks for current level

# Game Signals
signal score_updated(new_score)
signal lives_updated(new_lives)
signal level_completed(level)
signal game_over()
signal game_reset() # New signal for game reset
signal ball_speed_increased(new_speed) # Signal when ball speed increases
signal level_updated(new_level) # Signal when level changes

# Reference to DifficultyManager (will be set by Main scene)
var difficulty_manager_ref: Node

func _ready():
	# Load high score from user data if available
	load_high_score()

func add_score(amount: int):
	score += amount
	emit_signal("score_updated", score)
	print("Score: ", score)

func lose_life():
	if game_parameters_ref and game_parameters_ref.is_god_mode_active:
		print("God Mode active! Lives not lost.")
		return # Do not lose a life if god mode is active

	lives -= 1
	emit_signal("lives_updated", lives)
	print("Lives: ", lives)
	if lives <= 0:
		emit_signal("game_over")
		print("Game Over!")
		# Do not reload scene immediately. Let the UI display the message first.
		# The scene will be reloaded after a delay by a connected function.

func reset_game():
	score = 0
	lives = 3
	current_level = 1
	bricks_destroyed_this_level = 0
	total_breakable_bricks_in_level = 0 # Reset total breakable bricks
	emit_signal("score_updated", score)
	emit_signal("lives_updated", lives)
	emit_signal("level_updated", current_level) # Emit signal for level update
	emit_signal("game_reset") # Emit signal when game is reset
	if is_instance_valid(difficulty_manager_ref):
		difficulty_manager_ref.reset_difficulty()
	print("Game reset!")

func next_level(level_clear_time: float, lives_lost_this_level: int, bricks_hit_accuracy: float):
	current_level += 1
	bricks_destroyed_this_level = 0 # Reset for new level
	total_breakable_bricks_in_level = 0 # Reset total breakable bricks for new level
	emit_signal("level_updated", current_level) # Emit signal for level update

	if is_instance_valid(difficulty_manager_ref):
		difficulty_manager_ref.update_player_performance(level_clear_time, lives_lost_this_level, bricks_hit_accuracy)

	print("Advancing to Level ", current_level)

func update_high_score():
	if score > high_score:
		high_score = score
		save_high_score()
		print("New High Score: ", high_score)

func save_high_score():
	var file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	if file:
		file.store_line(str(high_score))
		file.close()

func load_high_score():
	if FileAccess.file_exists("user://highscore.save"):
		var file = FileAccess.open("user://highscore.save", FileAccess.READ)
		if file:
			high_score = int(file.get_line())
			file.close()
			print("Loaded High Score: ", high_score)

func _on_brick_destroyed():
	bricks_destroyed_this_level += 1
	total_breakable_bricks_in_level -= 1 # Decrement breakable brick count
	print("GameManager: Bricks destroyed this level: ", bricks_destroyed_this_level)
	print("GameManager: Remaining breakable bricks: ", total_breakable_bricks_in_level)
	
	# Increase ball speed every few bricks destroyed
	if bricks_destroyed_this_level % 3 == 0: # Every 3 bricks
		increase_ball_speed()

	# Check for level completion
	if total_breakable_bricks_in_level <= 0:
		emit_signal("level_completed", current_level)
		print("Level ", current_level, " completed!")

func increase_ball_speed():
	# Get the current ball from the main scene
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("get_ball"):
		var ball = main_scene.get_ball()
		if ball and ball.has_method("set_speed") and ball.has_method("get_current_speed"):
			if is_instance_valid(difficulty_manager_ref): # Ensure difficulty_manager_ref is valid
				var current_speed = ball.get_current_speed()
				
				# Get level-dependent speed increase rate from DifficultyManager
				var level_params = difficulty_manager_ref.get_level_parameters()
				var current_level = level_params.get("level_number", 1)
				var speed_increase_multiplier = 1.0 + (GameParametersClass.BALL_SPEED_INCREASE_RATE_PER_LEVEL * current_level)
				
				var new_speed = min(current_speed * speed_increase_multiplier, GameParametersClass.MAX_BALL_SPEED)
				ball.set_speed(new_speed)
				emit_signal("ball_speed_increased", new_speed)
				print("Ball speed increased to: ", new_speed, " (Level-dependent multiplier: ", speed_increase_multiplier, ")")
			else:
				print("GameManager: DifficultyManager reference not set, cannot increase ball speed with level-dependent rate.")
				# Fallback to a default speed increase if DifficultyManager is not ready
				var current_speed = ball.get_current_speed()
				var new_speed = min(current_speed * 1.1, GameParametersClass.MAX_BALL_SPEED)
				ball.set_speed(new_speed)
				emit_signal("ball_speed_increased", new_speed)
				print("Ball speed increased to: ", new_speed, " (Using default rate due to missing DifficultyManager)")

func _on_game_over_received():
	# This function will be connected to the game_over signal
	# It introduces a delay before reloading the scene
	await get_tree().create_timer(2.0).timeout # Wait for 2 seconds
	reset_game() # Reset game state before reloading
	get_tree().reload_current_scene()

func set_total_breakable_bricks(count: int):
	total_breakable_bricks_in_level = count
	print("GameManager: Total breakable bricks set to: ", count)

func set_game_parameters_reference(params: Resource):
	game_parameters_ref = params

func set_difficulty_manager_reference(dm: Node):
	difficulty_manager_ref = dm
