extends Area3D

@onready var video_susto = $UI_Jumpscare/VideoSusto

func _ready():

	body_entered.connect(_on_body_entered)

	video_susto.visible = false

func _on_body_entered(body):

	print(body.name)

	if body.name == "Player":

		monitoring = false

		video_susto.visible = true

		print("¡Jumpscare!")

		await get_tree().create_timer(1.5).timeout

		video_susto.visible = false

		queue_free()
