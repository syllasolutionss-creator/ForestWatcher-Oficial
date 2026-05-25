extends Area3D

@export var monstruo_sprite: Sprite3D # Asegúrate de que el Sprite esté arrastrado aquí en el Inspector

func _on_body_entered(body):
	# Si lo que entra es el jugador (CharacterBody3D)
	if body is CharacterBody3D:
		iniciar_susto()

func iniciar_susto():
	print("¡Susto iniciado!")
	
	# 1. Mostrar monstruo
	monstruo_sprite.visible = true
	
	# 2. Intentar reproducir sonido (Buscamos cualquier nodo de audio hijo del sprite)
	# Si tu nodo de audio se llama distinto, cámbialo aquí:
	if monstruo_sprite.has_node("AudioStreamPlayer3D"):
		monstruo_sprite.get_node("AudioStreamPlayer3D").play()
		print("Sonido activado")
	elif monstruo_sprite.has_node("AudioStreamPlayer"):
		monstruo_sprite.get_node("AudioStreamPlayer").play()
		print("Sonido 2D activado")

	# 3. Lanzar animación
	var anim = monstruo_sprite.get_node("AnimationPlayer")
	anim.play("ataque_monstruo")
	
	# 4. Esperar a que termine la animación
	await anim.animation_finished
	
	# 5. Limpieza total
	monstruo_sprite.queue_free()
	queue_free()

# BORRA CUALQUIER OTRA FUNCIÓN QUE DIGA "_on_area_3d_body_entered" ABAJO
