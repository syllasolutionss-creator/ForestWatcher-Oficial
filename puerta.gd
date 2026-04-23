extends StaticBody3D

var abierta = false
var tween : Tween

# Esta función es la que llama el jugador al pulsar 'E'
func interactuar():
	# Si la puerta se está moviendo, no hacemos nada
	if tween and tween.is_running():
		return
		
	# Creamos la animación
	tween = create_tween()
	abierta = not abierta # Cambiamos el estado (si estaba abierta, ahora cerrada y viceversa)
	
	if abierta:
		# Giramos 90 grados
		tween.tween_property(self, "rotation:y", deg_to_rad(90), 0.5)
	else:
		# Volvemos a 0 grados
		tween.tween_property(self, "rotation:y", 0, 0.5)

# Esta función es la que lee el jugador para saber qué texto poner en pantalla
func obtener_texto_interaccion() -> String:
	if abierta:
		return "[E] - Cerrar"
	else:
		return "[E] - Abrir"
