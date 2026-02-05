extends StaticBody2D

@export var vida := 3

func destruir():
	vida -= 1
	if vida <= 0:
		queue_free()
