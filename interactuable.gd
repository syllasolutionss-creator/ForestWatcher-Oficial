extends Node3D
class_name Interactuable

signal interactuado(nombre_objeto)

@export var nombre_para_mostrar: String = "Objeto"

func interactuar():
	interactuado.emit(self.name)
	print("Has interactuado con: ", self.name)

func obtener_texto_interaccion():
	return nombre_para_mostrar
