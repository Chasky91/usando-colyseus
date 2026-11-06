extends Node

const JUGADOR = preload("res://escena_Prueba.tscn")

var client: Colyseus.Client
var room: Colyseus.Room
var callbacks: Colyseus.Callbacks
var nodos := {}   # sessionId -> nodo del jugador

func conectar(skin: String):
	client = Colyseus.Client.new("ws://localhost:2567")
	room = client.join_or_create("sala_juego", {"skin": skin})
	if room:
		room.joined.connect(_on_unido)
		room.message_received.connect(_on_mensaje)
		room.error.connect(func(code, msg): printerr("Error ", code, ": ", msg))

func _on_unido():
	callbacks = Colyseus.Callbacks.of(room)
	callbacks.on_add("jugadores", _on_jugador_agregado)      # = Spawner
	callbacks.on_remove("jugadores", _on_jugador_eliminado)

func _on_jugador_agregado(jugador, session_id: String):
	var nodo = JUGADOR.instantiate()
	nodo.name = session_id
	nodo.es_local = (session_id == room.get_session_id())
	get_tree().current_scene.get_node("Jugadores").add_child(nodo)
	nodos[session_id] = nodo

	# = Synchronizer: escuchar cambios de cada propiedad
	callbacks.listen(jugador, "x", func(v, _ant): nodo.objetivo.x = v)
	callbacks.listen(jugador, "y", func(v, _ant): nodo.objetivo.y = v)
	callbacks.listen(jugador, "vida", func(v, _ant): nodo.set_vida(v))
	callbacks.listen(jugador, "skin", func(v, _ant): nodo.set_skin(v))

func _on_jugador_eliminado(_jugador, session_id: String):
	if nodos.has(session_id):
		nodos[session_id].queue_free()
		nodos.erase(session_id)

func _on_mensaje(tipo, data):
	if tipo == "golpe" and nodos.has(data.objetivo):
		nodos[data.objetivo].animar_golpe()

# --- Funciones para llamar desde el juego ---
func enviar_posicion(pos: Vector2):
	room.send_message("mover", {"x": pos.x, "y": pos.y})

func atacar(objetivo_id: String):
	room.send_message("atacar", {"objetivo": objetivo_id})
