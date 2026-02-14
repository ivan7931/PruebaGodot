extends CharacterBody2D


@export var speed := 450.0
@export var gravity := 1000.0
@export var vida := 1
@export var explosion_scene: PackedScene
@export var tiempo_preparacion := 1.5
@export var moneda_scene: PackedScene
@export var probabilidad_moneda := 0.8

var direccion := Vector2.ZERO
var muerto := false
var estado = Estado.IDLE
var player_objetivo = null

enum Estado {
	IDLE,
	PREPARANDO,
	LANZADO,
	MUERTO
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:

	if estado == Estado.LANZADO:
		velocity = direccion * speed
		move_and_slide()
		
		if is_on_wall() or is_on_floor():
			explotar()
	else:
		velocity = Vector2.ZERO

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
	if moneda_scene != null and randf() < probabilidad_moneda:
		var moneda = moneda_scene.instantiate()
		get_parent().add_child(moneda)
		moneda.global_position = global_position
	queue_free()
	
func explotar():
	if estado == Estado.MUERTO:
		return
	
	estado = Estado.MUERTO
	velocity = Vector2.ZERO
	
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	
	queue_free()

func iniciar_preparacion():
	estado = Estado.PREPARANDO
	$AnimatedSprite2D.play("Idle") # sigue en idle mientras espera
	
	await get_tree().create_timer(tiempo_preparacion).timeout
	
	# Si el jugador sigue dentro
	if estado == Estado.PREPARANDO and player_objetivo:
		lanzarse()

func lanzarse():
	$AnimatedSprite2D.play("Lanzarse")
	await $AnimatedSprite2D.animation_finished
	
	# Guardamos dirección en ese momento
	direccion = (player_objetivo.global_position - global_position).normalized()
	
	estado = Estado.LANZADO
	$AnimatedSprite2D.play("Caer")

func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and estado == Estado.IDLE:
		player_objetivo = body
		iniciar_preparacion()



func _on_detector_body_exited(body: Node2D) -> void:
	if body == player_objetivo and estado == Estado.PREPARANDO:
		estado = Estado.IDLE
		$AnimatedSprite2D.play("Idle")
