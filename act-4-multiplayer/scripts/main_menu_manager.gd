extends Control

@onready var authLayout = $AuthenticatedLayout
@onready var unAuthLayout = $UnauthenticatedLayout

@onready var loginInput = $"UnauthenticatedLayout/Username Input"
@onready var passwordInput = $"UnauthenticatedLayout/Password Input"
@onready var errorLabel = $UnauthenticatedLayout/ErrorLabel

var AccountInfo = [
	{
		"username": "User1",
		"password": "userpass1",
		"isAlreadyLoggedIn": false
	},
	{
		"username": "User2",
		"password": "userpass2",
		"isAlreadyLoggedIn": false
	}
]

func _ready() -> void:
	authLayout.visible = false
	unAuthLayout.visible = true
	errorLabel.visible = false


func _on_login_button_pressed() -> void:
	var username = loginInput.text.strip_edges()
	var password = passwordInput.text.strip_edges()

	for account in AccountInfo:
		if account["username"] == username and account["password"] == password:
			print("Login successful")
			
			unAuthLayout.visible = false
			authLayout.visible = true
			return
			
	# If login fails
	print("Invalid username or password")
	errorLabel.visible = true
	
	loginInput.text = ""
	passwordInput.text = ""

func _on_play_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
