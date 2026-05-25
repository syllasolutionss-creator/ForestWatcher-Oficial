extends Node3D # Esto evita el error de 'native type'

signal interactuado(nombre_objeto)

@export var nombre_para_mostrar: String = "Contestar Teléfono"

func interactuar():
	print("Interacción detectada en: ", self.name)
	
	# Buscamos los sonidos en cualquier parte de los hijos
	var timbre = find_child("AudioTimbre", true, false)
	var voz = find_child("Voz_telefono_tutorial", true, false)
	
	if timbre:
		timbre.stop()
		print("Timbre detenido")
	else:
		print("ERROR: No encuentro el nodo AudioTimbre")

	if voz:
		voz.play()
		print("Reproduciendo voz del narrador")
	else:
		print("ERROR: No encuentro el nodo Voz_telefono_tutorial")
	
	interactuado.emit(self.name)

func obtener_texto_interaccion():
	return nombre_para_mostrar
