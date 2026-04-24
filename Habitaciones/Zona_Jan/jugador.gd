extends CharacterBody3D

@export var velocidad: float = 5.0
@export var gravedad: float = 9.8
@export var distancia_interaccion: float = 6.0

@onready var camara: Camera3D = $Camera3D
var raycast: RayCast3D

func _ready():
	_crear_raycast()

func _physics_process(delta):
	_mover(delta)
	_detectar_objeto()

# ------------------------
# MOVIMIENTO
# ------------------------
func _mover(delta):
	var direccion = Vector3.ZERO

	if Input.is_action_pressed("ui_up"):
		direccion -= transform.basis.z
	if Input.is_action_pressed("ui_down"):
		direccion += transform.basis.z
	if Input.is_action_pressed("ui_left"):
		direccion -= transform.basis.x
	if Input.is_action_pressed("ui_right"):
		direccion += transform.basis.x

	direccion = direccion.normalized()

	velocity.x = direccion.x * velocidad
	velocity.z = direccion.z * velocidad

	# gravedad
	if not is_on_floor():
		velocity.y -= gravedad * delta
	else:
		velocity.y = 0

	move_and_slide()

# ------------------------
# RAYCAST
# ------------------------
func _crear_raycast():
	raycast = RayCast3D.new()
	raycast.target_position = Vector3(0, 0, -distancia_interaccion)
	raycast.enabled = true
	raycast.exclude_parent = true
	
	camara.add_child(raycast)

func _detectar_objeto():
	if raycast.is_colliding():
		var objeto = raycast.get_collider()

		if objeto:
			print("Mirando:", objeto.name)

			if Input.is_action_just_pressed("ui_accept"):
				if objeto.has_method("interactuar"):
					objeto.interactuar()
