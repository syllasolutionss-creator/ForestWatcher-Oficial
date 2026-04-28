extends CharacterBody3D

const SPEED = 5.0
const SENSITIVITY = 0.003

# Variables para el Head Bobbing (movimiento de cabeza)
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# Nodos actualizados
@onready var camara = $Camera3D
@onready var linterna = $Camera3D/Linterna
@onready var raycast = $Camera3D/InteractionRay 
@onready var texto_ui = $Interfaz/TextoInteraccion
@onready var mano = $Camera3D/Mano # <-- El punto donde flotarán los objetos

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Variable para saber qué llevamos agarrado
var objeto_en_mano = null 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta):
	texto_ui.text = "" 
	
	if raycast.is_colliding():
		var objeto_mirado = raycast.get_collider()
		if objeto_mirado.has_method("obtener_texto_interaccion"):
			texto_ui.text = objeto_mirado.obtener_texto_interaccion()

func _unhandled_input(event):
	# Rotación de cámara
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camara.rotate_x(-event.relative.y * SENSITIVITY)
		camara.rotation.x = clamp(camara.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	# Liberar ratón
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# --- SISTEMA DE MANO E INTERACCIÓN ---
	if Input.is_action_just_pressed("interactuar"):
		
		# 1. ¿TENEMOS ALGO EN LA MANO? ¡Nos lo tomamos!
		if objeto_en_mano != null:
			if objeto_en_mano.has_method("ser_consumido"):
				objeto_en_mano.ser_consumido()
				# Soltamos la referencia porque ya nos lo hemos tomado
				objeto_en_mano = null 
				
		# 2. ¿TENEMOS LA MANO VACÍA? Miramos el rayo para coger o comprar
		else:
			if raycast.is_colliding():
				var objeto_mirado = raycast.get_collider()
				
				# Si es una máquina o el altar
				if objeto_mirado.has_method("interactuar"):
					objeto_mirado.interactuar()
					
				# Si es un objeto del suelo para coger (café, cigarro)
				elif objeto_mirado.has_method("ser_recogido"):
					objeto_mirado.ser_recogido(mano) 
					# Guardamos el objeto en la variable para saber que tenemos la mano ocupada
					objeto_en_mano = objeto_mirado 

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

	# Head Bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camara.transform.origin = _headbob(t_bob)

	move_and_slide() 
	
	# --- EMPUJAR OBJETOS FÍSICOS (Patadas) ---
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto_tocado = colision.get_collider()
		
		if objeto_tocado is RigidBody3D:
			var direccion_empuje = -colision.get_normal()
			var fuerza = 2.0 
			objeto_tocado.apply_impulse(direccion_empuje * fuerza, colision.get_position() - objeto_tocado.global_position)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
