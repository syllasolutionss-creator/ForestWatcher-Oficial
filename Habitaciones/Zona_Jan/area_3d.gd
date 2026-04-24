extends Area3D

signal interactuado

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("Puedes usar esto")

func interactuar():
	emit_signal("interactuado")
	print("Usando objeto...")
