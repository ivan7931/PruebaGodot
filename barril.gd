extends StaticBody2D

@export var vida := 4

func destruir():
	vida -= 1
	if vida <= 0:
		queue_free()
