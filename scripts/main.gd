extends Node

@export var ball_scene: PackedScene
@export var paddle_scene: PackedScene

var paddle: Node2D
var ball: CharacterBody2D
var bricks_node: Node2D # Reference to the Bricks Node2D
var pulverize_cooldown = false # Prevent multiple rapid pulverize actions

@onready var level_generator = LevelGenerator.new()
@onready var difficulty_manager = DifficultyManager.new()
const GameParametersClass = preload("res://scripts/game_parameters.gd")
var game_parameters: Resource

func _ready():
	# Initialize game parameters instance
	game_parameters = GameParametersClass.new()
	
	# Get node references explicitly
	paddle = get_node("Paddle")
	ball = get_node("Ball")
	bricks_node = get_node("Bricks")
	var ui_node = get_node("UI") # Get reference to the UI node

	# Ensure nodes are found
	if not is_instance_valid(paddle):
		print("Error: Paddle node not found!")
		return
	if not is_instance_valid(ball):
		print("Error: Ball node not found!")
		return
	if not is_instance_valid(bricks_node):
		print("Error: Bricks Node2D not found!")
		return
	if not is_instance_valid(ui_node):
		print("Error: UI node not found!")
		return
	
	# Pass paddle reference to the ball for initial positioning
	ball.set_paddle_reference(paddle)
	
	# Initialize UI after all nodes are ready
	ui_node.initialize_ui()

	# Set initial ball position above the paddle
	ball.global_position = paddle.global_position + Vector2(0, -18)
	
	# Connect GameManager signals
	if not GameManager.is_connected("game_over", GameManager._on_game_over_received):
		GameManager.connect("game_over", GameManager._on_game_over_received)
	if not GameManager.is_connected("level_completed", _on_level_completed): # New: Connect level_completed signal
		GameManager.connect("level_completed", _on_level_completed)
	
	# Reset game state at the start of the game
	GameManager.reset_game()
	difficulty_manager.reset_difficulty() # Reset difficulty at game start
	# Pass GameManager reference to DifficultyManager
	difficulty_manager.set_game_manager_reference(GameManager)
	# Pass game parameters reference to GameManager
	GameManager.set_game_parameters_reference(game_parameters)
	# Pass game parameters reference to Paddle
	if paddle.has_method("set_game_parameters_reference"):
		paddle.set_game_parameters_reference(game_parameters)

	_start_new_level() # Start the first level

func _start_new_level():
	# Clear existing bricks
	for child in bricks_node.get_children():
		child.queue_free()
	
	# Get level parameters from DifficultyManager
	var level_params = difficulty_manager.get_level_parameters()
	
	# Get viewport size
	var viewport_size = get_viewport().size

	# Generate level, passing viewport size, and get breakable brick count
	var generated_level_info = level_generator.generate_level(level_params, viewport_size)
	var generated_level = generated_level_info.level_node
	var breakable_brick_count = generated_level_info.breakable_brick_count
	
	bricks_node.add_child(generated_level)
	
	# Inform GameManager about the total number of breakable bricks
	GameManager.set_total_breakable_bricks(breakable_brick_count)

	# Update ball speed and paddle scale based on difficulty parameters
	var ball_speed = level_params.get("ball_speed", GameParametersClass.DEFAULT_BALL_SPEED)
	if ball.has_method("set_speed"):
		ball.set_speed(ball_speed)
	
	# Update UI with ball speed
	var ui_node = get_node("UI")
	if is_instance_valid(ui_node) and ui_node.has_method("_on_ball_speed_increased"):
		ui_node._on_ball_speed_increased(ball_speed)
	
	paddle.scale.x = level_params.get("paddle_scale", GameParametersClass.DEFAULT_PADDLE_SCALE)

	# Connect brick_destroyed signal from all newly generated bricks
	for brick_instance in generated_level.get_children():
		if brick_instance.has_signal("brick_destroyed"):
			if not brick_instance.is_connected("brick_destroyed", GameManager._on_brick_destroyed):
				brick_instance.connect("brick_destroyed", GameManager._on_brick_destroyed)

