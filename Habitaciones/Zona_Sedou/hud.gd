extends CanvasLayer

@onready var label_dinero = $LabelDinero

func _process(_delta):
	label_dinero.text = "Dinero: " + str(Global.monedas)
