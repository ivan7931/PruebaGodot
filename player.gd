extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY = 1800
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:

	var input_direccion = Input.get_vector("Atras", "Alante", "Arriba", "Abajo")
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity = input_direccion * SPEED
		animated_sprite.play("Walk")
	if input_direccion:
		velocity = input_direccion * SPEED
		animated_sprite.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("Idle")
	move_and_slide() 

	# Handle jump.
	
