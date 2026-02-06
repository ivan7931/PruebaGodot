extends CharacterBody2D

# =======================
# Configuración
# =======================
@export var SPEED := 300.0
@export var JUMP_VELOCITY := -400.0
@export var GRAVITY := 1000.0
@export var DURACION_ATAQUE := 0.4
@export var DURACION_DESLIZAR := 0.7
@export var TIEMPO_RECUPERAR_SALTOS := 2.0

# Fuerza extra sobre rampas
@export var FUERZA_RAMPA := 1200.0
@export var FRICCION_RAMPA :=0.85
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

@onready var ataque_der: Area2D = $atacarDer
@onready var ataque_izq: Area2D = $atacarIzq


# =======================
# Ready
# =======================
func _ready():
	ataque_der.monitoring = false
	ataque_izq.monitoring = false
	col_deslizar.disabled = true
	

# =======================
# Física
# =======================
func _physics_process(delta: float) -> void:
	if muerto:
		velocity.y += GRAVITY * delta
		velocity.x = 0
		move_and_slide()
		return

	# Gravedad
	velocity.y += GRAVITY * delta

	# Input
	var input_dir := Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")
	var horizontal := input_dir.x

	# Dirección
	if horizontal != 0:
		mirando_derecha = horizontal > 0
		animated_sprite.flip_h = not mirando_derecha

	# Movimiento horizontal
	velocity.x = horizontal * SPEED

	# =======================
	# Recuperar saltos (suelo + wall jump)
	# =======================
	if is_on_wall() and not is_on_floor():
		saltos_restantes = 1
	elif is_on_floor():
		saltos_restantes = 1

	# cooldown saltos extra
	if cooldown_saltos > 0:
		cooldown_saltos -= delta

	# SALTO
	if Input.is_action_just_pressed("Arriba") and saltos_restantes > 0:
		velocity.y = JUMP_VELOCITY
		saltos_restantes -= 1
		cooldown_saltos = TIEMPO_RECUPERAR_SALTOS

	# =======================
	# ATAQUE
	# =======================
	if Input.is_action_just_pressed("Atacar") and not ataca and not deslizando:
		iniciar_ataque()

	# =======================
	# DESLIZAR
	# =======================
	if Input.is_action_just_pressed("Abajo") and is_on_floor() and not deslizando and not ataca:
		iniciar_deslizamiento()

	# =======================
	# Estados y animaciones
	# =======================
	if ataca:
		tiempo_ataque += delta
		if tiempo_ataque >= DURACION_ATAQUE:
			terminar_ataque()

	elif deslizando:
		tiempo_deslizamiento += delta
		if tiempo_deslizamiento >= DURACION_DESLIZAR:
			terminar_deslizamiento()

	else:
		if not is_on_floor():
			animated_sprite.play("salto_completo")
		elif horizontal != 0:
			animated_sprite.play("Walk")
		else:
			animated_sprite.play("Idle")
	# -----------------------
	# Deslizamiento sobre rampas físicas
	# -----------------------
	if is_on_floor():
		var pendiente_x = get_floor_normal().x # positiva → baja a la derecha, negativa → cuesta subir
		#descendiendo
		if pendiente_x > 0:
			velocity.x += pendiente_x * FUERZA_RAMPA * delta
		#subiendo
		else:
			velocity.x += pendiente_x * (FUERZA_RAMPA * 10) * delta
		
		 # Animación opcional al deslizar por pendiente
		if not deslizando and horizontal ==0 and abs(pendiente_x) > 0.1:
			animated_sprite.play("correr")
	# -----------------------
	# Aplicar movimiento
	# -----------------------
	move_and_slide()
	


# =======================
# ATAQUE
# =======================
func iniciar_ataque():
	ataca = true
	tiempo_ataque = 0.0
	# Animación según si se mueve o no
	if velocity.x != 0:  # Si está en movimiento
		animated_sprite.play("ataque_mov")
	else:               # Si está quieto
		animated_sprite.play("Atack")

	if mirando_derecha:
		ataque_der.monitoring = true
		ataque_izq.monitoring = false
	else:
		ataque_der.monitoring = false
		ataque_izq.monitoring = true

func terminar_ataque():
	ataca = false
	ataque_der.monitoring = false
	ataque_izq.monitoring = false
	col_pie.disabled = false

# =======================
# DESLIZAR
# =======================
func iniciar_deslizamiento():
	deslizando = true
	tiempo_deslizamiento = 0.0
	animated_sprite.play("deslizar")

	col_pie.disabled = true
	col_deslizar.disabled = false
	ataque_der.monitoring = false
	ataque_izq.monitoring = false

func terminar_deslizamiento():
	deslizando = false
	col_pie.disabled = false
	col_deslizar.disabled = true

# =======================
# MUERTE
# =======================
func _on_espinas_body_entered(body: Node2D) -> void:
	if body != self:
		return
	muerto = true
	velocity = Vector2.ZERO
	animated_sprite.play("Die")

func morir():
	muerto = true
	velocity = Vector2.ZERO
	animated_sprite.play("Die")

func _on_atacar_der_body_entered(body: Node2D) -> void:
	print("Golpeó a:", body.name)
	if body.has_method("destruir"):
		body.destruir()
	elif body.is_in_group("Enemigo"):
		body.morir()


func _on_atacar_izq_body_entered(body: Node2D) -> void:
	print("Golpeó a:", body.name)
	if body.has_method("destruir"):
		body.destruir()
	elif body.is_in_group("Enemigo"):
		body.morir()
		
# =======================
# DETECTAR SUELO (TRAMPAS + RAMPAS)
# =======================
func _on_detectar_suelo_area_entered(area: Area2D) -> void:
	if area.has_method("desaparecer"):
		area.desaparecer()
