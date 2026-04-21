extends StaticBody3D

# Esta es la función que busca el láser de tu jugador al pulsar el botón
func interactuar():
	print("El Duende susurra desde la grieta: '¿Qué quieres, Vigilante?'")
	
	# Comprobamos si el jugador tiene 50 monedas o más en nuestro "Cerebro" (Global)
	if Global.dinero >= 50:
		Global.modificar_dinero(-50) # Le cobramos el dinero
		print("Has comprado una batería. Se escuchan risitas detrás de la pared.")
	else:
		print("El Duende se esconde: '¡No tienes dinero! Vuelve cuando tengas algo que brille...'")
