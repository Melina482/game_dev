extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0

@onready var animated_character_sprite = $AnimatedSprite2D
@onready var run_sfx = $RunSFX
@onready var jump_sfx = $JumpSFX

var is_attacking := false

enum CharacterActions {
	IDLE,
	RUNNING,
	JUMPING,
	ATTACK
}

func _ready() -> void:
	animated_character_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Input
	var jump_pressed := Input.is_action_just_pressed("ui_accept")
	var left_click_attack := Input.is_action_just_pressed("left_click")
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# attack
	if left_click_attack and not is_attacking:
		is_attacking = true
		animated_character_sprite.play("attack")
	
	# jump
	if jump_pressed and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
		play_character_sfx(CharacterActions.JUMPING)
		animated_character_sprite.play("jump")
	
	if not is_attacking:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = 0
	
	move_and_slide()
	
	if not is_attacking:
		play_animations(direction)
	
	if direction != 0 and is_on_floor() and not is_attacking:
		if not run_sfx.playing:
			run_sfx.play()
	else:
		run_sfx.stop()


func play_animations(direction: float) -> void:
	
	# Flip character
	if direction > 0:
		animated_character_sprite.flip_h = false
	elif direction < 0:
		animated_character_sprite.flip_h = true
	
	# Air animation
	if not is_on_floor():
		animated_character_sprite.play("jump")
	elif direction == 0:
		animated_character_sprite.play("idle")
	else:
		animated_character_sprite.play("run")


func play_character_sfx(action: CharacterActions) -> void:
	
	if action == CharacterActions.JUMPING:
		jump_sfx.play()


func _on_animation_finished() -> void:
	if animated_character_sprite.animation == "attack":
		is_attacking = false


func _on_killzone_body_entered(body: Node2D) -> void:
	if body == self:
		get_tree().reload_current_scene()
