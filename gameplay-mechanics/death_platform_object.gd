extends StaticBody2D

func _on_body_entered(body):
	if body is CharacterBody2D:
		get_tree().reload_current_scene()
