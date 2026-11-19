extends Node2D

var room
var callbacks
var mi_id = ""
var jugadores = {}

func _ready():
	var client = Colyseus.Client.new("ws://localhost:2567")
	room = client.join_or_create("mi_sala")
	room.joined.connect(_al_unirme)
	print("se unio")

func _al_unirme():
	mi_id = room.get_session_id()
	print(mi_id)
	callbacks = Colyseus.Callbacks.of(room)
	callbacks.on_add("jugadores", _jugador_entra)
	callbacks.on_remove("jugadores", _jugador_sale)

func _jugador_entra(jugador, id):
	var cuadro = ColorRect.new()
	cuadro.size = Vector2(32, 32)
	cuadro.position = Vector2(jugador["x"], jugador["y"])
	cuadro.color = Color.GREEN if id == mi_id else Color.RED
	add_child(cuadro)
	jugadores[id] = cuadro

	# A los demás los movemos con lo que manda el servidor
	if id != mi_id:
		callbacks.listen(jugador, "x", func(valor, _antes): cuadro.position.x = valor)
		callbacks.listen(jugador, "y", func(valor, _antes): cuadro.position.y = valor)

func _jugador_sale(_jugador, id):
	jugadores[id].queue_free()
	jugadores.erase(id)

func _process(delta):
	if not jugadores.has(mi_id):
		return
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direccion != Vector2.ZERO:
		var yo = jugadores[mi_id]
		yo.position += direccion * 200 * delta
		room.send_message("mover", {"x": yo.position.x, "y": yo.position.y})
