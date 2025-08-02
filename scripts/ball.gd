extends CharacterBody2D

var launched = false
var paddle_node: Node2D = null # Reference to the paddle

func _ready():
	# Initial direction (can be randomized or set by main scene)
	velocity = Vector2(1, -1).normalized() * GameManager.base_ball_speed
	# Connect to GameManager's ball_speed_increased signal
	GameManager.connect("ball_speed_increased", update_speed)

func _physics_process(delta):
	if not launched and is_instance_valid(paddle_node):
		# Keep ball centered on paddle horizontally
		global_position.x = paddle_node.global_position.x
	elif launched:
		var collision_info = move_and_collide(velocity * delta)
		if collision_info:
			velocity = velocity.bounce(collision_info.get_normal())
			var collider = collision_info.get_collider()
			if collider.has_method("hit"):
				collider.hit()

func launch():
	launched = true
	# Re-initialize velocity when launched, using current speed from GameManager
	velocity = Vector2(1, -1).normalized() * GameManager.get_current_ball_speed()

func reset():
	print("Ball reset called!")
	launched = false
	# Reset position to paddle or center, to be handled by main scene
	# For now, just stop movement
	velocity = Vector2.ZERO
	# Reset ball speed to base speed from GameManager on reset
	GameManager.destroyed_bricks_count = 0 # Reset destroyed bricks count in GameManager
	GameManager.emit_signal("ball_speed_increased", GameManager.base_ball_speed) # Reset ball speed

func update_speed(new_speed: float):
	# Update the speed and maintain the current direction
	# Note: The 'speed' variable in ball.gd is no longer @exported, it's managed by GameManager
	velocity = velocity.normalized() * new_speed
	print("Ball speed updated to: ", new_speed)

func set_paddle_reference(paddle: Node2D):
	paddle_node = paddle
