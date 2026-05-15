extends Area3D

@onready var sonido = $AudioStreamPlayer3D
var jugador_dentro = false

func _ready():
	# Cargar el audio automáticamente
	sonido.stream = load("res://five-nights-at-freddys-full-scream-sound_2.mp3")
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta):
	if jugador_dentro and Input.is_action_just_pressed("interactuar"):
		reproducir_sonido()

func _on_body_entered(body):
	if body.name == "Player":
		jugador_dentro = true

func _on_body_exited(body):
	if body.name == "Player":
		jugador_dentro = false

func reproducir_sonido():
	if not sonido.playing:
		sonido.play()
