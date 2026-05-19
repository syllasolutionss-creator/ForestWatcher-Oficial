extends Control

func _ready():
	# Configuramos los botones para que sigan siendo bonitos
	for boton in $CanvasLayer/VBoxContainer.get_children():
		if boton is Button:
			boton.mouse_entered.connect(_on_mouse_entered.bind(boton))
			boton.mouse_exited.connect(_on_mouse_exited.bind(boton))
			boton.pressed.connect(_on_boton_pressed.bind(boton.name))
			boton.pivot_offset = boton.size / 2

func _on_boton_pressed(nombre_boton):
	if nombre_boton == "BotonJugar":
		# Cambio directo sin esperas ni fundidos
		get_tree().change_scene_to_file("res://node_3d.tscn")
	elif nombre_boton == "BotonSalir":
		get_tree().quit()

func _on_mouse_entered(boton):
	var tween = create_tween()
	tween.tween_property(boton, "scale", Vector2(1.1, 1.1), 0.1)
	boton.add_theme_color_override("font_color", Color.YELLOW)

func _on_mouse_exited(boton):
	var tween = create_tween()
	tween.tween_property(boton, "scale", Vector2(1.0, 1.0), 0.1)
	boton.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
