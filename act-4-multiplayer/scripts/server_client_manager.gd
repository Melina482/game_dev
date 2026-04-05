extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var player_scenes = preload("res://scenes/multiplayer_player.tscn")
var _players_spawn_node

var is_dedicated_server = false
var connected_users = {}

func initialize_server():
	print("Starting server")
	
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_connect_player)
	multiplayer.peer_disconnected.connect(_disconnect_player)
	
func connect_client_to_server(userName: String):	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	# wait for connection then register username
	await multiplayer.connected_to_server
	register_username.rpc_id(1, userName)

func _connect_player(id: int):
	print("User %d has joined the game." % id)
	
func _disconnect_player(id: int):
	for username in connected_users.keys():
		if connected_users[username] == id:
			connected_users.erase(username)
			print("%s has disconnected." % username)
			break

func spawn_player(peer_id: int):
	if peer_id == 1:
		return
	
	var spawn_node = get_tree().get_current_scene().get_node_or_null("Players")
	if spawn_node == null:
		print("Players node not found!")
		return
	
	if spawn_node.has_node(str(peer_id)):
		print("Player %d already spawned, skipping." % peer_id)
		return
	
	# spawn on server first
	_do_spawn_player(peer_id)
	
	# tell ALL clients to spawn this player
	spawn_player_on_clients.rpc(peer_id)

func _do_spawn_player(peer_id: int):
	var spawn_node = get_tree().get_current_scene().get_node_or_null("Players")
	if spawn_node == null:
		return
	if spawn_node.has_node(str(peer_id)):
		return
	var player_to_add = player_scenes.instantiate()
	player_to_add.name = str(peer_id)
	player_to_add.player_id = peer_id
	spawn_node.add_child(player_to_add)
	print("Spawned player %d" % peer_id)
	
func get_existing_player_ids() -> Array:
	var spawn_node = get_tree().get_current_scene().get_node_or_null("Players")
	if spawn_node == null:
		return []
	var ids = []
	for child in spawn_node.get_children():
		ids.append(int(child.name))
	return ids

# client calls this after scene loads
@rpc("any_peer", "reliable")
func notify_scene_ready(peer_id: int):
	if multiplayer.is_server():
		var current_scene = get_tree().get_current_scene()
		var is_in_game = current_scene.scene_file_path == "res://scenes/game_scene.tscn"
		
		if not is_in_game:
			get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
			await get_tree().create_timer(0.2).timeout
			if is_dedicated_server:
				get_tree().get_current_scene().hide()
		
		# spawn existing players on the new client
		for existing_id in get_existing_player_ids():
			spawn_player_on_clients.rpc_id(peer_id, existing_id)
		
		# spawn this new player on everyone
		spawn_player(peer_id)

@rpc("any_peer", "reliable")
func register_username(username: String):
	print("register_username called with: %s" % username)
	if multiplayer.is_server():
		print("I am server, connected_users: %s" % str(connected_users))
		var sender_id = multiplayer.get_remote_sender_id()
		if username in connected_users:
			print("KICKING %d" % sender_id)
			multiplayer.multiplayer_peer.disconnect_peer(sender_id)
		else:
			connected_users[username] = sender_id
			print("%s registered." % username)

@rpc("authority", "call_local", "reliable")
func spawn_player_on_clients(peer_id: int):
	if multiplayer.is_server():
		return  # server already spawned it
	_do_spawn_player(peer_id)
	# Set authority after spawning locally
	await get_tree().create_timer(0.1).timeout
	var spawn_node = get_tree().get_current_scene().get_node_or_null("Players")
	if spawn_node == null:
		return
	var player = spawn_node.get_node_or_null(str(peer_id))
	if player:
		player.set_multiplayer_authority(peer_id)
		if multiplayer.get_unique_id() == peer_id:
			player.get_node("Camera2D").make_current()
