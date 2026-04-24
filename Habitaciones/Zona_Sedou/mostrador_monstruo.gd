extends StaticBody3D

# Referencia al letrero que creaste (asegúrate de que el nombre coincida)
@onready var aviso = $Label3D 

func _ready():
	# Nos aseguramos de que empiece oculto al iniciar el juego
	aviso.visible = false

# Esto se activa cuando el jugador entra en el Area3D
func _on_zona_interaccion_body_entered(body):
	if body.is_in_group("Player"):
		aviso.visible = true

# Esto se activa cuando el jugador sale del Area3D
func _on_zona_interaccion_body_exited(body):
	if body.is_in_group("Player"):
		aviso.visible = false
