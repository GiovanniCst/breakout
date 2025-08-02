extends CanvasLayer

@onready var lives_container = $TopUI/LivesContainer
@onready var score_label = $TopUI/ScoreLabel
@onready var ball_speed_label = $TopUI/BallSpeedLabel
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
	if not GameManager.is_connected("ball_speed_increased", _on_ball_speed_increased):
		GameManager.connect("ball_speed_increased", _on_ball_speed_increased)
	if not GameManager.is_connected("game_over", _on_game_over):
		GameManager.connect("game_over", _on_game_over)
	if not GameManager.is_connected("game_reset", _on_game_reset): # New signal for game reset
		GameManager.connect("game_reset", _on_game_reset)
	
	# Initialize UI with current game state
	_on_score_updated(GameManager.score)
	_on_lives_updated(GameManager.lives)
	_on_ball_speed_increased(GameManager.base_ball_speed) # Initial ball speed
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
	print("UI: Received ball_speed_increased signal. New speed: ", new_speed)
	ball_speed_label.text = "Speed: " + str(int(new_speed)) # Display as integer

func _on_game_over():
	print("UI: Received game_over signal. Displaying game over message.")
	game_over_label.visible = true

func _on_game_reset():
	print("UI: Received game_reset signal. Hiding game over message.")
	game_over_label.visible = false
