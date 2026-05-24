extends Node3D

# =====================================================================
# CONEXIONES DEL INSPECTOR
# =====================================================================
@export var jugador: CharacterBody3D
@export var camara: Camera3D
@export var luz_cabina: SpotLight3D
@export var raycast_radio: RayCast3D
@export var voz_arthur_player: AudioStreamPlayer
@export var audio_timbre_telefono: AudioStreamPlayer3D # Asignar en el inspector
@export var audio_voz_telefono: AudioStreamPlayer3D # Asignar en el inspector
@export var ui_cartel_zoom: TextureRect # Asignar el nodo UI_Cartel_Zoom
@export var ui_fundido_negro: ColorRect # Crea un ColorRect negro que cubra todo y asígnalo
@export var label_dia: Label # Crea un Label que diga 'DÍA 1' y asígnalo

var telefono_contestado: bool = false
var inspeccionando_cartel: bool = false
var dia_actual: int = 0
# =====================================================================
# VARIABLES DE INTERFAZ (UI) - TODAS DECLARADAS
# =====================================================================
var hud_dialogo: RichTextLabel
var panel_dialogo: PanelContainer
var hud_mirilla: ColorRect
var hud_shader: ColorRect
var contenedor_opciones: HBoxContainer
var contenedor_botones: GridContainer  # DECLARADO para compatibilidad
var contenedor_preguntas: HBoxContainer  # Horizontal para las dos opciones
var label_ayuda: Label
var label_salida: Label
var contenedor_rayos: HBoxContainer
var iconos_rayo: Array[TextureRect] = []
var panel_ficha: ColorRect
var hud_ficha: TextureRect

# =====================================================================
# TEXTOS DEL EVENTO DE ARTHUR
# =====================================================================
const TEXTO_PRIMERA_LINEA: String = "ARTHUR: ¿Hola? ¿Hay alguien ahí? Por Dios, responde... He visto la luz de tu cabaña desde el bosque. No salgas, hay algo moviéndose entre los árboles... algo que no debería estar aquí. Dime que me escuchas."
const OPCION_A: String = "Te escucho. Mantén la calma, ¿qué está pasando?"
const OPCION_B: String = "¿Quién eres? Aléjate de mi propiedad."
const RESPUESTA_A: String = "[color=yellow]ARTHUR:[/color] Gracias a Dios... No sé qué es eso, pero se está acercando. ¡Cierra las puertas y ventanas! ¡No salgas bajo ninguna circunstancia!"
const RESPUESTA_B: String = "[color=yellow]ARTHUR:[/color] ¡Soy Arthur! Arthur Pendelton, tu vecino. Por favor, necesito ayuda. Algo viene... algo que no debería estar aquí..."
const TEXTO_TUTORIAL: String = "Atención, guarda forestal. El generador principal ha entrado en modo de emergencia. Solo dispone de cuatro cargas del flash. Úselas únicamente para repeler a los intrusos. Si la energía se agota, reinicie la caja de fusibles. Y sobre todo... no deje que entren. Fin del mensaje."

# =====================================================================
# SINCRONIZACIÓN TEXTO-AUDIO
# =====================================================================
var duracion_audio_arthur: float = 30.0
var duracion_audio_telefono: float = 0.0
var tutorial_telefono_en_curso: bool = false
var texto_actual_arthur: String = ""
var progreso_texto_arthur: float = 0.0
var velocidad_texto_arthur: float = 0.0
var texto_arthur_completado: bool = false
var decision_elegida: bool = false
var opciones_mostradas: bool = false  # CANDADO: evita recrear botones 60 veces/seg

# =====================================================================
# PATHS DE ARCHIVOS
# =====================================================================
const PATH_FICHA_ARTHUR := "res://ficha_arthur.png"
const PATH_ICONO_RAYO := "res://assets/icono_rayo.png"
const PATH_RADIO_ESTATICA := "res://assets/radio_estatica.mp3"
const PATH_AMBIENTE_FONDO := "res://assets/ambiente_fondo.mp3"
const PATH_VOZ_ARTHUR := "res://Audio/Voces/voz_arthur_1.mp3"
const PATH_VOZ_ARTHUR_A := "res://Audio/Voces/voz_arthur_2a.mp3"
const PATH_VOZ_ARTHUR_B := "res://Audio/Voces/voz_arthur_2b.mp3"
const PATH_VOZ_TELEFONO := "res://Audio/Voces/voz_telefono_tutorial.mp3"

# =====================================================================
# VARIABLES DE RECURSOS
# =====================================================================
var textura_ficha_normal: Texture2D

# =====================================================================
# AUDIO
# =====================================================================
var audio_radio: AudioStreamPlayer
var audio_voz_arthur: AudioStreamPlayer
var musica_fondo: AudioStreamPlayer

# =====================================================================
# ESTADO DE RADIO
# =====================================================================
var radio_encendida: bool = false
var arthur_ha_aparecido: bool = false
var timer_arthur_aparicion: Timer
var _radio_volumen_estatica_activa_db: float = 0.0
@export var segundos_hasta_voz_arthur: float = 15.0
@export var radio_volumen_estatica_db: float = -2.0

# =====================================================================
# MÚSICA AMBIENTAL
# =====================================================================
@export var musica_fondo_volumen_base_db: float = -15.0
@export var musica_fondo_volumen_reducido_db: float = -24.0
@export var musica_fondo_fade_speed: float = 2.5
var musica_fondo_objetivo_db: float = -15.0

# =====================================================================
# RAYOS (ENERGÍA)
# =====================================================================
var rayos_maximos: int = 4
var rayos_restantes: int = 4

# =====================================================================
# ACECHADOR (OJOS ROJOS)
# =====================================================================
@export var acechador_interval_min: float = 1.8
@export var acechador_interval_max: float = 4.5
@export var acechador_visible_min: float = 0.15
@export var acechador_visible_max: float = 0.5
@export var acechador_pos_x_min: float = -10.0
@export var acechador_pos_x_max: float = 10.0
@export var acechador_pos_z_min: float = -35.0
@export var acechador_pos_z_max: float = -8.0
@export var acechador_energy_min: float = 18.0
@export var acechador_energy_max: float = 42.0

