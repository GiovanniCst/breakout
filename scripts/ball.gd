extends CharacterBody2D

var launched = false
var paddle_node: Node2D = null # Reference to the paddle
var current_speed: float = 0.0 # Track the intended speed
var spin_effect: float = 0.0 # Represents the horizontal spin applied to the ball
@export var spin_strength: float = 0.002 # How strongly paddle movement creates spin
@export var spin_decay_rate: float = 0.98 # How fast the spin effect decays per frame (0.0 to 1.0)
@export var min_bounce_angle_deg: float = 30.0 # Minimum angle from horizontal for bounces (to prevent sticking)

func _ready():
	# Initial direction (can be randomized or set by main scene)
	# Speed will be set by Main scene via set_speed
	velocity = Vector2(1, -1).normalized() * 0 # Start with 0 speed, will be set by Main

func _physics_process(delta):
	if not launched and is_instance_valid(paddle_node):
		# Keep ball centered on paddle horizontally
		global_position.x = paddle_node.global_position.x
	elif launched:
		# Apply spin effect as a continuous horizontal acceleration
		if abs(spin_effect) > 0.01: # Only apply if spin is significant
			velocity.x += spin_effect * delta * current_speed # Scale spin by current speed
			spin_effect *= spin_decay_rate # Decay spin over time
		else:
			spin_effect = 0.0 # Reset if negligible

		var collision_info = move_and_collide(velocity * delta)
		if collision_info:
			var normal = collision_info.get_normal()
			var collider = collision_info.get_collider()

			if collider == paddle_node:
				# Special paddle bounce with spin calculation
				handle_paddle_bounce(collision_info)
			else:
				# Normal bounce for other colliders (bricks, walls)
				velocity = velocity.bounce(normal)
				# Ensure minimum bounce angle to prevent sticking
				ensure_min_bounce_angle(normal)

			if collider.has_method("hit"):
				collider.hit()
		
		# Re-normalize velocity to maintain consistent speed after all forces/bounces
		velocity = velocity.normalized() * current_speed

func handle_paddle_bounce(collision_info):
	# Get collision details
	var collision_point = collision_info.get_position()
	var paddle_center_x = paddle_node.global_position.x
	
	# Determine paddle half-width based on shape type
	var paddle_collision_shape = paddle_node.shape_owner_get_shape(0, 0)
	var paddle_half_width: float
	if paddle_collision_shape is CapsuleShape2D:
		paddle_half_width = paddle_collision_shape.radius
	elif paddle_collision_shape is RectangleShape2D:
		paddle_half_width = paddle_collision_shape.size.x / 2
	else:
		paddle_half_width = 30.0 # Default fallback

	# Calculate where on the paddle the ball hit (-1 = left edge, 0 = center, 1 = right edge)
	var hit_position = (collision_point.x - paddle_center_x) / paddle_half_width
	hit_position = clamp(hit_position, -1.0, 1.0) # Ensure it's within bounds
	
	# Calculate initial bounce angle (mostly vertical, influenced by hit position)
	# This is the initial "kick" off the paddle
	var initial_bounce_angle = -PI/2 + (hit_position * PI/6) # Smaller spread for initial kick
	
	# Set initial velocity based on this angle
	velocity = Vector2(cos(initial_bounce_angle), sin(initial_bounce_angle)) * current_speed
	
	# Calculate spin effect based on paddle velocity and hit position
	# Faster paddle movement and off-center hits create more spin
	spin_effect = paddle_node.velocity.x * spin_strength * (1.0 + abs(hit_position))
	
	# DEBUG LOGGING - Evidence of parameter influence
	print("=== PADDLE BOUNCE DEBUG (Spin System) ===")
	print("Paddle velocity X: ", paddle_node.velocity.x)
	print("Hit position on paddle: ", hit_position)
	print("Initial bounce angle (degrees): ", rad_to_deg(initial_bounce_angle))
	print("Calculated spin effect: ", spin_effect)
	print("Spin strength setting: ", spin_strength)
	print("Spin decay rate setting: ", spin_decay_rate)
	print("Resulting initial ball velocity: ", velocity)
	print("Ball speed maintained: ", velocity.length())
	print("========================================")

func ensure_min_bounce_angle(normal: Vector2):
	# This function ensures the ball doesn't get stuck by having too shallow an angle
	var current_angle = velocity.angle()
	var min_angle_rad = deg_to_rad(min_bounce_angle_deg)

	if normal.y != 0: # Bouncing off horizontal surface (top/bottom walls, paddle)
		# Ensure vertical component is strong enough
		if abs(velocity.y) < current_speed * sin(min_angle_rad):
			velocity.y = sign(velocity.y) * current_speed * sin(min_angle_rad)
			velocity.x = sign(velocity.x) * sqrt(current_speed*current_speed - velocity.y*velocity.y)
	elif normal.x != 0: # Bouncing off vertical surface (side walls)
		# Ensure horizontal component is strong enough
		if abs(velocity.x) < current_speed * sin(min_angle_rad):
			velocity.x = sign(velocity.x) * current_speed * sin(min_angle_rad)
			velocity.y = sign(velocity.y) * sqrt(current_speed*current_speed - velocity.x*velocity.x)
	
	# Re-normalize to ensure speed is exactly current_speed after adjustment
	velocity = velocity.normalized() * current_speed

func launch():
	launched = true
	if velocity.length_squared() == 0:
		velocity = Vector2(1, -1).normalized() * 200 # Fallback default speed

func reset():
	print("Ball reset called!")
	launched = false
	velocity = Vector2.ZERO
	spin_effect = 0.0 # Reset spin on ball reset

func set_speed(new_speed: float):
	current_speed = new_speed
	if velocity.length_squared() > 0:
		velocity = velocity.normalized() * new_speed
	else:
		velocity = Vector2(1, -1).normalized() * new_speed
	print("Ball speed updated to: ", new_speed)

func get_current_speed() -> float:
	return current_speed

func set_paddle_reference(paddle: Node2D):
	paddle_node = paddle