func _input(event):
	if event.is_action_pressed("launch"): # Use global Input check
		print("Launch action pressed!")
		if ball and not ball.launched:
			ball.launch()
	
	# Development shortcut: Press 'N' to advance to the next level
	if event.is_action_pressed("next_level_dev"): # Assuming "next_level_dev" action is set up
		print("Dev: Advancing to next level!")
		_start_new_level()
	
	# Debug shortcut: Press 'X' to pulverize all breakable bricks
	if event.is_action_pressed("pulverize_bricks") and not pulverize_cooldown:
		_execute_pulverize()
	
	# Toggle God Mode
	if event.is_action_pressed("god_mode"): # Assuming "god_mode" action is set up
		game_parameters.is_god_mode_active = not game_parameters.is_god_mode_active
		print("God Mode: ", "ON" if game_parameters.is_god_mode_active else "OFF")
		# Update paddle color immediately
		if paddle.has_method("set_god_mode_color"):
			paddle.set_god_mode_color(game_parameters.is_god_mode_active)

func _execute_pulverize():
	pulverize_cooldown = true # Set cooldown to prevent rapid re-execution
	print("Dev: Pulverizing all breakable bricks!")
	
	# Create a list of bricks to destroy to avoid modifying the collection while iterating
	var bricks_to_destroy = []
	
	# Check hierarchy - bricks are children of level nodes
	for level_node in bricks_node.get_children():
		for child in level_node.get_children():
			# Check if the child is a breakable brick
			if child.has_method("instant_destroy") and not child is UnbreakableBrick:
				bricks_to_destroy.append(child)
	
	print("Dev: Found ", bricks_to_destroy.size(), " breakable bricks to destroy")
	if bricks_to_destroy.size() > 0:
		for brick in bricks_to_destroy:
			brick.instant_destroy()
	
	# Clean up any existing cooldown timers to prevent timer accumulation
	var existing_timers = get_children().filter(func(child): return child is Timer and child.has_signal("timeout"))
	for timer in existing_timers:
		if timer.is_connected("timeout", _reset_pulverize_cooldown):
			timer.queue_free()
	
	# Reset cooldown after a delay using a timer
	var timer = Timer.new()
	timer.name = "PulverizeCooldownTimer"
	add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_reset_pulverize_cooldown)
	timer.start()

func _reset_pulverize_cooldown():
	pulverize_cooldown = false
	print("Dev: Pulverize cooldown reset")

func get_ball():
	return ball

func _on_ball_out_of_bounds(body): # Add 'body' parameter for Area2D signal
	# Only trigger if it's actually the ball that went out of bounds
	if body == ball and is_instance_valid(ball):
		print("Ball out of bounds! Resetting...")
		# Lose a life when ball goes out of bounds
		GameManager.lose_life()
		
		ball.reset()
		# Reposition ball above paddle, adjust offset for better placement
		ball.global_position = paddle.global_position + Vector2(0, -18) # Adjusted offset
		# Pass paddle reference to the ball again after reset
		ball.set_paddle_reference(paddle)
		
		# Reset ball speed and paddle scale to current difficulty settings after losing a life
		var current_params = difficulty_manager.get_level_parameters()
		var ball_speed = current_params.get("ball_speed", GameParametersClass.DEFAULT_BALL_SPEED)
		if ball.has_method("set_speed"):
			ball.set_speed(ball_speed)
		paddle.scale.x = current_params.get("paddle_scale", GameParametersClass.DEFAULT_PADDLE_SCALE)

func _on_level_completed(level: int):
	print("Main: Level ", level, " completed! Advancing to next level.")
	# Advance to the next level after a short delay
	await get_tree().create_timer(1.0).timeout # Adjust delay as needed
	
	# Call GameManager.next_level() to increment level and update difficulty
	GameManager.next_level(0.0, 0, 1.0) # Using placeholder values for level clear time, lives lost, and accuracy
	# Update difficulty manager with the new level number
	difficulty_manager.update_level_number(GameManager.current_level)
	
	# Start the new level
	_start_new_level()