var acechador_next_in: float = 0.0
var acechador_visible_left: float = 0.0
var ojos_acechador: OmniLight3D

# =====================================================================
# LUZ CABINA
# =====================================================================
var energia_luz_max: float = 18.0
var tiempo_ruido: float = 0.0
var energia: float = 100.0

# =====================================================================
# ESTADOS DEL JUEGO
# =====================================================================
const ESTADO_EXPLORANDO := "EXPLORANDO"
const ESTADO_INTERACTUANDO := "INTERACTUANDO"
var estado_actual: String = ESTADO_EXPLORANDO:
	set(value):
		estado_actual = value
		if is_instance_valid(jugador):
			jugador.puedo_moverse = (estado_actual == ESTADO_EXPLORANDO)
var modo_interaccion: bool = false

# =====================================================================
# TEXTO TIPO MÁQUINA DE ESCRIBIR
# =====================================================================
var texto_destino: String = ""
var caracteres_mostrados: float = 0.0
var velocidad_texto: float = 25.0

# =====================================================================
# RATÓN Y CÁMARA
# =====================================================================
var sensibilidad_mouse: float = 0.003
var rotacion_x: float = 0.0
@export var auto_enfoque_duracion: float = 0.3
var auto_enfoque_activo: bool = false
var auto_enfoque_tiempo: float = 0.0
var auto_enfoque_yaw_inicio: float = 0.0
var auto_enfoque_yaw_objetivo: float = 0.0
var auto_enfoque_pitch_inicio: float = 0.0
var auto_enfoque_pitch_objetivo: float = 0.0
var camara_guardada_yaw: float = 0.0
var camara_guardada_pitch: float = 0.0

var fov_normal: float = 75.0
var fov_zoom: float = 35.0

# =====================================================================
# MOVIMIENTO DEL JUGADOR
# =====================================================================
@export var velocidad_horizontal: float = 4.0
@export var aceleracion_horizontal: float = 14.0
@export var frenado_horizontal: float = 18.0
@export var gravedad: float = 20.0

# =====================================================================
# UI FADE
# =====================================================================
@export var ayuda_fade_speed: float = 8.0
@export var ayuda_max_alpha: float = 0.12
var ayuda_alpha: float = 0.0

# =====================================================================
# _READY - INICIALIZACIÓN
# =====================================================================
func _ready() -> void:
	print("=== INICIALIZANDO SISTEMA DE RADIO ===")
	
	_cargar_recursos()
	_crear_ui()
	_configurar_audio_radio()
	_configurar_audio_arthur()
	_configurar_timer_arthur()
	_configurar_musica_fondo()
	_crear_acechador()
	_ejecutar_cinematica_segura()
	
	_conectar_interactuables()
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if is_instance_valid(panel_dialogo):
		panel_dialogo.hide()
	if is_instance_valid(panel_ficha):
		panel_ficha.hide()
	if is_instance_valid(contenedor_preguntas):
		contenedor_preguntas.hide()
	
	acechador_next_in = randf_range(acechador_interval_min, acechador_interval_max)
	acechador_visible_left = 0.0
	rayos_restantes = rayos_maximos
	_actualizar_iconos_rayo()
	
	print("Sistema inicializado correctamente")

# =====================================================================
# _PROCESS - ACTUALIZACIÓN POR FRAME
# =====================================================================
func _process(delta: float) -> void:
	
	# Texto escribiéndose (diálogos generales)
	if hud_dialogo and texto_destino != "" and caracteres_mostrados < texto_destino.length():
		caracteres_mostrados += velocidad_texto * delta
		hud_dialogo.visible_characters = int(caracteres_mostrados)
	
	# Sincronización texto-audio de Arthur
	if estado_actual == ESTADO_INTERACTUANDO and arthur_ha_aparecido and not texto_arthur_completado:
		if hud_dialogo and texto_actual_arthur != "":
			if is_instance_valid(audio_voz_arthur) and audio_voz_arthur.playing:
				var tiempo_audio: float = audio_voz_arthur.get_playback_position()
				if duracion_audio_arthur > 0.0:
					var progreso: float = tiempo_audio / duracion_audio_arthur
					var chars: int = int(progreso * texto_actual_arthur.length())
					
					if chars >= texto_actual_arthur.length():
						hud_dialogo.visible_characters = texto_actual_arthur.length()
						texto_arthur_completado = true
					else:
						hud_dialogo.visible_characters = chars
	
	# Sincronización texto-audio del Teléfono
	if estado_actual == ESTADO_INTERACTUANDO and tutorial_telefono_en_curso:
		if hud_dialogo and TEXTO_TUTORIAL != "":
			if is_instance_valid(audio_voz_telefono) and audio_voz_telefono.playing:
				var tiempo_audio: float = audio_voz_telefono.get_playback_position()
				if duracion_audio_telefono > 0.0:
					var progreso: float = tiempo_audio / duracion_audio_telefono
					var chars: int = int(progreso * TEXTO_TUTORIAL.length())
					
					if chars >= TEXTO_TUTORIAL.length():
						hud_dialogo.visible_characters = TEXTO_TUTORIAL.length()
					else:
						hud_dialogo.visible_characters = chars
	
	# Verificar si audio terminó (respaldo) - SOLO LLAMAR UNA VEZ
	if estado_actual == ESTADO_INTERACTUANDO and arthur_ha_aparecido and not decision_elegida and not opciones_mostradas:
		if is_instance_valid(audio_voz_arthur) and not audio_voz_arthur.playing:
			if not texto_arthur_completado and hud_dialogo and texto_actual_arthur != "":
				hud_dialogo.visible_characters = texto_actual_arthur.length()
				texto_arthur_completado = true
			_mostrar_opciones_respuesta()
	
	# Luz cabina
	if energia > 0.0:
		energia -= 0.08 * delta
		Actualizar_luz(delta)
	else:
		if is_instance_valid(luz_cabina):
			luz_cabina.light_energy = 0.0
	
	# Acechador
	if is_instance_valid(ojos_acechador):
		if ojos_acechador.visible:
			acechador_visible_left -= delta
			if acechador_visible_left <= 0.0:
				ojos_acechador.hide()
				acechador_next_in = randf_range(acechador_interval_min, acechador_interval_max)
		else:
			acechador_next_in -= delta
			if acechador_next_in <= 0.0:
				ojos_acechador.position = Vector3(
					randf_range(acechador_pos_x_min, acechador_pos_x_max),
					1.6,
					randf_range(acechador_pos_z_min, acechador_pos_z_max)
				)
				ojos_acechador.light_energy = randf_range(acechador_energy_min, acechador_energy_max)
				ojos_acechador.show()
				acechador_visible_left = randf_range(acechador_visible_min, acechador_visible_max)
	
	# Música fade
	if is_instance_valid(musica_fondo):
		musica_fondo.volume_db = lerpf(musica_fondo.volume_db, musica_fondo_objetivo_db, musica_fondo_fade_speed * delta)
	
	# Zoom
	if is_instance_valid(camara) and estado_actual != ESTADO_INTERACTUANDO:
		var zoom_target: float = fov_normal
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			zoom_target = fov_zoom
		camara.fov = lerp(camara.fov, zoom_target, 0.1)
	
	if hud_mirilla:
		hud_mirilla.color = Color(1, 1, 1, 0.5)
	
	if is_instance_valid(label_salida):
		var mostrar: bool = (estado_actual == ESTADO_INTERACTUANDO) and _puede_salir()
		label_salida.visible = mostrar or (arthur_ha_aparecido and not decision_elegida)
		if mostrar:
			label_salida.text = "[Q] Salir"
		elif arthur_ha_aparecido and not decision_elegida:
			label_salida.text = "[Q] Bloqueado"
	
	if is_instance_valid(contenedor_rayos) and not contenedor_rayos.visible:
		contenedor_rayos.show()

