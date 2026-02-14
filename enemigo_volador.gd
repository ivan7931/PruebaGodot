extends CharacterBody2D

@export var speed := 120.0
@export var vida := 2
@export var spell_scene: PackedScene
@export var moneda_scene: PackedScene
@export var probabilidad_moneda := 0.8	

var persiguiendo := false
var player_obj : Node2D = null
var estado := "idle"
var muerto := false
var atacando := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	print("🎞 Animación inicial")

func _physics_process(delta: float) -> void:
	if muerto:#prueba1:
		atacando = false
		return

	if atacando:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if persiguiendo and player_obj:
		var direction = (player_obj.global_position - global_position).normalized()
		velocity = direction * speed
		
		anim.flip_h = direction.x < 0
		anim.play("Walking")
	else:
		velocity = Vector2.ZERO
		anim.play("Idle")

	move_and_slide()

func _on_attack_timer_timeout():
	if muerto or atacando or not persiguiendo:
		return

	atacando = true
	anim.play("CastingSpells")
	disparar_hechizo()

func disparar_hechizo():
	var spell = spell_scene.instantiate()

	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		# Dirección real hacia el player
		spell.direction = (player.global_position - global_position).normalized()
		
		# Elegimos el spawner del lado correcto
		if player.global_position.x < global_position.x:
			spell.global_position = $SpellSpawnerIzq.global_position
		else:
			spell.global_position = $SpellSpawnerDerecha.global_position
	else:
		# Si no hay player
		if anim.flip_h:
			spell.direction = Vector2.LEFT
			spell.global_position = $SpellSpawnerIzq.global_position
		else:
			spell.direction = Vector2.RIGHT
			spell.global_position = $SpellSpawnerDerecha.global_position
	

	get_tree().current_scene.add_child(spell)

func morir():
	if muerto:
		return

	muerto = true
	$CollisionShape2D.disabled = true
	$HurtBox/CollisionShape2D.disabled = true
	$AttackTimer.stop()
	velocity = Vector2.ZERO
	anim.play("Die")
	await anim.animation_finished
	#Posibilidad de soltar moneda
	if moneda_scene != null and randf() < probabilidad_moneda:
		var moneda = moneda_scene.instantiate()
		get_parent().add_child(moneda)
		moneda.global_position = global_position   # Aparece en la posición del enemigo
	queue_free()
	
func siendo_atacado():
	vida -=1
	if vida <=0:
		morir()
		
func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "CastingSpells":
		atacando = false
		


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.jugador_siendo_atacado()


func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		persiguiendo = true
		player_obj = body


func _on_detector_body_exited(body: Node2D) -> void:
	if body == player_obj:
		persiguiendo = false
		player_obj = null
		atacando = false
