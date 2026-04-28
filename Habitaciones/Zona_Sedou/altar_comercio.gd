extends StaticBody3D

@export var precio: int = 10
@export var aviso: Label3D
@export var detector: Area3D
@export var spawn_point: Marker3D
@export var items_posibles: Array[PackedScene]

var jugador_cerca = false

func _ready():
	if aviso: aviso.hide()
	
	if detector:
		detector.body_entered.connect(_on_detector_body_entered)
		detector.body_exited.connect(_on_detector_body_exited)

func _on_detector_body_entered(body):
	if body.is_in_group("player"):
		jugador_cerca = true
		if aviso: aviso.show()

func _on_detector_body_exited(body):
	if body.is_in_group("player"):
		jugador_cerca = false
		if aviso: aviso.hide()

func _input(event):
	if jugador_cerca and event.is_action_pressed("interactuar"):
		# ESTA ES LA LÍNEA MÁGICA: "Se come" el input para que no rebote y se ejecute 2 veces
		get_viewport().set_input_as_handled() 
		interactuar()

func interactuar():
	if items_posibles.size() == 0:
		print("DEBUG: No hay objetos en el array")
		return

	# Comprobamos el dinero una sola vez aquí
	if Global.monedas >= precio:
		Global.modificar_dinero(-precio) 
		print("DEBUG: Dinero descontado. Restante: ", Global.monedas)

		# Instanciar objeto
		var objeto = items_posibles.pick_random().instantiate()
		get_tree().current_scene.add_child(objeto)
		
		# Posición y escala
		objeto.global_position = spawn_point.global_position
		objeto.scale = Vector3(0.3, 0.3, 0.3)
		
		# FÍSICA
		if objeto is RigidBody3D:
			var direccion = global_transform.basis.z + Vector3(0, 0.6, 0)
			objeto.apply_central_impulse(direccion.normalized() * 7.0)
			print("DEBUG: Objeto lanzado")
	else:
		print("DEBUG: No tienes suficientes monedas")
