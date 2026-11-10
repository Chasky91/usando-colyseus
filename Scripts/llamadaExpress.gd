extends Node

func enviar_puntos():
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_r, _c, _h, body):
		print(JSON.parse_string(body.get_string_from_utf8())))
	var datos := JSON.stringify({"nombre": "Ana", "puntos": 150})
	http.request("http://localhost:2567/puntos",
		["Content-Type: application/json"], HTTPClient.METHOD_POST, datos)
