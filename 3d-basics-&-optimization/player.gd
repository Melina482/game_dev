extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.01

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	
	# Release mouse
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Capture mouse again
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			
			# Rotate player left/right
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			
			# Look up/down
			neck.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			
			# Limit vertical look
			neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-60), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement input
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
