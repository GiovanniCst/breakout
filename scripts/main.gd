extends Node

@export var ball_scene: PackedScene
@export var paddle_scene: PackedScene
@export var brick_scene: PackedScene # Export brick scene for instantiation

@export var brick_rows: int = 3
@export var bricks_per_row: int = 8
@export var brick_start_y: float = 50.0 # Starting Y position for the first row
@export var brick_spacing_x: float = 5.0 # Horizontal spacing between bricks
@export var brick_spacing_y: float = 5.0 # Vertical spacing between rows

@onready var paddle = $Paddle
@onready var ball = $Ball
@onready var bricks_node = $Bricks # Reference to the Bricks Node2D

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

# Scaled brick dimensions (original 384x128, scaled by 0.15)
const SCALED_BRICK_WIDTH = 384 * 0.15
const SCALED_BRICK_HEIGHT = 128 * 0.15

func _ready():
	# Ensure ball and paddle are in the scene, or instantiate them if needed
	if not paddle:
		print("Paddle node not found!")
	if not ball:
		print("Ball node not found!")
	
	# Pass paddle reference to the ball for initial positioning
	if ball and paddle:
		ball.set_paddle_reference(paddle)
	
	_populate_bricks() # Call the brick population function

func _populate_bricks():
	if not is_instance_valid(bricks_node):
		print("Error: Bricks Node2D not found in Main scene!")
		return

	# Clear existing bricks if any (useful for level resets)
	for child in bricks_node.get_children():
		child.queue_free()

	var current_x = 0.0
	var current_y = brick_start_y

	for row in range(brick_rows):
		current_x = (get_viewport().size.x - (bricks_per_row * SCALED_BRICK_WIDTH + (bricks_per_row - 1) * brick_spacing_x)) / 2.0 # Center bricks horizontally
		for col in range(bricks_per_row):
			var new_brick = brick_scene.instantiate()
			bricks_node.add_child(new_brick)

			# Randomly select a non-cracked brick texture
			var random_texture_path = non_cracked_brick_textures[randi() % non_cracked_brick_textures.size()]
			new_brick.set_brick_texture(random_texture_path)

			new_brick.position = Vector2(current_x + SCALED_BRICK_WIDTH / 2, current_y + SCALED_BRICK_HEIGHT / 2) # Position brick by its center
			current_x += SCALED_BRICK_WIDTH + brick_spacing_x
		current_y += SCALED_BRICK_HEIGHT + brick_spacing_y

func _input(_event):
	if Input.is_action_just_pressed("launch"): # Use global Input check
		print("Launch action pressed!")
		if ball and not ball.launched:
			ball.launch()

func _on_ball_out_of_bounds(body): # Add 'body' parameter for Area2D signal
	print("Ball out of bounds! Resetting...")
	if body == ball: # Ensure it's the ball that entered the area
		if is_instance_valid(ball): # Check if ball node is still valid
			ball.reset()
			# Reposition ball above paddle, adjust offset for better placement
			ball.global_position = paddle.global_position + Vector2(0, -30) # Adjusted offset
			# Pass paddle reference to the ball again after reset
			ball.set_paddle_reference(paddle)
		else:
			print("Error: Ball node is not valid when out of bounds!")
