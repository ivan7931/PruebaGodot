extends Area2D

@export var damage := 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	anim.play("Explosion")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("jugador_siendo_atacado"):
			body.jugador_siendo_atacado()

func _on_animated_sprite_2d_animation_finished():
	queue_free()
