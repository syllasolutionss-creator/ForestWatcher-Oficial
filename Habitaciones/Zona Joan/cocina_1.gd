extends Node3D

# Referencia a tu CanvasLayer o TextureRect
@onready var ui_jumpscare = $UI_Jumpscare  # Cambia esta ruta por la tuya exacta

func _ready():
	# PASO FUNDAMENTAL: Forzamos que el jumpscare esté oculto al arrancar
	ui_jumpscare.visible = false
	
	# Asegúrate de conectar tu señal aquí si no lo hiciste en el editor
	$ZonaSusto.body_entered.connect(_on_zona_susto_body_entered)

func _on_zona_susto_body_entered(body):
	# Condición de seguridad para que solo el jugador (body) lo active
	if body.name == "Player":
		ui_jumpscare.visible = true  # Muestra el susto
		queue_free() # Borra la zona para que no se repita
