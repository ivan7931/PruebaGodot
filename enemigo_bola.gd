extends CharacterBody2D

@export var speed := 250.0
@export var gravity := 1000.0
@export var vida := 2
@export var tiempo_rodar := 2.0

var estado :="Idle"
var direccion := 1 #Para que empiece hacia la izquierda

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $SpinTimer

func _ready() -> void:
	anim.play("Idle")
	timer.start()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	if estado == "Idle":
		velocity.x = 0

	elif estado == "Rodando":
		velocity.x = direccion * speed

	move_and_slide()

	# Detectar pared y rebotar
	if estado == "Rodando" and is_on_wall():
		print("💥 REBOTE")
		direccion *= -1
		anim.flip_h = direccion < 0
	


func _on_spin_timer_timeout() -> void:
	if estado == "Idle":
		estado = "Rodando"
		anim.play("Rodar")
		timer.start(tiempo_rodar)
	else:
		estado = "Idle" 
		anim.play("Idle")
		timer.start(3.0) #El tiempo hasta volver a rodar


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.jugador_siendo_atacado()

func morir():
	$AttackTimer.stop()
	velocity = Vector2.ZERO
	anim.play("Muerte")
	await anim.animation_finished
	queue_free()
	
func siendo_atacado():
	vida -=1
	if vida <=0:
		morir()
