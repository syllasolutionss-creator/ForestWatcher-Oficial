extends Area3D

@onready var aviso = $Label3D # Cambia "Label3D" por el nombre exacto de tu nodo Label
@onready var maquina = get_parent()

# --- ESTA ES LA LÍNEA QUE TE FALTA ---
var jugador_cerca = false 

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	aviso.visible = false

func _process(delta):
	# Ahora el script ya sabe qué es "jugador_cerca"
	if jugador_cerca and not maquina.esta_ocupado:
		aviso.visible = true
	else:
		aviso.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		jugador_cerca = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		jugador_cerca = false