# =====================================================================
# _PHYSICS_PROCESS - MOVIMIENTO (Eliminado para evitar conflictos)
# =====================================================================

# =====================================================================
# _INPUT - TECLADO Y RATÓN
# =====================================================================
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if estado_actual == ESTADO_INTERACTUANDO and (event.keycode == KEY_Q or event.keycode == KEY_ESCAPE):
			if inspeccionando_cartel:
				_cerrar_inspeccion_cartel()
			elif _puede_salir():
				_finalizar_interaccion()

func _conectar_interactuables() -> void:
	_conectar_recursivo(self)

func _conectar_recursivo(nodo: Node) -> void:
	if nodo is Interactuable:
		if not nodo.interactuado.is_connected(_on_interactuable_accion):
			nodo.interactuado.connect(_on_interactuable_accion)
		return
		
	# Duck typing: adjuntamos dinámicamente si los nombres coinciden
	var attach_script = false
	if nodo.name == "Radio" or nodo.name == "CuerpoRadio":
		attach_script = true
	elif nodo.name == "Telefono":
		attach_script = true
	elif nodo.name == "Cartel":
		attach_script = true
	elif nodo.name == "Cama":
		attach_script = true
		
	if attach_script and not nodo.has_signal("interactuado"):
		nodo.set_script(load("res://interactuable.gd"))
		if not nodo.interactuado.is_connected(_on_interactuable_accion):
			nodo.interactuado.connect(_on_interactuable_accion)
	
	for hijo in nodo.get_children():
		_conectar_recursivo(hijo)

func _on_interactuable_accion(nombre_objeto: String) -> void:
	if estado_actual == ESTADO_INTERACTUANDO:
		return

	if "Radio" in nombre_objeto or "CuerpoRadio" in nombre_objeto:
		if not radio_encendida:
			_encender_radio()
		_iniciar_interaccion()
	
	elif "Telefono" in nombre_objeto:
		if not telefono_contestado:
			_contestar_telefono()

	elif "Cartel" in nombre_objeto:
		if not inspeccionando_cartel:
			_abrir_inspeccion_cartel()

	elif "Cama" in nombre_objeto:
		if dia_actual == 0:
			_ir_a_dormir()

# =====================================================================
# AUDIO RADIO
# =====================================================================
func _configurar_audio_radio() -> void:
	audio_radio = AudioStreamPlayer.new()
	audio_radio.name = "AudioRadioEstatica"
	add_child(audio_radio)
	if ResourceLoader.exists(PATH_RADIO_ESTATICA):
		var st: AudioStream = load(PATH_RADIO_ESTATICA)
		if st is AudioStreamMP3:
			(st as AudioStreamMP3).loop = true
		audio_radio.stream = st
		audio_radio.volume_db = radio_volumen_estatica_db
	audio_radio.stop()

func _encender_radio() -> void:
	if radio_encendida:
		return
	radio_encendida = true
	_radio_volumen_estatica_activa_db = radio_volumen_estatica_db
	if is_instance_valid(audio_radio):
		audio_radio.volume_db = _radio_volumen_estatica_activa_db
		audio_radio.play()
	_escribir_texto("[color=#c8c8c8]Radio encendida... buscando frecuencia...[/color]")
	
	arthur_ha_aparecido = false
	texto_arthur_completado = false
	decision_elegida = false
	progreso_texto_arthur = 0.0

func _reiniciar_estatica() -> void:
	if not is_instance_valid(audio_radio) or audio_radio.stream == null:
		return
	var vol: float = _radio_volumen_estatica_activa_db
	if arthur_ha_aparecido:
		vol = linear_to_db(db_to_linear(_radio_volumen_estatica_activa_db) * 0.5)
	audio_radio.stop()
	audio_radio.volume_db = vol
	audio_radio.play()

