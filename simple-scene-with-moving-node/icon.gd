extends Sprite2D

func shoot_text(dir: Vector2) -> void:
	var label := Label.new()
	label.text = "HELLO WORLD"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Big font
	label.add_theme_font_size_override("font_size", 48)
	
	label.z_index = -10

	# IMPORTANT: make it world-space
	label.top_level = true

	get_tree().current_scene.add_child(label)

	# Start at icon center
	label.global_position = global_position

	var speed := 600.0
	var lifetime := 2
	var t := 0.0

	while t < lifetime:
		var delta := get_process_delta_time()
		label.global_position += dir * speed * delta
		t += delta
		await get_tree().process_frame

	label.queue_free()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		shoot_text(Vector2.RIGHT)

	if Input.is_action_just_pressed("ui_left"):
		shoot_text(Vector2.LEFT)

	if Input.is_action_just_pressed("ui_up"):
		shoot_text(Vector2.UP)

	if Input.is_action_just_pressed("ui_down"):
		shoot_text(Vector2.DOWN)
