extends CharacterBody2D


@export var speed := 250.0
@export var gravity := 1000.0
@export var vida := 1
@export var explosion_scene: PackedScene

var direccion := Vector2.ZERO
var muerto := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:

	if muerto:
		return

	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	var player = get_tree().get_first_node_in_group("player")

	if player:
		direccion = (player.global_position - global_position).normalized()
		velocity.x = direccion.x * speed

		anim.flip_h = direccion.x < 0
		anim.play("Run")

	move_and_slide()

	if is_on_wall() or is_on_floor():
		explotar()

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("💥 Se estrelló contra el jugador")
		explotar()
		if body.has_method("jugador_siendo_atacado"):
			body.jugador_siendo_atacado()

		morir()
		
func morir():
	if muerto:
		return

	muerto = true
	velocity = Vector2.ZERO
	anim.play("Die")

	await anim.animation_finished
	queue_free()
	
func explotar():
	if muerto:
		return

	muerto = true
	velocity = Vector2.ZERO
	anim.play("Die")

	# Crear explosión
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)

	queue_free()