# =====================================================================
# AUDIO ARTHUR
# =====================================================================
func _configurar_audio_arthur() -> void:
	print("Configurando audio de Arthur...")
	
	var nodo_voz = get_node_or_null("VozArthurPlayer")
	
	if nodo_voz != null:
		audio_voz_arthur = nodo_voz as AudioStreamPlayer
		print("✓ Nodo VozArthurPlayer encontrado")
	else:
		audio_voz_arthur = AudioStreamPlayer.new()
		audio_voz_arthur.name = "VozArthurPlayer"
		add_child(audio_voz_arthur)
		print("✓ Nodo VozArthurPlayer creado")
	
	if not ResourceLoader.exists(PATH_VOZ_ARTHUR):
		push_error("ERROR: Audio no encontrado: " + PATH_VOZ_ARTHUR)
		return
	
	var stream: AudioStream = load(PATH_VOZ_ARTHUR)
	if stream == null:
		push_error("ERROR: No se pudo cargar: " + PATH_VOZ_ARTHUR)
		return
	
	audio_voz_arthur.stream = stream
	
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = false
	
	var duracion: float = stream.get_length()
	if duracion > 0.0:
		duracion_audio_arthur = duracion
		print("✓ Audio cargado: ", duracion, " segundos")
	
	if audio_voz_arthur.playing:
		audio_voz_arthur.stop()

# =====================================================================
# TIMER ARTHUR
# =====================================================================
func _configurar_timer_arthur() -> void:
	timer_arthur_aparicion = Timer.new()
	timer_arthur_aparicion.name = "TimerArthurAparicion"
	timer_arthur_aparicion.one_shot = true
	timer_arthur_aparicion.wait_time = segundos_hasta_voz_arthur
	add_child(timer_arthur_aparicion)
	timer_arthur_aparicion.timeout.connect(_on_timer_arthur_timeout)

func _reiniciar_timer_arthur() -> void:
	if arthur_ha_aparecido or not is_instance_valid(timer_arthur_aparicion):
		return
	timer_arthur_aparicion.stop()
	timer_arthur_aparicion.wait_time = segundos_hasta_voz_arthur
	timer_arthur_aparicion.start()

func _detener_timer_arthur() -> void:
	if is_instance_valid(timer_arthur_aparicion):
		timer_arthur_aparicion.stop()

func _on_timer_arthur_timeout() -> void:
	if not is_inside_tree():
		return
	if estado_actual != ESTADO_INTERACTUANDO:
		return
	if arthur_ha_aparecido:
		return
	
	print("=== EVENTO DE ARTHUR ===")
	
	arthur_ha_aparecido = true
	musica_fondo_objetivo_db = musica_fondo_volumen_reducido_db
	
	if is_instance_valid(audio_radio) and audio_radio.playing:
		var lin: float = db_to_linear(audio_radio.volume_db)
		audio_radio.volume_db = linear_to_db(lin * 0.5)
	
	if not is_instance_valid(audio_voz_arthur):
		_configurar_audio_arthur()
	
	if is_instance_valid(audio_voz_arthur) and audio_voz_arthur.stream != null:
		audio_voz_arthur.stop()
		audio_voz_arthur.play()
		print("✓ Audio de Arthur reproduciéndose")
	
	if is_instance_valid(panel_dialogo):
		panel_dialogo.show()
	
	_iniciar_sincronizacion_texto()

# =====================================================================
# MÚSICA FONDO
# =====================================================================
func _configurar_musica_fondo() -> void:
	musica_fondo = AudioStreamPlayer.new()
	musica_fondo.name = "MusicaFondo"
	musica_fondo.bus = &"Master"
	musica_fondo.process_mode = Node.PROCESS_MODE_PAUSABLE
	musica_fondo.volume_db = musica_fondo_volumen_base_db
	musica_fondo.autoplay = true
	musica_fondo_objetivo_db = musica_fondo_volumen_base_db
	
	if ResourceLoader.exists(PATH_AMBIENTE_FONDO):
		var st: AudioStream = load(PATH_AMBIENTE_FONDO)
		if st is AudioStreamMP3:
			(st as AudioStreamMP3).loop = true
		musica_fondo.stream = st
	
	add_child(musica_fondo)

# =====================================================================
# SINCRONIZACIÓN TEXTO-AUDIO
# =====================================================================
func _iniciar_sincronizacion_texto() -> void:
	texto_actual_arthur = TEXTO_PRIMERA_LINEA
	texto_arthur_completado = false
	decision_elegida = false
	progreso_texto_arthur = 0.0
	opciones_mostradas = false  # Resetear candado
	
	velocidad_texto_arthur = texto_actual_arthur.length() / duracion_audio_arthur
	
	print("=== INICIANDO SINCRONIZACIÓN TEXTO-AUDIO ===")
	print("Texto: ", texto_actual_arthur.length(), " caracteres")
	print("Duración audio: ", duracion_audio_arthur, " segundos")
	print("===========================================")
	
	# Configurar el RichTextLabel correctamente
	if is_instance_valid(hud_dialogo):
		hud_dialogo.text = ""
		hud_dialogo.bbcode_text = texto_actual_arthur
		hud_dialogo.visible_characters = 0
		hud_dialogo.show()
		hud_dialogo.visible = true
		print("✓ Texto configurado en RichTextLabel")
	else:
		push_error("ERROR: hud_dialogo no es válido")
	
	# Asegurar que el panel de diálogo esté visible
	if is_instance_valid(panel_dialogo):
		panel_dialogo.show()
		print("✓ Panel de diálogo mostrado")
	
	# Ocultar contenedor de opciones/preguntas
	if is_instance_valid(contenedor_preguntas):
		contenedor_preguntas.hide()
	
	# Conectar señal de audio terminado
	if is_instance_valid(audio_voz_arthur):
		if audio_voz_arthur.finished.is_connected(_on_audio_terminado):
			audio_voz_arthur.finished.disconnect(_on_audio_terminado)
		audio_voz_arthur.finished.connect(_on_audio_terminado)

