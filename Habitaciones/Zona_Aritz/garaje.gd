extends Node3D

# Referencias directas a los nodos en la escena actual
@onready var el_video = $CanvasLayer/VideoStreamPlayer # Asegúrate de que la ruta sea correcta
@onready var area_susto = $Area3D # Usaremos tu Area3D existente

func _ready():
	# Nos aseguramos de que el video empiece oculto
	el_video.visible = false
	
	# Conectamos la señal del Area3D que ya tienes
	# (Si ya la conectaste en el paso anterior, esta línea no es necesaria, 
	# pero por seguridad la incluyo para que la conexión sea automática)
	area_susto.body_entered.connect(_on_area_3d_body_entered)
	
	# Conectamos la señal para saber cuándo termina el video
	el_video.finished.connect(_on_video_finished)

# Esta función se activa cuando algo entra en tu Area3D
func _on_area_3d_body_entered(body):
	# Comprobamos si el cuerpo que entra es el Player
	# (Asegúrate de que el nodo de tu jugador se llama "Player")
	if body.name == "Player":
		print("¡Susto activado desde el script principal!")
		
		# Mostramos y reproducimos el video directamente
		el_video.visible = true
		el_video.play()
		
		# Opcional: Desactivamos el Area3D para que no se repita
		area_susto.monitoring = false

# Esta función se activa cuando el video termina
func _on_video_finished():
	el_video.visible = false
