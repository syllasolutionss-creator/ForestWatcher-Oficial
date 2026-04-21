extends CharacterBody3D

const SPEED = 5.0
const SENSITIVITY = 0.003

# Variables para el Head Bobbing (movimiento de cabeza)
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

@onready var cuello = $Cuello
@onready var camara = $Cuello/Camera3D
@onready var linterna = $Cuello/Camera3D/SpotLight3D
@onready var raycast = $Cuello/Camera3D/RayCast3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		cuello.rotate_x(-event.relative.y * SENSITIVITY)
		cuello.rotation.x = clamp(cuello.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# Sistema de Interacción (Botón 'E' o click)
	if Input.is_action_just_pressed("ui_accept"):
		if raycast.is_colliding():
			var objeto_mirado = raycast.get_collider()
			if objeto_mirado.has_method("interactuar"):
				objeto_mirado.interactuar()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Linterna
	if Input.is_action_just_pressed("ui_focus_next"):
		linterna.visible = not linterna.visible

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Aplicar el Head Bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camara.transform.origin = _headbob(t_bob)

	move_and_slide()

# Función matemática para mover la cámara al caminar
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
