extends Area2D

@export var valor :=10

@onready var animated_sprite: AnimatedSprite2D = $animacion_moneda
func _physics_process(delta: float) -> void:
	animated_sprite.play("moneda_animacion")
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("sumar_score"):
		body.sumar_score(valor)
		queue_free()
