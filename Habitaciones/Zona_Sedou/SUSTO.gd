extends Area3D

@export var tiempo_visible: float = 0.5 # Cuánto dura el susto en pantalla

func _on_body_entered(body):
	# Imprime el nombre de lo que entra para que lo veas en la terminal
	print("Algo ha entrado en el área: ", body.name)
	
	# Cambia "Jugador" por el nombre EXACTO de tu nodo de jugador
	# O usa esta línea que es más segura:
	if body is CharacterBody3D: 
		ejecutar_susto()

func ejecutar_susto():
	# 1. Mostrar la cara y sonar el grito
	$Sprite3D.visible = true
	$AudioStreamPlayer3D.play()
	
	print("¡Screamer activado!")
	
	# 2. Esperar un instante (puedes ajustar el tiempo)
	await get_tree().create_timer(tiempo_visible).timeout
	
	# 3. Borrar el susto para que no se repita y no gaste recursos
	queue_free()
