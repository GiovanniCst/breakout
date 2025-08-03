extends CharacterBody2D

@export var speed = 300
@export var speed_increment_rate = 0.001 # Adjust this value to control how fast speed increases
var initial_y_position: float
var current_speed_multiplier = 1.0
@onready var animated_sprite = $Sprite2D
var game_parameters_ref: Resource
var default_color: Color = Color.WHITE

func _ready():
	initial_y_position = global_position.y
	animated_sprite.play("default") # Start playing the animation by default
	default_color = animated_sprite.modulate # Store original color

func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		current_speed_multiplier += speed_increment_rate * delta
		velocity.x = direction * speed * current_speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * current_speed_multiplier)
		current_speed_multiplier = 1.0 # Reset multiplier when paddle stops
	
	velocity.y = 0 # Prevent vertical movement

	move_and_slide()
	
	global_position.y = initial_y_position # Strictly maintain vertical position

func set_god_mode_color(is_god_mode: bool):
	if animated_sprite:
		if is_god_mode:
			animated_sprite.modulate = Color.RED
		else:
			animated_sprite.modulate = default_color

func set_game_parameters_reference(params: Resource):
	game_parameters_ref = params
