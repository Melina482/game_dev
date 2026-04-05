extends Control


@onready var authLayout = $AuthenticatedLayout
@onready var unAuthLayout = $UnauthenticatedLayout
@onready var loginInput = $"UnauthenticatedLayout/Username Input"
@onready var passwordInput = $"UnauthenticatedLayout/Password Input"
@onready var errorLabel = $UnauthenticatedLayout/ErrorLabel
@onready var numOfPlayersJoinedLabel = $AuthenticatedLayout/PlayersJoined

var authManager = AuthClass.new()

func _ready() -> void:
	authLayout.visible = false
	unAuthLayout.visible = true
	errorLabel.visible = false
	
	var test = ENetMultiplayerPeer.new()
	var result = test.create_server(8080)
	test.close()
	# we are running 3 instances (2 clients 1 server) for debugging
	# but in real cases there should be a dedicated server 
	if result == OK: 
		hide() 
		ServerClientManager.initialize_server()
		ServerClientManager.is_dedicated_server = true
	
	multiplayer.server_disconnected.connect(_on_kicked)

func _on_login_button_pressed() -> void:
	var username = loginInput.text.strip_edges()
	var password = passwordInput.text.strip_edges()
	
	var validUser = authManager.login_player(username, password)
	
	if validUser:
		authLayout.visible = true
		unAuthLayout.visible = false
		ServerClientManager.connect_client_to_server(username)
	else:
		errorLabel.visible = true
		loginInput.text = ""
		passwordInput.text = ""

func _on_kicked() -> void:
	authLayout.visible = false
	unAuthLayout.visible = true
	errorLabel.text = "User is already logged in!"
	errorLabel.visible = true
	
func _on_play_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
