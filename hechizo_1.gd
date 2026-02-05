extends Area2D

@export var lifetime := 3.0
@export var speed := 300.0
var direction := Vector2.ZERO
var impactado := false

@onready var anim: AnimatedSprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	print("✨ Hechizo creado")
	anim.play("Walking")
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	if impactado:
		return
	global_position += direction * speed * delta

func _on_body_entered(body):
	print("💥 Impactó con:", body.name)
	if impactado:
		return

	impactado = true
	collision.disabled = true

	if body.is_in_group("Player"):
		body.morir() # o recibir_daño()

	anim.play("Hit")

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "Hit":
		queue_free()
