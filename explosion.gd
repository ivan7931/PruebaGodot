extends Area2D

@export var damage := 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	anim.play("Explosion")
	
	# Espera un frame para que la física se actualice
	await get_tree().physics_frame
	
	# Comprobar cuerpos ya dentro
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			if body.has_method("jugador_siendo_atacado"):
				body.jugador_siendo_atacado()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("jugador_siendo_atacado"):
			body.jugador_siendo_atacado()

func _on_animated_sprite_2d_animation_finished():
	$CollisionShape2D.disabled = true
	$HurtBox/CollisionShape2D.disabled = true
	queue_free()