func _on_audio_terminado() -> void:
	print("Audio terminado")
	if hud_dialogo and texto_actual_arthur != "":
		hud_dialogo.visible_characters = texto_actual_arthur.length()
		texto_arthur_completado = true
	
	if not decision_elegida:
		# Si es la primera vez que habla, mostramos los botones
		_mostrar_opciones_respuesta()
	else:
		# Si ya respondimos, esperamos 1.5 segundos y cerramos la radio automáticamente
		await get_tree().create_timer(1.5).timeout
		if estado_actual == ESTADO_INTERACTUANDO:
			_finalizar_interaccion()

# =====================================================================
# MOSTRAR OPCIONES DE RESPUESTA
# =====================================================================
func _mostrar_opciones_respuesta() -> void:
	# CANDADO: Evitar recrear botones 60 veces por segundo
	if opciones_mostradas:
		return
	opciones_mostradas = true
	
	if not is_instance_valid(contenedor_preguntas):
		push_error("ERROR: contenedor_preguntas no es válido")
		return
	if decision_elegida:
		return
	
	print("=== MOSTRANDO OPCIONES DE RESPUESTA (UNA SOLA VEZ) ===")
	
	# Liberar ratón para permitir clics
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("✓ Ratón liberado (MOUSE_MODE_VISIBLE)")
	
	# Limpiar botones existentes
	for c in contenedor_preguntas.get_children():
		c.queue_free()
	
	# Botón A - "Te escucho..."
	var btn_a: Button = Button.new()
	btn_a.name = "BotonOpcionA"
	btn_a.text = OPCION_A
	btn_a.pressed.connect(_on_opcion_a)
	btn_a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_a.custom_minimum_size = Vector2(350, 80)
	btn_a.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var style_a = StyleBoxFlat.new()
	style_a.bg_color = Color(0, 0, 0, 0.7)
	style_a.border_color = Color(1, 1, 1, 1)
	style_a.border_width_left = 3
	style_a.border_width_top = 3
	style_a.border_width_right = 3
	style_a.border_width_bottom = 3
	style_a.content_margin_left = 20
	style_a.content_margin_top = 15
	style_a.content_margin_right = 20
	style_a.content_margin_bottom = 15
	btn_a.add_theme_stylebox_override("normal", style_a)
	
	contenedor_preguntas.add_child(btn_a)
	
	# Botón B - "¿Quién eres?"
	var btn_b: Button = Button.new()
	btn_b.name = "BotonOpcionB"
	btn_b.text = OPCION_B
	btn_b.pressed.connect(_on_opcion_b)
	btn_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_b.custom_minimum_size = Vector2(350, 80)
	btn_b.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var style_b = StyleBoxFlat.new()
	style_b.bg_color = Color(0, 0, 0, 0.7)
	style_b.border_color = Color(1, 1, 1, 1)
	style_b.border_width_left = 3
	style_b.border_width_top = 3
	style_b.border_width_right = 3
	style_b.border_width_bottom = 3
	style_b.content_margin_left = 20
	style_b.content_margin_top = 15
	style_b.content_margin_right = 20
	style_b.content_margin_bottom = 15
	btn_b.add_theme_stylebox_override("normal", style_b)
	
	contenedor_preguntas.add_child(btn_b)
	
	# Dar foco al primer botón
	btn_a.grab_focus()
	
	# Mostrar contenedor
	contenedor_preguntas.show()
	print("✓ Contenedor de preguntas mostrado (HBoxContainer)")
	
	# Ocultar mirilla mientras el ratón es visible
	if is_instance_valid(hud_mirilla):
		hud_mirilla.hide()
		print("✓ Mirilla ocultada")
	
	print("========================================")

func _on_opcion_a() -> void:
	decision_elegida = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_instance_valid(hud_mirilla):
		hud_mirilla.show()
	if is_instance_valid(contenedor_preguntas):
		contenedor_preguntas.hide()
	
	texto_actual_arthur = RESPUESTA_A
	texto_arthur_completado = false
	
	if ResourceLoader.exists(PATH_VOZ_ARTHUR_A):
		var stream: AudioStream = load(PATH_VOZ_ARTHUR_A)
		if is_instance_valid(audio_voz_arthur):
			audio_voz_arthur.stream = stream
			duracion_audio_arthur = stream.get_length()
			audio_voz_arthur.play()
	
	if is_instance_valid(hud_dialogo):
		hud_dialogo.text = ""
		hud_dialogo.bbcode_text = texto_actual_arthur
		hud_dialogo.visible_characters = 0

func _on_opcion_b() -> void:
	decision_elegida = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_instance_valid(hud_mirilla):
		hud_mirilla.show()
	if is_instance_valid(contenedor_preguntas):
		contenedor_preguntas.hide()
	
	texto_actual_arthur = RESPUESTA_B
	texto_arthur_completado = false
	
	if ResourceLoader.exists(PATH_VOZ_ARTHUR_B):
		var stream: AudioStream = load(PATH_VOZ_ARTHUR_B)
		if is_instance_valid(audio_voz_arthur):
			audio_voz_arthur.stream = stream
			duracion_audio_arthur = stream.get_length()
			audio_voz_arthur.play()
	
	if is_instance_valid(hud_dialogo):
		hud_dialogo.text = ""
		hud_dialogo.bbcode_text = texto_actual_arthur
		hud_dialogo.visible_characters = 0

# =====================================================================
# INTERACCIÓN
# =====================================================================
func _iniciar_interaccion(foco_radio: Vector3 = Vector3.ZERO) -> void:
	if estado_actual == ESTADO_INTERACTUANDO:
		return
	
	if is_instance_valid(jugador):
		camara_guardada_yaw = jugador.rotation.y
		camara_guardada_pitch = rotacion_x
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	modo_interaccion = true
	estado_actual = ESTADO_INTERACTUANDO
	
	_reiniciar_timer_arthur()
	_reiniciar_estatica()
	
	if is_instance_valid(panel_dialogo):
		panel_dialogo.show()
	if is_instance_valid(label_salida):
		label_salida.visible = true
	if is_instance_valid(contenedor_rayos):
		contenedor_rayos.show()
	
	_escribir_texto("[color=#c8c8c8]Frecuencia abierta... esperando señal...[/color]")

