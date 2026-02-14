extends Area2D

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	col.disabled = true        # No se puede tocar
	sprite.visible = false     # Invisible hasta que se active

func activar():
	sprite.visible = true
	col.disabled = false

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	if bodies.size() > 0:
		print("Detectando:", bodies)

func _on_body_entered(body: Node2D) -> void:
	print("Final")
	if body.is_in_group("player"):
		print("Final")
		get_tree().change_scene("res://Final.tscn")
