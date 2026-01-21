extends CharacterBody2D

@export var  SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY = 1000
var muerto: bool
var ataca: bool = false

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if muerto:
		return
	# Gravedad (siempre) para evitar que pj se quede flotando en el aire
	velocity.y += GRAVITY * delta
	if !ataca:
		var input_direccion = Input.get_vector("Izquierda","Derecha","Arriba","Abajo")
		var horizontal = input_direccion.x
		var vertical = input_direccion.y

		

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
			if animated_sprite.animation != "Walk":
				animated_sprite.play("Walk")
			animated_sprite.flip_h = horizontal < 0
		else:
			if animated_sprite.animation != "Idle":
				animated_sprite.play("Idle")
	# Mover al personaje
	move_and_slide()
	



func _on_espinas_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	print("ENTRÓ EN EL AREA:", body.name)
	animated_sprite.play("Die")
	muerto = true
