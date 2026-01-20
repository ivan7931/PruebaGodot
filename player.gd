extends CharacterBody2D

@export var  SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY = 800

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_direccion = Input.get_vector("Atras","Alante","Arriba","Abajo")
	var horizontal = input_direccion.x
	var vertical = input_direccion.y

	# Gravedad (siempre) para evitar que pj se quede flotando en el aire
	velocity.y += GRAVITY * delta

	# Salto
	if is_on_floor() and vertical < 0:
		velocity.y = JUMP_VELOCITY
		if not is_on_floor() and vertical < 0 :
			velocity.y = JUMP_VELOCITY
	# Movimiento horizontal
	velocity.x = horizontal * SPEED

	# Animaciones
	if not is_on_floor():
		if animated_sprite.animation != "salto_completo":
			animated_sprite.play("salto_completo")
		# Flip en el aire
		if horizontal != 0:
			animated_sprite.flip_h = horizontal < 0
	elif horizontal != 0:
		if animated_sprite.animation != "caminar":
			animated_sprite.play("caminar")
		animated_sprite.flip_h = horizontal < 0
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

	# Mover al personaje
	move_and_slide()
