extends Area2D

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	col.disabled = true        # No se puede tocar
	sprite.visible = false     # Invisible hasta que se active

func activar():
	sprite.visible = true
	col.disabled = false
	sprite.play("activado")    # Opcional: animación de aparecer


func _on_body_entered(body: Node2D) -> void:
	if body == self:
		get_tree().change_scene("res://NivelSiguiente.tscn")
