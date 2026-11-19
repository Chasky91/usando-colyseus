extends Control

const URL = "http://localhost:2567"

@onready var usuario = $CenterContainer/VBoxContainer/usuario
@onready var boton  =$CenterContainer/VBoxContainer/entrar
@onready var password = $CenterContainer/VBoxContainer/password
@onready var http = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boton.pressed.connect(_entrar)
	usuario.grab_focus()
	password.text_submitted.connect(func(_t): _entrar())
	boton.pressed.connect(_entrar)
	print("en  ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _entrar():
	var body = JSON.stringify({"usuario": usuario.text.strip_edges(), "password":password.text})
	http.request(URL + "/login", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	print(body)	
	print("Presiono")
	print(usuario.text.strip_edges())
