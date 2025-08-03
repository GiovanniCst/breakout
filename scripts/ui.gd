extends CanvasLayer

const GameParameters = preload("res://scripts/game_parameters.gd") # Preload GameParameters

@onready var lives_container = $TopUI/LivesContainer
@onready var score_label = $TopUI/ScoreLabel
@onready var ball_speed_label = $TopUI/BallSpeedLabel
@onready var level_label = $TopUI/LevelLabel # New: Reference to the LevelLabel
@onready var game_over_label = $GameOverLabel

func _ready():
	print("UI: _ready called. Waiting for main.gd to call initialize_ui().")
	# _ready will no longer call initialize_ui directly.
	# main.gd is now responsible for calling initialize_ui() after all nodes are ready.

func initialize_ui():
	print("UI: initialize_ui called. Connecting signals and initializing UI.")
	# Ensure signals are not connected multiple times
	if not GameManager.is_connected("score_updated", _on_score_updated):
		GameManager.connect("score_updated", _on_score_updated)
	if not GameManager.is_connected("lives_updated", _on_lives_updated):
		GameManager.connect("lives_updated", _on_lives_updated)
	# Removed: GameManager.connect("ball_speed_increased", _on_ball_speed_increased)
	if not GameManager.is_connected("game_over", _on_game_over):
		GameManager.connect("game_over", _on_game_over)
	if not GameManager.is_connected("game_reset", _on_game_reset): # New signal for game reset
		GameManager.connect("game_reset", _on_game_reset)
	if not GameManager.is_connected("ball_speed_increased", _on_ball_speed_increased):
		GameManager.connect("ball_speed_increased", _on_ball_speed_increased)
	if not GameManager.is_connected("level_updated", _on_level_updated): # New: Connect level_updated signal
		GameManager.connect("level_updated", _on_level_updated)
	if not GameManager.is_connected("level_completed", _on_level_completed): # New: Connect level_completed signal
		GameManager.connect("level_completed", _on_level_completed)
	
	# Initialize UI with current game state (without triggering duplicate prints)
	score_label.text = "Score: " + str(GameManager.score)
	for i in range(lives_container.get_child_count()):
		var heart = lives_container.get_child(i)
		heart.visible = i < GameManager.lives
	ball_speed_label.text = "Speed: " + str(int(GameParameters.DEFAULT_BALL_SPEED))
	level_label.text = "Level: " + str(GameManager.current_level) # New: Initialize level label
	game_over_label.visible = false # Ensure game over message is hidden at start

func _on_score_updated(new_score: int):
	print("UI: Received score_updated signal. New score: ", new_score)
	score_label.text = "Score: " + str(new_score)

func _on_lives_updated(new_lives: int):
	print("UI: Received lives_updated signal. New lives: ", new_lives)
	for i in range(lives_container.get_child_count()):
		var heart = lives_container.get_child(i)
		if i < new_lives:
			heart.visible = true
		else:
			heart.visible = false

func _on_ball_speed_increased(new_speed: float):
	# This function is now called by Main.gd or other scripts directly
	# when ball speed changes, not by GameManager signal.
	print("UI: Ball speed updated to: ", new_speed)
	ball_speed_label.text = "Speed: " + str(int(new_speed)) # Display as integer

func _on_game_over():
	print("UI: Received game_over signal. Displaying game over message.")
	game_over_label.visible = true

func _on_level_updated(new_level: int):
	print("UI: Received level_updated signal. New level: ", new_level)
	level_label.text = "Level: " + str(new_level)

func _on_level_completed(level: int):
	print("UI: Received level_completed signal for level: ", level)
	# Optionally display a "Level Complete!" message here before main.gd advances

func _on_game_reset():
	print("UI: Received game_reset signal. Hiding game over message.")
	game_over_label.visible = false
