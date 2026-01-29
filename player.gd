extends CharacterBody2D

@export var  SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY = 1000
@export var DURACION_ATAQUE = 2
var muerto: bool
var ataca: bool = false
var tiempo_ataque = 1
var deslizando = false

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	#SI MUERE NO RECIBE MÁS INPUTS
	if muerto:
		return
	#gravedad siempre activa para que no flote
	velocity.y += GRAVITY * delta
	#código para detectar movimiento
	var input_direccion = Input.get_vector("Izquierda","Derecha","Arriba","Abajo")
	#IZQUIERDA(-1) DERECHA(+1)
	var horizontal = input_direccion.x
	#ARRIBA(-1)-ABAJO(+1)
	var vertical = input_direccion.y
	#SI ESTÁ EN EL SUELO Y PULSA ARRIBA -> SALTA
	if horizontal!=0:
		animated_sprite.flip_h = horizontal < 0
	if is_on_floor() and vertical < 0:
		velocity.y = JUMP_VELOCITY
	#detectar ataque
	if Input.is_action_just_pressed("Atacar") and not ataca:
		ataca = true
		tiempo_ataque = 1
		animated_sprite.play("Atack")
	# Movimiento horizontal
	velocity.x = horizontal * SPEED
	
	#CODIGO PARA ANIMACIONES
	if ataca:
		atacar()
		tiempo_ataque += delta
		if tiempo_ataque >= DURACION_ATAQUE:
			ataca = false
			
	#SI ABAJO (+1) DESLIZAR
	else:
		if is_on_floor() and vertical > 0:
			animated_sprite.play("deslizar")
			agacharse()
		#SI NO ESTA EN EL SUELO SALTO
		elif not is_on_floor():
			animated_sprite.play("salto_completo")
			
		# SI DERECHA/IZQUIERDA CAMINA
		elif horizontal !=0 :
			animated_sprite.play("Walk")
			
		#EN EL SUELO Y SIN MOVIMIENTO QUIETO
		else:
			animated_sprite.play("Idle")
	move_and_slide()
		



func _on_espinas_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	print("ENTRÓ EN EL AREA:", body.name)
	animated_sprite.play("Die")
	muerto = true
	
func agacharse():
	$PlayerColission.disabled=true
	$atacar.disabled = true
	$deslizar.disabled = false
	
func atacar():
	$PlayerColission.disabled = true
	$deslizar.disabled = true
	$atacar.disabled = false
	# Crear un temporizador que vuelva a la postura normal
	var timer = get_tree().create_timer(1)
	await timer.timeout  # espera DURACION_ATAQUE segundos
	
	# Volver a la postura de pie
	de_pie()
func de_pie():
	$deslizar.disabled = true
	$atacar.disabled = true
	$PlayerColission.disabled = false
