extends Control
@export var escena_juego : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_reintentar_pressed() -> void:
	get_tree().change_scene_to_packed(escena_juego)
