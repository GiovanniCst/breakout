extends CharacterBody2D

@export var speed = 300

func _physics_process(_delta):
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	velocity.y = 0 # Prevent vertical movement

	move_and_slide()
	
