extends Node

# Game State Variables
var score = 0
var lives = 3
var current_level = 1
var high_score = 0

# Ball Acceleration
var destroyed_bricks_count = 0
var ball_acceleration_rate = 15.0 # Initial acceleration rate
var base_ball_speed = 500 # Initial ball speed, moved from ball.gd

# Game Signals
signal score_updated(new_score)
signal lives_updated(new_lives)
signal level_completed(level)
signal game_over()
signal ball_speed_increased(new_speed) # This signal is now emitted by GameManager
signal game_reset() # New signal for game reset

func _ready():
	# Load high score from user data if available
	load_high_score()

func add_score(amount: int):
	score += amount
	emit_signal("score_updated", score)
	print("Score: ", score)

func lose_life():
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
	destroyed_bricks_count = 0
	ball_acceleration_rate = 1.0 # Reset acceleration rate
	emit_signal("score_updated", score)
	emit_signal("lives_updated", lives)
	emit_signal("game_reset") # Emit signal when game is reset
	print("Game reset!")

func next_level():
	current_level += 1
	emit_signal("level_completed", current_level)
	print("Advancing to Level ", current_level)
	# Reset destroyed bricks count for the new level
	destroyed_bricks_count = 0
	# Potentially increase base ball speed or acceleration rate for new level
	# For now, just reset destroyed_bricks_count

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
	destroyed_bricks_count += 1
	print("GameManager: Bricks destroyed: ", destroyed_bricks_count)
	
	var new_speed = base_ball_speed + (destroyed_bricks_count * ball_acceleration_rate)
	emit_signal("ball_speed_increased", new_speed) # Emit signal for ball to update its speed

func get_current_ball_speed():
	return base_ball_speed + (destroyed_bricks_count * ball_acceleration_rate)

func _on_game_over_received():
	# This function will be connected to the game_over signal
	# It introduces a delay before reloading the scene
	await get_tree().create_timer(2.0).timeout # Wait for 2 seconds
	reset_game() # Reset game state before reloading
	get_tree().reload_current_scene()
