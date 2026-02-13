extends Control

@export var jugador: NodePath  # arrastrar el nodo jugador desde el editor
@export var corazon_scene: PackedScene



@onready var player = get_node(jugador)
@onready var contenedor_corazones = $HBoxContainer
#========================
#SISTEMA MONEDAS
#========================
@onready var score_label = $ScoreLabel

var vidas_mostradas := 0

#@onready var corazones = $HBoxContainer.get_children()  # asume que cada hijo es un corazón

func _process(delta):
	actualizar_corazones()
	score_label.text = "Score : "+ str(player.score)

func actualizar_corazones():
	while vidas_mostradas < player.vida:
		var nuevo_corazon = corazon_scene.instantiate()
		contenedor_corazones.add_child(nuevo_corazon)
		vidas_mostradas += 1
	while vidas_mostradas > player.vida:
		contenedor_corazones.get_child(vidas_mostradas - 1).queue_free()
		vidas_mostradas -= 1
	#for i in range(corazones.size()):
		#if i < player.vida:
			#corazones[i].visible = true
		#else:
			#corazones[i].visible = false
