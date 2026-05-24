extends Control

func _ready():
	visible = false
	$VideoStreamPlayer.finished.connect(_on_finished)

func iniciar():
	visible = true
	$VideoStreamPlayer.play()

func _on_finished():
	visible = false
	# No ponemos queue_free() aquí para poder probarlo varias veces si quieres
