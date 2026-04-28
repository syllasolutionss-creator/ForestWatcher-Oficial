extends RigidBody3D

@export var nombre_item: String = "Café" # <-- AQUÍ PODRÁS ESCRIBIR EL NOMBRE EN EL INSPECTOR

@onready var sonido = $AudioStreamPlayer3D
@onready var modelo_3d = $MeshInstance3D 
@onready var colision = $CollisionShape3D

var en_mano = false

func obtener_texto_interaccion():
	if not en_mano:
		return "[E] Coger " + nombre_item # Ahora usará el nombre que tú le digas
	return ""

func ser_recogido(nodo_mano: Node3D):
	en_mano = true
	
	# Desactivamos físicas
	freeze = true
	colision.disabled = true
	
	# Lo movemos a la mano
	reparent(nodo_mano, false)
	
	# Lo centramos en la mano y arreglamos la escala por si se hizo enano
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	scale = Vector3(1, 1, 1) # Obligamos a que recupere su tamaño normal
	
	print("DEBUG: Objeto en la mano")

func ser_consumido():
	if modelo_3d: modelo_3d.hide()
	
	if sonido and sonido.stream != null:
		sonido.play()
		await sonido.finished
		
	queue_free()
