extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready():    # No se puede tocar
	sprite.visible = false     # Invisible hasta que se active
	monitoring = false

func activar():
	print("Activando diamante")
	sprite.visible = true
	monitoring = true

func _on_body_entered(body: Node2D) -> void:
	print("Contacto con:", body.name)
	if body.is_in_group("player"):
		print("Final")
		Global.score = body.score
		
		get_tree().change_scene_to_file("res://Final.tscn")
