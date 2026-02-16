extends Control

@export var escena_juego : PackedScene

func _ready():
	$VBoxContainer/Button.grab_focus()


func _on_ButtonSalir_pressed():
	get_tree().quit()

func _on_ButtonPlay_pressed() -> void:
	get_tree().change_scene_to_packed(escena_juego)
