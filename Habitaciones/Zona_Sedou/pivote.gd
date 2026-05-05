extends Node3D

@onready var anim = $AnimationPlayer
var esta_abierta = false

# Esto es lo que el jugador llama al pulsar E
func interactuar():
	if esta_abierta:
		anim.play("cerrar")
		esta_abierta = false
	else:
		anim.play("abrir")
		esta_abierta = true

# Esto es lo que hace que salga el texto "Abrir" / "Cerrar"
func obtener_texto_interaccion() -> String:
	if esta_abierta:
		return "Presiona E para cerrar"
	else:
		return "Presiona E para abrir"
