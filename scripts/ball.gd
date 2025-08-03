extends CharacterBody2D

var launched = false
var paddle_node: Node2D = null # Reference to the paddle
var current_speed: float = 0.0 # Track the intended speed

func _ready():
	# Initial direction (can be randomized or set by main scene)
	# Speed will be set by Main scene via set_speed
	velocity = Vector2(1, -1).normalized() * 0 # Start with 0 speed, will be set by Main

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
	# Velocity is already set by set_speed, just ensure it's not zero
	if velocity.length_squared() == 0:
		velocity = Vector2(1, -1).normalized() * 200 # Fallback default speed

func reset():
	print("Ball reset called!")
	launched = false
	# Reset position to paddle or center, to be handled by main scene
	# For now, just stop movement
	velocity = Vector2.ZERO

func set_speed(new_speed: float):
	# Update the speed and maintain the current direction
	current_speed = new_speed
	if velocity.length_squared() > 0:
		velocity = velocity.normalized() * new_speed
	else:
		# If velocity is zero, use a default direction
		velocity = Vector2(1, -1).normalized() * new_speed
	print("Ball speed updated to: ", new_speed)

func get_current_speed() -> float:
	return current_speed

func set_paddle_reference(paddle: Node2D):
	paddle_node = paddle
