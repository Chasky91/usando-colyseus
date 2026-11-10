extends Node

var client: Colyseus.Client
var room: Colyseus.Room
var callbacks: Colyseus.Callbacks
var nodos_jugadores := {}

func _ready():
	client = Colyseus.Client.new("ws://localhost:2567")
	room = client.join_or_create("my_room")
	if room:
		room.joined.connect(_on_joined)
		room.message_received.connect(_on_message)
		room.error.connect(func(code, msg): printerr("Error ", code, ": ", msg))

func _on_joined():
	print("Conectado. Mi ID: ", room.get_session_id())
	callbacks = Colyseus.Callbacks.of(room)
	callbacks.on_add("players", _on_player_add)
	callbacks.on_remove("players", _on_player_remove)

func _on_player_add(player, key: String):
	var sprite := Sprite2D.new()
	sprite.texture = preload("res://icon.svg")
	add_child(sprite)
	nodos_jugadores[key] = sprite
	callbacks.listen(player, "x", func(actual, _ant): sprite.position.x = actual)
	callbacks.listen(player, "y", func(actual, _ant): sprite.position.y = actual)

func _on_player_remove(_player, key: String):
	if nodos_jugadores.has(key):
		nodos_jugadores[key].queue_free()
		nodos_jugadores.erase(key)

func _on_message(type, data):
	print("[", type, "] ", data)   # recibe el broadcast "chat"

func mover(pos: Vector2):
	if room and room.connected:
		room.send_message("move", {"x": pos.x, "y": pos.y})   # → messages.move en Node
