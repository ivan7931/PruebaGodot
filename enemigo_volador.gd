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
		return

	if atacando:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var player = get_tree().get_first_node_in_group("Player")

	if player:
		var dir = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed
		anim.flip_h = dir < 0
		anim.play("Walking")
	else:
		velocity.x = 0
		anim.play("Idle")

	move_and_slide()

func _on_attack_timer_timeout():
	print("⏱ Timer disparó")
	if muerto or atacando:
		return

	atacando = true
	anim.play("CastingSpells")
	disparar_hechizo()

func disparar_hechizo():
	print("🔥 DISPARANDO HECHIZO")
	var spell = spell_scene.instantiate()
	print("✨ Hechizo instanciado:", spell)

	spell.global_position = $SpellSpawner.global_position

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		spell.direction = (player.global_position - global_position).normalized()
	else:
		spell.direction = Vector2.LEFT if anim.flip_h else Vector2.RIGHT

	get_tree().current_scene.add_child(spell)
	print("📦 Hechizo añadido a la escena")

func morir():
	if muerto:
		return

	muerto = true
	$AttackTimer.stop()
	velocity = Vector2.ZERO
	anim.play("Die")
	await anim.animation_finished
	queue_free()
	
func _on_hurtbox_area_entered(area):
	if area.is_in_group("PlayerAttack"):
		morir()
		
func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "CastingSpells":
		atacando = false
		
