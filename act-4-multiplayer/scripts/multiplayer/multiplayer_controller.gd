extends CharacterBody2D

@onready var animated_character_sprite = $AnimatedSprite2D
@onready var run_sfx = $RunSFX
@onready var jump_sfx = $JumpSFX

const SPEED = 100.0
const JUMP_VELOCITY = -300.0

enum CharacterActions {
	IDLE,
	RUNNING,
	JUMPING
}

@export var player_id := 1:
	set(id):
		player_id = id
		if not is_inside_tree():
			await ready
		set_multiplayer_authority(player_id)
		if multiplayer.get_unique_id() == player_id:
			$Camera2D.make_current()
		else:
			$Camera2D.enabled = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var jump_pressed := Input.is_action_just_pressed("ui_accept")
	if jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY
		play_character_sfx(CharacterActions.JUMPING)
		
	var direction := Input.get_axis("ui_left", "ui_right")
	play_animations(direction, jump_pressed)
	
	if direction != 0 and is_on_floor():
		play_character_sfx(CharacterActions.RUNNING)
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	# broadcast player input to all peers for every frame
	sync_state.rpc(position, velocity, animated_character_sprite.animation, animated_character_sprite.flip_h)

@rpc("any_peer", "unreliable_ordered")
func sync_state(new_position: Vector2, new_velocity: Vector2, new_animation: String, new_flip: bool):
	if not is_multiplayer_authority():
		position = new_position
		velocity = new_velocity
		animated_character_sprite.animation = new_animation
		animated_character_sprite.flip_h = new_flip

func _on_killzone_body_entered(body: Node2D) -> void:
	if body == self:
		get_tree().reload_current_scene()

func play_animations(direction: float, jump_pressed: bool) -> void:
	if direction > 0:
		animated_character_sprite.flip_h = false
	elif direction < 0:
		animated_character_sprite.flip_h = true
		
	if direction == 0:
		animated_character_sprite.play("idle")
	elif jump_pressed and is_on_floor():
		animated_character_sprite.play("jump")
	else:
		animated_character_sprite.play("run")
		
func play_character_sfx(action: CharacterActions) -> void:
	if action == CharacterActions.RUNNING:
		if not run_sfx.playing:
			run_sfx.play()
	elif action == CharacterActions.JUMPING:
		jump_sfx.play()
	
func _on_game_end_zone_body_entered(body: Node2D) -> void:
	if body == self:
		print("End")
