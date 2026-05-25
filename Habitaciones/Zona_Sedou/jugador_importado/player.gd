extends CharacterBody3D

# --- VARIABLES DE ESTADO Y CONTROL ---
var puedo_moverse: bool = true 

# --- CONFIGURACIÓN DE MOVIMIENTO ---
const SPEED = 5.0
const SENSITIVITY = 0.003
const FOV_NORMAL = 75.0
const FOV_ZOOM = 55.0

# --- VARIABLES DE HEAD BOBBING (EFECTO CAMINAR) ---
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# --- NODOS ---
@onready var camara = $Camera3D
@onready var linterna = $Camera3D/Linterna
@onready var raycast = $Camera3D/InteractionRay 
@onready var texto_ui = $Interfaz/TextoInteraccion
@onready var mano = $Camera3D/Mano 

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var objeto_en_mano = null 

func _ready():
	# Capturamos el ratón para que no se salga de la ventana
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# 1. Lógica de UI (Texto de interacción)
	texto_ui.text = "" 
	if raycast.is_colliding():
		var objeto_mirado = raycast.get_collider()
		# Detectamos si es interactuable
		if objeto_mirado.has_method("obtener_texto_interaccion"):
			texto_ui.text = objeto_mirado.obtener_texto_interaccion()
		elif objeto_mirado.has_method("interactuar") or objeto_mirado.get_parent().has_method("interactuar"):
			texto_ui.text = "[E] Interactuar"

	# 2. Lógica del Zoom
	if puedo_moverse:
		if Input.is_action_just_pressed("zoom"):
			create_tween().tween_property(camara, "fov", FOV_ZOOM, 0.2)
		if Input.is_action_just_released("zoom"):
			create_tween().tween_property(camara, "fov", FOV_NORMAL, 0.2)

func _unhandled_input(event):
	# Bloqueo de rotación si hay diálogo o pausa
	if not puedo_moverse: return

	# Rotación con el ratón
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camara.rotate_x(-event.relative.y * SENSITIVITY)
		camara.rotation.x = clamp(camara.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	# ESC para liberar ratón
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	# --- SISTEMA DE INTERACCIÓN ---
	if Input.is_action_just_pressed("interactuar"):
		if objeto_en_mano != null:
			if objeto_en_mano.has_method("ser_consumido"):
				objeto_en_mano.ser_consumido()
				objeto_en_mano = null 
		else:
			if raycast.is_colliding():
				var objeto_mirado = raycast.get_collider()
				if objeto_mirado.has_method("interactuar"):
					objeto_mirado.interactuar()
				elif objeto_mirado.get_parent().has_method("interactuar"):
					objeto_mirado.get_parent().interactuar()
				elif objeto_mirado.has_method("ser_recogido"):
					objeto_mirado.ser_recogido(mano) 
					objeto_en_mano = objeto_mirado 

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Bloqueo total si el script lo pide (puedo_moverse = false)
	if not puedo_moverse:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		return

	# Control Linterna
	if Input.is_action_just_pressed("ui_focus_next"):
		linterna.visible = not linterna.visible

	# --- MOVIMIENTO "ANTIBALAS" BASADO EN CÁMARA ---
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Usamos la base de la cámara para que W sea "hacia donde miro"
	var look_dir = camara.global_transform.basis
	var forward = -look_dir.z 
	var right = look_dir.x
	
	# Anulamos eje Y para no volar al mirar arriba/abajo
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	# W/S usan 'forward', A/D usan 'right'
	# Si al darle a la W vas hacia atrás, quita el '-' de antes de 'input_dir.y'
	var direction = (forward * -input_dir.y + right * input_dir.x).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Balanceo (Headbob)
	if is_on_floor() and direction != Vector3.ZERO:
		t_bob += delta * velocity.length()
		camara.transform.origin = _headbob(t_bob)
	else:
		camara.transform.origin = camara.transform.origin.lerp(Vector3.ZERO, delta * 5)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
