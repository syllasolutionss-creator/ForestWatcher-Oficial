extends Area3D

@onready var aviso = $Label3D 
var jugador_cerca = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	aviso.visible = false 

func _on_body_entered(body):
	if body.is_in_group("player"):
		jugador_cerca = true
		aviso.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		jugador_cerca = false
		aviso.visible = false

func _input(event):
	# Si pulsamos la tecla y estamos cerca...
	if event.is_action_pressed("interactuar") and jugador_cerca:
		# ...LLAMAMOS AL CEREBRO (StaticBody3D)
		# "get_parent()" es la máquina. "interactuar()" es la función del cerebro.
		get_parent().interactuar()
