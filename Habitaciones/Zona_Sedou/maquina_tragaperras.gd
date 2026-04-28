extends StaticBody3D

@onready var anim = $AnimationPlayer
@onready var rodillos = [$Rodillo1, $Rodillo2, $Rodillo3]

const ANCHO_SIMBOLO = 874
const ALTO_SIMBOLO = 688 
var esta_ocupado = false

func interactuar():
	# 1. Comprobaciones de seguridad
	if esta_ocupado: 
		print("La máquina está ocupada")
		return 
	
	if Global.monedas < 10:
		print("No tienes suficiente dinero")
		return

	# 2. Bloqueamos
	esta_ocupado = true
	Global.modificar_dinero(-10)
	
	# 3. Animación de palanca
	anim.play("tirar_palanca")
	
	# 4. Gira los rodillos y ESPERA a que terminen (await es vital aquí)
	var resultados = await girar_rodillos()
	
	# 5. Comprueba si ganaste
	verificar_premios(resultados)
	
	# 6. Desbloqueamos (IMPORTANTE: Esto permite volver a jugar)
	esta_ocupado = false 

func girar_rodillos():
	var resultados_finales = []
	var altura_total = 2752 
	
	for i in range(rodillos.size()):
		var rodillo = rodillos[i]
		# Reseteamos posición antes de girar para evitar acumulación
		rodillo.region_rect.position.y = 0 
		
		var resultado = randi() % 4
		resultados_finales.append(resultado)
		
		var destino_y = resultado * ALTO_SIMBOLO
		var distancia_total = (3 * altura_total) + destino_y
		
		var tween = create_tween()
		var tiempo_giro = 1.5 + (i * 0.4) 
		
		tween.tween_property(rodillo, "region_rect:position:y", float(distancia_total), tiempo_giro).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(3.0).timeout
	return resultados_finales

func verificar_premios(resultados):
	if resultados[0] == resultados[1] and resultados[1] == resultados[2]:
		print("¡PREMIO!")
		Global.modificar_dinero(50)
	else:
		print("Has perdido.")