func _finalizar_interaccion() -> void:
	if arthur_ha_aparecido and not decision_elegida:
		return
	
	modo_interaccion = false
	estado_actual = ESTADO_EXPLORANDO
	
	_detener_timer_arthur()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if is_instance_valid(jugador):
		jugador.rotation.y = camara_guardada_yaw
	rotacion_x = camara_guardada_pitch
	if is_instance_valid(camara):
		camara.rotation.x = rotacion_x
	
	if is_instance_valid(audio_radio):
		audio_radio.stop()
	
	if is_instance_valid(audio_voz_arthur):
		if audio_voz_arthur.playing:
			audio_voz_arthur.stop()
		if audio_voz_arthur.finished.is_connected(_on_audio_terminado):
			audio_voz_arthur.finished.disconnect(_on_audio_terminado)
			
	if is_instance_valid(audio_voz_telefono):
		if audio_voz_telefono.playing:
			audio_voz_telefono.stop()
		if audio_voz_telefono.finished.is_connected(_on_audio_telefono_terminado):
			audio_voz_telefono.finished.disconnect(_on_audio_telefono_terminado)
	
	musica_fondo_objetivo_db = musica_fondo_volumen_base_db
	
	if is_instance_valid(panel_dialogo):
		panel_dialogo.hide()
	if is_instance_valid(label_salida):
		label_salida.visible = false
	if is_instance_valid(contenedor_preguntas):
		contenedor_preguntas.hide()
	if is_instance_valid(contenedor_rayos):
		contenedor_rayos.show()
	if is_instance_valid(hud_mirilla):
		hud_mirilla.show()
	
	texto_arthur_completado = false
	decision_elegida = false
	progreso_texto_arthur = 0.0

func _puede_salir() -> bool:
	if estado_actual != ESTADO_INTERACTUANDO:
		return false
	if arthur_ha_aparecido and not decision_elegida:
		return false
	if tutorial_telefono_en_curso:
		return false
	return true

# =====================================================================
# TEXTO
# =====================================================================
func _escribir_texto(t: String) -> void:
	texto_destino = t
	caracteres_mostrados = 0.0
	
	if hud_dialogo:
		hud_dialogo.text = t
		hud_dialogo.visible_characters = 0

# =====================================================================
# RAYOS
# =====================================================================
func _actualizar_iconos_rayo() -> void:
	for i in range(iconos_rayo.size()):
		var icon: TextureRect = iconos_rayo[i]
		if is_instance_valid(icon):
			icon.modulate = Color(1.0, 1.0, 1.0, 1.0) if i < rayos_restantes else Color(0.22, 0.22, 0.22, 0.45)

# =====================================================================
# LUZ CABINA
# =====================================================================
func Actualizar_luz(delta: float) -> void:
	if not is_instance_valid(luz_cabina):
		return
	
	var es_critico: bool = energia <= 20.0
	tiempo_ruido += delta * (55.0 if es_critico else 15.0)
	
	var umbral: float = 0.62 if es_critico else 0.92
	if randf() > umbral:
		luz_cabina.visible = false
	else:
		luz_cabina.visible = true
		var variacion: float = 10.0 if es_critico else 2.0
		luz_cabina.light_energy = energia_luz_max + randf_range(-variacion, variacion)
		
		if es_critico and randf() > 0.85:
			luz_cabina.light_energy += randf_range(8.0, 20.0)

# =====================================================================
# ACECHADOR
# =====================================================================
func _crear_acechador() -> void:
	ojos_acechador = OmniLight3D.new()
	ojos_acechador.light_color = Color.RED
	ojos_acechador.light_energy = 25.0
	add_child(ojos_acechador)
	ojos_acechador.position = Vector3(randf_range(-6.0, 6.0), 1.6, -15.0)
	ojos_acechador.hide()

# =====================================================================
# CARGA DE RECURSOS
# =====================================================================
func _cargar_recursos() -> void:
	if ResourceLoader.exists(PATH_FICHA_ARTHUR):
		textura_ficha_normal = load(PATH_FICHA_ARTHUR)

# =====================================================================
# RAYCAST CONFIG
# =====================================================================
func _configurar_raycast() -> void:
	if not is_instance_valid(camara):
		push_error("Asigna `camara` en el Inspector.")
		return
	if not is_instance_valid(raycast_radio):
		var rc := RayCast3D.new()
		rc.name = "RayCastRadio"
		rc.enabled = true
		rc.target_position = Vector3(0.0, 0.0, -6.0)
		rc.collision_mask = 1048575
		camara.add_child(rc)
		raycast_radio = rc

