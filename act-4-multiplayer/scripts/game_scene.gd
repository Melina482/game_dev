extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		ServerClientManager.notify_scene_ready.rpc_id(1, multiplayer.get_unique_id())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
