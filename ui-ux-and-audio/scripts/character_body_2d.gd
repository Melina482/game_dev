extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0

@onready var animated_character_sprite = $AnimatedSprite2D
@onready var run_sfx = $RunSFX
@onready var jump_sfx = $JumpSFX

enum CharacterActions {
	IDLE,
	RUNNING,
	JUMPING
}

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
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

func _on_killzone_body_entered(body: Node2D) -> void:
	if body == self:
		get_tree().reload_current_scene()


func play_animations(direction: float, jump_pressed: bool) -> void:
	# flip user direction
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
	
