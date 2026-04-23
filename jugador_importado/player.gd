extends CharacterBody3D

const SPEED = 5.0
const SENSITIVITY = 0.003

# Variables para el Head Bobbing (movimiento de cabeza)
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# Nodos actualizados a tu nueva estructura (sin cuello)
@onready var camara = $Camera3D
@onready var linterna = $Camera3D/Linterna
@onready var raycast = $Camera3D/InteractionRay
@onready var texto_ui = $Interfaz/TextoInteraccion

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta):
	texto_ui.text = "" 
	
	if raycast.is_colliding():
		var objeto_mirado = raycast.get_collider()
		# --- CHIVATO: Esto imprimirá en la consola lo que el rayo toca ---
		print("El rayo está tocando a: ", objeto_mirado.name)
		
		if objeto_mirado.has_method("obtener_texto_interaccion"):
			texto_ui.text = objeto_mirado.obtener_texto_interaccion()
	else:
		# Si quieres ver que el rayo está activo aunque no toque nada:
		# print("El rayo no toca nada")
		pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		# Rotamos directamente la cámara hacia arriba y abajo
		camara.rotate_x(-event.relative.y * SENSITIVITY)
		# Ponemos límite para no partirse el cuello mirando atrás
		camara.rotation.x = clamp(camara.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
# Sistema de Interacción
	if Input.is_action_just_pressed("ui_accept"):
		print("¡Tecla pulsada!") # <-- CHIVATO 1
		if raycast.is_colliding():
			var objeto_mirado = raycast.get_collider()
			print("El láser toca a: ", objeto_mirado.name) # <-- CHIVATO 2
			if objeto_mirado.has_method("interactuar"):
				objeto_mirado.interactuar()
			else:
				print("¡Error! El objeto tocado NO tiene el método 'interactuar'")

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Encender / Apagar Linterna
	if Input.is_action_just_pressed("ui_focus_next"):
		linterna.visible = not linterna.visible

	# Movimiento (WASD)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Aplicar el Head Bobbing directamente a la posición de la cámara
	t_bob += delta * velocity.length() * float(is_on_floor())
	camara.transform.origin = _headbob(t_bob)

	move_and_slide()

# Función matemática para simular el paso al caminar
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