# =====================================================================
# CREAR UI
# =====================================================================
func _crear_ui() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)
	
	# Shader PS1
	hud_shader = ColorRect.new()
	hud_shader.name = "PostProcesadoPS1"
	hud_shader.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_shader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_shader.z_index = -100
	hud_shader.color = Color(1, 1, 1, 0)
	canvas.add_child(hud_shader)
	
	var path_shader := "res://assets/ps1_horror.gdshader"
	if ResourceLoader.exists(path_shader):
		var res: Resource = load(path_shader)
		if res is Shader:
			var mat := ShaderMaterial.new()
			mat.shader = res as Shader
			mat.set_shader_parameter("scanline_intensity", 0.26)
			mat.set_shader_parameter("resolution_scale", 3.5)
			mat.set_shader_parameter("noise_intensity", 0.06)
			hud_shader.material = mat
			hud_shader.color = Color(1, 1, 1, 1)
	
	# Mirilla
	hud_mirilla = ColorRect.new()
	hud_mirilla.custom_minimum_size = Vector2(6, 6)
	hud_mirilla.mouse_filter = Control.MOUSE_FILTER_IGNORE  # IMPORTANTE: no bloquear clics
	canvas.add_child(hud_mirilla)
	hud_mirilla.set_anchors_preset(Control.PRESET_CENTER)
	
	# Label ayuda [E]
	label_ayuda = Label.new()
	label_ayuda.text = "[E] INTERACTUAR CON RADIO"
	label_ayuda.add_theme_font_size_override("font_size", 24)
	label_ayuda.add_theme_color_override("font_color", Color(1.0, 0.96, 0.28))
	label_ayuda.add_theme_color_override("font_outline_color", Color.BLACK)
	label_ayuda.add_theme_constant_override("outline_size", 6)
	canvas.add_child(label_ayuda)
	label_ayuda.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	label_ayuda.anchor_left = 0.0
	label_ayuda.anchor_right = 1.0
	label_ayuda.offset_left = 0.0
	label_ayuda.offset_right = 0.0
	label_ayuda.offset_bottom = -50.0
	label_ayuda.offset_top = -130.0
	label_ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_ayuda.visible = false
	label_ayuda.modulate = Color(1, 1, 1, 0)
	
	# Label salida [Q]
	label_salida = Label.new()
	label_salida.text = "[Q] Salir"
	label_salida.add_theme_font_size_override("font_size", 18)
	label_salida.add_theme_color_override("font_color", Color(1.0, 0.96, 0.28))
	label_salida.add_theme_color_override("font_outline_color", Color.BLACK)
	label_salida.add_theme_constant_override("outline_size", 4)
	canvas.add_child(label_salida)
	label_salida.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	label_salida.offset_top = 18.0
	label_salida.offset_right = -18.0
	label_salida.offset_left = -210.0
	label_salida.offset_bottom = 56.0
	label_salida.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label_salida.visible = false
	
	# Ficha Arthur
	panel_ficha = ColorRect.new()
	panel_ficha.color = Color(0, 0, 0, 0)
	panel_ficha.custom_minimum_size = Vector2(300, 300)
	canvas.add_child(panel_ficha)
	panel_ficha.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	panel_ficha.offset_left = -320
	panel_ficha.offset_right = -20
	panel_ficha.hide()
	
	hud_ficha = TextureRect.new()
	panel_ficha.add_child(hud_ficha)
	hud_ficha.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_ficha.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Panel de diálogo - PanelContainer con estilo cajita negra (CENTRADO)
	panel_dialogo = PanelContainer.new()
	panel_dialogo.name = "PanelDialogo"
	canvas.add_child(panel_dialogo)
	
	# Configuración manual de anchors para centrado horizontal perfecto
	panel_dialogo.anchor_left = 0.5  # Centro horizontal
	panel_dialogo.anchor_right = 0.5  # Centro horizontal
	panel_dialogo.anchor_top = 1.0    # Abajo
	panel_dialogo.anchor_bottom = 1.0  # Abajo
	
	panel_dialogo.custom_minimum_size = Vector2(800, 150)
	
	# Posición: centrado horizontalmente, elevado 50px del borde inferior
	panel_dialogo.offset_left = -400  # -800/2 para centrar
	panel_dialogo.offset_right = 400   # 800/2 para centrar
	panel_dialogo.offset_top = -150    # Altura del panel
	panel_dialogo.offset_bottom = -50  # Margen inferior de 50px
	
	panel_dialogo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_dialogo.z_index = 10
	
	# Estilo del panel: fondo negro semi-transparente con borde blanco fino
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.8)  # Negro semi-transparente
	style_box.border_color = Color.WHITE
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.content_margin_left = 15
	style_box.content_margin_top = 10
	style_box.content_margin_right = 15
	style_box.content_margin_bottom = 10
	panel_dialogo.add_theme_stylebox_override("panel", style_box)
	panel_dialogo.hide()
	
	# Texto diálogo - RichTextLabel blanco centrado
	hud_dialogo = RichTextLabel.new()
	hud_dialogo.name = "HudDialogo"
	hud_dialogo.bbcode_enabled = true
	hud_dialogo.add_theme_color_override("default_color", Color.WHITE)  # Blanco
	hud_dialogo.add_theme_font_size_override("normal_font_size", 20)
	hud_dialogo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER  # Centrado
	hud_dialogo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER  # Centrado vertical
	hud_dialogo.scroll_active = false
	hud_dialogo.fit_content = false  # IMPORTANTE: false para ocupar todo el espacio
	hud_dialogo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_dialogo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hud_dialogo.mouse_filter = Control.MOUSE_FILTER_IGNORE  # No bloquear clics
	# Márgenes internos para que el texto no toque los bordes
	hud_dialogo.add_theme_constant_override("margin_left", 10)
	hud_dialogo.add_theme_constant_override("margin_top", 10)
	hud_dialogo.add_theme_constant_override("margin_right", 10)
	hud_dialogo.add_theme_constant_override("margin_bottom", 10)
	panel_dialogo.add_child(hud_dialogo)
	hud_dialogo.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Contenedor de preguntas (HBoxContainer - encima del diálogo, centrado)
	contenedor_preguntas = HBoxContainer.new()
	contenedor_preguntas.name = "ContenedorPreguntas"
	contenedor_preguntas.alignment = BoxContainer.ALIGNMENT_CENTER  # Centrado horizontal
	contenedor_preguntas.z_index = 1000  # MUY ALTO: por encima de TODO
	canvas.add_child(contenedor_preguntas)
	contenedor_preguntas.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	contenedor_preguntas.anchor_left = 0.0
	contenedor_preguntas.anchor_right = 1.0
	contenedor_preguntas.offset_left = 50
	contenedor_preguntas.offset_right = -50
	contenedor_preguntas.offset_top = -260  # Justo encima del diálogo
	contenedor_preguntas.offset_bottom = -210
	contenedor_preguntas.add_theme_constant_override("separation", 40)
	contenedor_preguntas.mouse_filter = Control.MOUSE_FILTER_PASS  # PASS: pasar clics a botones
	contenedor_preguntas.hide()
	
	# Contenedor de opciones (alias para compatibilidad)
	contenedor_opciones = contenedor_preguntas
	
	# IMPORTANTE: Mover contenedor_preguntas al final para que esté encima de todo
	canvas.move_child(contenedor_preguntas, -1)
	
	# Rayos (arriba izquierda)
	iconos_rayo.clear()
	contenedor_rayos = HBoxContainer.new()
	contenedor_rayos.name = "ContenedorRayos"
	canvas.add_child(contenedor_rayos)
	contenedor_rayos.set_anchors_preset(Control.PRESET_TOP_LEFT)
	contenedor_rayos.offset_left = 20.0
	contenedor_rayos.offset_top = 20.0
	contenedor_rayos.add_theme_constant_override("separation", 6)
	
	if ResourceLoader.exists(PATH_ICONO_RAYO):
		var tex: Texture2D = load(PATH_ICONO_RAYO)
		for _i in range(rayos_maximos):
			var tr := TextureRect.new()
			tr.custom_minimum_size = Vector2(40, 40)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.texture = tex
			tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			contenedor_rayos.add_child(tr)
			iconos_rayo.append(tr)
	
	# Contenedores compatibilidad (vacíos, ocultos)
	contenedor_botones = GridContainer.new()
	contenedor_botones.hide()
	canvas.add_child(contenedor_botones)
	
	# contenedor_preguntas ya fue creado anteriormente como HBoxContainer

