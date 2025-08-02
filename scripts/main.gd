extends Node

@export var ball_scene: PackedScene
@export var paddle_scene: PackedScene
@export var brick_scene: PackedScene # Export brick scene for instantiation

@export var brick_rows: int = 3
@export var bricks_per_row: int = 8
@export var brick_start_y: float = 50.0 # Starting Y position for the first row
@export var brick_spacing_x: float = 5.0 # Horizontal spacing between bricks
@export var brick_spacing_y: float = 5.0 # Vertical spacing between rows

var paddle: Node2D
var ball: CharacterBody2D
var bricks_node: Node2D # Reference to the Bricks Node2D

# Paths to non-cracked brick textures (odd numbers from 01 to 19)
var non_cracked_brick_textures = [
	"res://assets/PNG/01-Breakout-Tiles.png",
	"res://assets/PNG/03-Breakout-Tiles.png",
	"res://assets/PNG/05-Breakout-Tiles.png",
	"res://assets/PNG/07-Breakout-Tiles.png",
	"res://assets/PNG/09-Breakout-Tiles.png",
	"res://assets/PNG/11-Breakout-Tiles.png",
	"res://assets/PNG/13-Breakout-Tiles.png",
	"res://assets/PNG/15-Breakout-Tiles.png",
	"res://assets/PNG/17-Breakout-Tiles.png",
	"res://assets/PNG/19-Breakout-Tiles.png"
]

# Paths to unbreakable brick textures (from 22 to 30)
var unbreakable_brick_textures = [
	"res://assets/PNG/22-Breakout-Tiles.png",
	"res://assets/PNG/23-Breakout-Tiles.png",
	"res://assets/PNG/24-Breakout-Tiles.png",
	"res://assets/PNG/25-Breakout-Tiles.png",
	"res://assets/PNG/26-Breakout-Tiles.png",
	"res://assets/PNG/27-Breakout-Tiles.png",
	"res://assets/PNG/28-Breakout-Tiles.png",
	"res://assets/PNG/29-Breakout-Tiles.png",
	"res://assets/PNG/30-Breakout-Tiles.png"
]

# Scaled brick dimensions (original 384x128, scaled by 0.15)
const SCALED_BRICK_WIDTH = 384 * 0.15
const SCALED_BRICK_HEIGHT = 128 * 0.15

func _ready():
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
	
	_populate_bricks() # Call the brick population function
	_populate_unbreakable_bricks() # Call the unbreakable brick population function

func _populate_bricks():
	if not is_instance_valid(bricks_node):
		print("Error: Bricks Node2D not found in Main scene!")
		return

	# Clear existing bricks if any (useful for level resets)
	for child in bricks_node.get_children():
		child.queue_free()
	
	GameManager.destroyed_bricks_count = 0 # Reset destroyed bricks count for new level/population

	var current_x = 0.0
	var current_y = brick_start_y

	for row in range(brick_rows):
		current_x = (get_viewport().size.x - (bricks_per_row * SCALED_BRICK_WIDTH + (bricks_per_row - 1) * brick_spacing_x)) / 2.0 # Center bricks horizontally
		for col in range(bricks_per_row):
			var new_brick = brick_scene.instantiate()
			bricks_node.add_child(new_brick)

			# Connect the brick_destroyed signal to GameManager
			new_brick.connect("brick_destroyed", GameManager._on_brick_destroyed)

			# Randomly select a non-cracked brick texture
			var random_texture_path = non_cracked_brick_textures[randi() % non_cracked_brick_textures.size()]
			new_brick.set_brick_texture(random_texture_path)

			new_brick.position = Vector2(current_x + SCALED_BRICK_WIDTH / 2, current_y + SCALED_BRICK_HEIGHT / 2) # Position brick by its center
			current_x += SCALED_BRICK_WIDTH + brick_spacing_x
		current_y += SCALED_BRICK_HEIGHT + brick_spacing_y

func _populate_unbreakable_bricks():
	if not is_instance_valid(bricks_node):
		print("Error: Bricks Node2D not found in Main scene for unbreakable bricks!")
		return

	var unbreakable_brick_min_y = 200.0 # Starting Y position for unbreakable bricks
	var unbreakable_brick_max_y = 400.0 # Ending Y position for unbreakable bricks
	var min_unbreakable_bricks = 3
	var max_unbreakable_bricks = 7
	var num_unbreakable_bricks = randi_range(min_unbreakable_bricks, max_unbreakable_bricks)

	var unbreakable_brick_packed_scene = load("res://unbreakable_brick.tscn")
	if not unbreakable_brick_packed_scene:
		print("Error: Could not load unbreakable_brick.tscn!")
		return

	for i in range(num_unbreakable_bricks):
		var new_unbreakable_brick = unbreakable_brick_packed_scene.instantiate()
		bricks_node.add_child(new_unbreakable_brick)

		var random_texture_path = unbreakable_brick_textures[randi() % unbreakable_brick_textures.size()]
		new_unbreakable_brick.set_brick_texture(random_texture_path)

		var random_x = randf_range(SCALED_BRICK_WIDTH / 2, get_viewport().size.x - SCALED_BRICK_WIDTH / 2)
		var random_y = randf_range(unbreakable_brick_min_y + SCALED_BRICK_HEIGHT / 2, unbreakable_brick_max_y - SCALED_BRICK_HEIGHT / 2)
		new_unbreakable_brick.position = Vector2(random_x, random_y)

func _input(_event):
	if Input.is_action_just_pressed("launch"): # Use global Input check
		print("Launch action pressed!")
		if ball and not ball.launched:
			ball.launch()

func _on_ball_out_of_bounds(body): # Add 'body' parameter for Area2D signal
	print("Ball out of bounds! Resetting...")
	if body == ball: # Ensure it's the ball that entered the area
		if is_instance_valid(ball): # Check if ball node is still valid
			# Lose a life when ball goes out of bounds
			GameManager.lose_life()
			
			ball.reset()
			# Reposition ball above paddle, adjust offset for better placement
			ball.global_position = paddle.global_position + Vector2(0, -18) # Adjusted offset
			# Pass paddle reference to the ball again after reset
			ball.set_paddle_reference(paddle)
		else:
			print("Error: Ball node is not valid when out of bounds!")
