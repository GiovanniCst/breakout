extends CharacterBody2D

@export var speed = 400
var launched = false

func _ready():
	# Initial direction (can be randomized or set by main scene)
	velocity = Vector2(1, -1).normalized() * speed

func _physics_process(delta):
	if launched:
		var collision_info = move_and_collide(velocity * delta)
		if collision_info:
			velocity = velocity.bounce(collision_info.get_normal())
			var collider = collision_info.get_collider()
			if collider.has_method("hit"):
				collider.hit()

func launch():
	launched = true
	# Re-initialize velocity when launched
	velocity = Vector2(1, -1).normalized() * speed

func reset():
	print("Ball reset called!")
	launched = false
	# Reset position to paddle or center, to be handled by main scene
	# For now, just stop movement
	velocity = Vector2.ZERO
