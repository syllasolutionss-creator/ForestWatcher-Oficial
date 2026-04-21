extends StaticBody3D

var precio_apuesta = 10

func interactuar():
	if Global.dinero >= precio_apuesta:
		Global.modificar_dinero(-precio_apuesta)
		apostar()
	else:
		print("No tienes suficiente dinero para jugar...")

func apostar():
	# Generamos un número al azar entre 0 y 100
	var suerte = randi() % 100
	
	if suerte > 60: # 40% de probabilidad de ganar
		var premio = 25
		Global.modificar_dinero(premio)
		print("¡HAS GANADO! +", premio)
		# Aquí podrías activar una luz verde
	else:
		print("Has perdido... El Duende se ríe de ti.")
		# Aquí podrías restar un poco de vida al Vigilante
