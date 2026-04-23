extends Node

var monedas : int = 100

func modificar_dinero(cantidad: int):
	monedas += cantidad
	print("Dinero actual: ", monedas)
