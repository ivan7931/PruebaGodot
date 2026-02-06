extends Area2D

@export var speed := 300.0
var direction := Vector2.ZERO
var impactado := false

@onready var anim: AnimatedSprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	anim.frame = 0
	anim.play("Fly")
	print("🧙‍♂️ Hechizo creado en:", global_position)

func _physics_process(delta):
	if impactado:
		return

	global_position += direction * speed * delta
	print("🧙‍♂️ Hechizo volando:", global_position)

func _on_body_entered(body):
	if impactado:
		return

	print("💥 Impactó con:", body.name)
	impactado = true
	speed = 0
	collision.disabled = true

	if body.is_in_group("player"):
		body.morir()

	anim.play("Hit")

func _on_animated_sprite_2d_animation_finished():
	print("🎬 Animación terminada:", anim.animation)
	if anim.animation == "Hit":
		queue_free()
