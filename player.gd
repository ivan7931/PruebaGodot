
extends CharacterBody2D

# =======================
# Configuración
# =======================
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY = 1000.0
@export var DURACION_ATAQUE = 0.4
@export var DURACION_DESLIZAR = 0.6
@export var TIEMPO_RECUPERAR_SALTOS = 2 # cooldown para recuperar saltos extra

# =======================
# Estados
# =======================
var muerto := false
var ataca := false
var deslizando := false
var tiempo_ataque := 0.0
var tiempo_deslizamiento := 0.0
var mirando_derecha := true

var saltos_restantes := 1
var cooldown_saltos := 0.0

# =======================
# Nodos
# =======================
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var col_pie: CollisionShape2D = $dePie
@onready var col_deslizar: CollisionShape2D = $deslizar
@onready var col_atk_der: CollisionShape2D = $atacarDer
@onready var col_atk_izq: CollisionShape2D = $atacarIzq

# =======================
# Ready
# =======================
func _ready():
	col_atk_der.disabled = true
	col_atk_izq.disabled = true
	col_deslizar.disabled = true

# =======================
# Física y controles
# =======================
func _physics_process(delta: float) -> void:
	if muerto:
		velocity = Vector2.ZERO
		return

	# gravedad
	velocity.y += GRAVITY * delta

	# input
	var input_dir = Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
	var horizontal = input_dir.x
	var vertical = input_dir.y

	# mirar dirección
	if horizontal != 0:
		mirando_derecha = horizontal > 0
		animated_sprite.flip_h = not mirando_derecha

	# =======================
	# ATAQUE
	# =======================
	if Input.is_action_just_pressed("Atacar") and not ataca and not deslizando:
		ataca = true
		tiempo_ataque = 0.0
		animated_sprite.play("Atack")

		col_pie.disabled = true
		col_deslizar.disabled = true

		if mirando_derecha:
			col_atk_der.disabled = false
			col_atk_izq.disabled = true
		else:
			col_atk_izq.disabled = false
			col_atk_der.disabled = true

	# =======================
	# DESLIZAR
	# =======================
	if Input.is_action_just_pressed("Abajo") and is_on_floor() and not deslizando and not ataca:
		deslizando = true
		tiempo_deslizamiento = 0.0
		animated_sprite.play("deslizar")

		col_pie.disabled = true
		col_deslizar.disabled = false
		col_atk_der.disabled = true
		col_atk_izq.disabled = true

	# movimiento horizontal
	velocity.x = horizontal * SPEED

	# =======================
	# SALTO
	# =======================
	# Recuperar saltos extra si toca pared
	if (is_on_wall() and not is_on_floor()):
		saltos_restantes = 1
	elif is_on_floor():
		saltos_restantes = 1

	# cooldown para saltos extra
	if cooldown_saltos > 0:
		cooldown_saltos -= delta
		if cooldown_saltos <= 0 and not is_on_wall():
			saltos_restantes = 1

	if Input.is_action_just_pressed("Arriba") and saltos_restantes > 0:
		velocity.y = JUMP_VELOCITY
		saltos_restantes -= 1
		if saltos_restantes == 1:
			cooldown_saltos = TIEMPO_RECUPERAR_SALTOS

	# =======================
	# Animaciones y estados
	# =======================
	if ataca:
		tiempo_ataque += delta
		if tiempo_ataque >= DURACION_ATAQUE:
			ataca = false
			de_pie()
	elif deslizando:
		tiempo_deslizamiento += delta
		if tiempo_deslizamiento >= DURACION_DESLIZAR:
			deslizando = false
			de_pie()
	else:
		if not is_on_floor():
			animated_sprite.play("salto_completo")
		elif horizontal != 0:
			animated_sprite.play("Walk")
		else:
			animated_sprite.play("Idle")

	move_and_slide()

# =======================
# Volver a normal
# =======================
func de_pie():
	col_pie.disabled = false
	col_deslizar.disabled = true
	col_atk_der.disabled = true
	col_atk_izq.disabled = true

	if is_on_floor():
		animated_sprite.play("Idle")

# =======================
# Zona de muerte
# =======================
func _on_espinas_body_entered(body: Node2D) -> void:
	if body != self:
		return
	animated_sprite.play("Die")
	muerto = true
	velocity = Vector2.ZERO
