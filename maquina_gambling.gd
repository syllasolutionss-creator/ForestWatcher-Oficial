extends StaticBody3D

# Configuración de la máquina
var precio_partida = 10
var premio = 50

func interactuar():
	# 1. Comprobar si el jugador tiene suficiente dinero
	if Global.monedas >= precio_partida:
		# Cobrar el precio de la partida
		Global.monedas -= precio_partida
		print("Has pagado 10 monedas. Girando...")
		
		# Ejecutar el juego
		jugar_tragaperras()
	else:
		# Si no tiene dinero, no dejamos jugar
		print("No tienes suficientes monedas. ¡Necesitas 10!")

func jugar_tragaperras():
	# 2. Generar números aleatorios (0, 1 o 2)
	var rodillo1 = randi() % 3
	var rodillo2 = randi() % 3
	var rodillo3 = randi() % 3
	
	print("Resultado: ", rodillo1, " - ", rodillo2, " - ", rodillo3)
	
	# 3. Comprobar si hay premio (si los 3 números son iguales)
	if rodillo1 == rodillo2 and rodillo2 == rodillo3:
		Global.monedas += premio
		print("¡JACKPOT! Has ganado ", premio, " monedas.")
	else:
		print("Mala suerte, has perdido las 10 monedas.")

# Esta función es la que llama tu script del jugador
func obtener_texto_interaccion() -> String:
	return "[E] - Jugar tragaperras (Cuesta 10)"
