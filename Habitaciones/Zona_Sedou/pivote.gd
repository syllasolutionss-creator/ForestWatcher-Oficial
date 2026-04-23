extends Node3D

var abierta = false
var tween : Tween

func interactuar():
	print("¡La puerta ha recibido la orden de abrirse!") # <-- CHIVATO 3
	
	if tween and tween.is_running():
		return
	# ... resto de tu código ...
	
	# Creamos la animación suave
	tween = create_tween()
	abierta = !abierta
	
	# Giramos sobre el eje Y
	if abierta:
		# Girar 90 grados hacia un lado
		tween.tween_property(self, "rotation_degrees:y", -90.0, 0.5)
	else:
		# Volver a la posición inicial (0 grados)
		tween.tween_property(self, "rotation_degrees:y", 0.0, 0.5)

func obtener_texto_interaccion() -> String:
	if abierta:
		return "[E] - Cerrar"
	else:
		return "[E] - Abrir"