func _contestar_telefono() -> void:
	telefono_contestado = true
	tutorial_telefono_en_curso = true
	estado_actual = ESTADO_INTERACTUANDO
	modo_interaccion = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if is_instance_valid(jugador):
		camara_guardada_yaw = jugador.rotation.y
		camara_guardada_pitch = rotacion_x
		
	if is_instance_valid(audio_timbre_telefono):
		audio_timbre_telefono.stop() # Cortamos el timbre
	
	# Reproducimos la voz del tutorial
	if ResourceLoader.exists(PATH_VOZ_TELEFONO):
		var stream: AudioStream = load(PATH_VOZ_TELEFONO)
		if is_instance_valid(audio_voz_telefono):
			audio_voz_telefono.stream = stream
			duracion_audio_telefono = stream.get_length()
			
			if audio_voz_telefono.finished.is_connected(_on_audio_telefono_terminado):
				audio_voz_telefono.finished.disconnect(_on_audio_telefono_terminado)
			audio_voz_telefono.finished.connect(_on_audio_telefono_terminado)
			
			audio_voz_telefono.play()
			
	if is_instance_valid(label_salida):
		label_salida.visible = true
		label_salida.text = "[Q] Bloqueado"
		
	if is_instance_valid(panel_dialogo):
		panel_dialogo.show()
	
	# Mostramos los subtítulos en la UI de diálogo
	if is_instance_valid(hud_dialogo):
		hud_dialogo.get_parent().show() # Aseguramos que el panel sea visible
		hud_dialogo.text = ""
		hud_dialogo.bbcode_text = TEXTO_TUTORIAL
		hud_dialogo.visible_characters = 0
	
	print("Tutorial del teléfono reproduciéndose.")

func _on_audio_telefono_terminado() -> void:
	if hud_dialogo and TEXTO_TUTORIAL != "":
		hud_dialogo.visible_characters = TEXTO_TUTORIAL.length()
	
	await get_tree().create_timer(2.0).timeout
	if estado_actual == ESTADO_INTERACTUANDO and tutorial_telefono_en_curso:
		tutorial_telefono_en_curso = false
		_finalizar_interaccion()

func _abrir_inspeccion_cartel():
	inspeccionando_cartel = true
	estado_actual = ESTADO_INTERACTUANDO
	if is_instance_valid(ui_cartel_zoom): ui_cartel_zoom.show()
	if is_instance_valid(hud_mirilla): hud_mirilla.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _cerrar_inspeccion_cartel():
	inspeccionando_cartel = false
	estado_actual = ESTADO_EXPLORANDO
	if is_instance_valid(ui_cartel_zoom): ui_cartel_zoom.hide()
	if is_instance_valid(hud_mirilla): hud_mirilla.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ir_a_dormir():
	estado_actual = ESTADO_INTERACTUANDO
	if is_instance_valid(hud_mirilla): hud_mirilla.hide()
	
	var tween = create_tween()
	# Hace que el ColorRect pase de transparente (0) a negro (1) en 2 segundos
	tween.tween_property(ui_fundido_negro, "modulate:a", 1.0, 2.0)
	await tween.finished
	
	if is_instance_valid(label_dia): label_dia.show()
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(label_dia): label_dia.hide()
	
	dia_actual = 1
	
	var tween_out = create_tween()
	tween_out.tween_property(ui_fundido_negro, "modulate:a", 0.0, 2.0)
	await tween_out.finished
	
	estado_actual = ESTADO_EXPLORANDO
	if is_instance_valid(hud_mirilla): hud_mirilla.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _ejecutar_cinematica_segura():
	# 1. Bloqueamos al jugador
	estado_actual = ESTADO_INTERACTUANDO
	
	# 2. Activamos la cámara de cine
	if has_node("CamaraCinematica"):
		$CamaraCinematica.make_current()
	
	# 3. Arrancamos la animación visual
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("cinematica_inicio")
	
	# 4. DISPARAMOS EL AUDIO (audio_defini_animacion1)
	if is_instance_valid(voz_arthur_player):
		voz_arthur_player.play()
		print("¡El audio de Arthur debería estar sonando ahora!")
	
	# 5. TIEMPO DE ESPERA (Ajusta los segundos a lo que dure tu audio)
	# Si tu audio dura 12 segundos, pon 12.0
	await get_tree().create_timer(22.0).timeout 
	
	# 6. Devolvemos el control al jugador
	if is_instance_valid(camara):
		camara.make_current()
	
	estado_actual = ESTADO_EXPLORANDO
	print("Fin de la cinemática: Jugador libre.")
