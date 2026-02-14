extends CharacterBody2D

@export var speed := 150.0
@export var distancia := 310.0
@export var tiempo_espera := 2.0

var direccion := 1       # 1 derecha, -1 izquierda
var limite_derecha := 0.0
var limite_izquierda := 0.0
var esperando := false
var posicion_inicial := Vector2.ZERO

@onready var timer := $Timer

func _ready():
	limite_derecha = global_position.x + distancia
	limite_izquierda = global_position.x - distancia
	timer.wait_time = tiempo_espera
	timer.one_shot = true
	posicion_inicial = global_position
	# Señal ya conectada en el editor


func _physics_process(delta):
	global_position.y = posicion_inicial.y  # mantiene la plataforma a la misma altura

	var movimiento = Vector2.ZERO

	if esperando:
		movimiento.x = 0
	else:
		movimiento.x = direccion * speed * delta
		
		# Comprobamos los límites
		if direccion == 1 and global_position.x + movimiento.x >= limite_derecha:
			movimiento.x = limite_derecha - global_position.x
			esperando = true
			timer.start()
		elif direccion == -1 and global_position.x + movimiento.x <= limite_izquierda:
			movimiento.x = limite_izquierda - global_position.x
			esperando = true
			timer.start()
	
	# Mover horizontalmente
	global_position.x += movimiento.x


func _on_timer_timeout() -> void:
	direccion *= -1
	esperando = false
