extends CharacterBody2D

@export var speed := 80.0
@export var life := 3
@export var spell_scene: PackedScene	

var estado := "idle"
var muerto := false
var atacando := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	print("🎞 Animación inicial")

func _physics_process(delta: float) -> void:
	if muerto:
		atacando = false
		return

	if atacando:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var player = get_tree().get_first_node_in_group("player")

	if player:
		var dir = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed
		dir = sign(player.global_position.y - global_position.y)
		velocity.y = dir * speed
		anim.flip_h = dir < 0
		anim.play("Walking")
	else:
		velocity.x = 0
		anim.play("Idle")

	move_and_slide()

func _on_attack_timer_timeout():
	if muerto or atacando:
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
	$AttackTimer.stop()
	velocity = Vector2.ZERO
	anim.play("Die")
	await anim.animation_finished
	queue_free()
	

		
func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "CastingSpells":
		atacando = false
		


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.morir()
