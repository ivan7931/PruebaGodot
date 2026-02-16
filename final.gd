extends Control

@onready var score_label = $ScoreLabel
@export var escena_juego : PackedScene

func _ready():
	score_label.text = "Puntuación :    " + str(Global.score) + "   pts"


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_packed(escena_juego)
