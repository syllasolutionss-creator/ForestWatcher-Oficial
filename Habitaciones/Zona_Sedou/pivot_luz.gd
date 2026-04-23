extends Node3D

@onready var luz = $OmniLight3D # Esto busca la luz que está debajo de este nodo
var tiempo = 0.0

func _process(delta):
	tiempo += delta
	
	# 1. Movimiento de balanceo (Péndulo)
	rotation_degrees.z = sin(tiempo * 1.5) * 15 
	
	# 2. Parpadeo (Picos de luz)
	var base_energia = 1.0
	var aleatorio = randf_range(-0.5, 0.5) 
	
	if randf() > 0.95: 
		luz.light_energy = base_energia * 3.0 
	else:
		luz.light_energy = base_energia + aleatorio
