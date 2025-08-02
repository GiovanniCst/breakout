extends Node

@export var ball_scene: PackedScene
@export var paddle_scene: PackedScene

@onready var paddle = $Paddle
@onready var ball = $Ball

func _ready():
	# Ensure ball and paddle are in the scene, or instantiate them if needed
	if not paddle:
		print("Paddle node not found!")
	if not ball:
		print("Ball node not found!")
	
	# Pass paddle reference to the ball for initial positioning
	if ball and paddle:
		ball.set_paddle_reference(paddle)

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
