extends Area3D

@onready var imagen_monstruo = $UI_Jumpscare/ImagenMonstruo

func _ready():

	body_entered.connect(_on_body_entered)

	imagen_monstruo.visible = false

func _on_body_entered(body):

	print(body.name)

	if body.name == "Player":

		monitoring = false

		imagen_monstruo.visible = true

		print("¡Jumpscare!")

		await get_tree().create_timer(1.5).timeout

		imagen_monstruo.visible = false

		queue_free()
