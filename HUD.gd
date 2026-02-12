extends Control

@export var jugador: NodePath  # arrastrar el nodo jugador desde el editor
@onready var player = get_node(jugador)

@onready var corazones = $HBoxContainer.get_children()  # asume que cada hijo es un corazón

func _process(delta):
	actualizar_corazones()

func actualizar_corazones():
	for i in range(corazones.size()):
		if i < player.vida:
			corazones[i].visible = true
		else:
			corazones[i].visible = false
