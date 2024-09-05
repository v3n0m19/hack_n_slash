extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 200.0
const JUMP_POWER = -350.0


func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta #default is get_gravity()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_POWER

 
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	handle_movement_direction(direction)
	
func handle_movement_direction(direction: int) -> void:
	var weapon_equipped: bool = Global.playerWeaponEquip 
	if(!weapon_equipped):
		animated_sprite.play(("run" if velocity else "idle") if is_on_floor() else "fall" )
		toggle_sprite_dir(direction)
	if(weapon_equipped):
		animated_sprite.play(("weapon_run" if velocity else "weapon_idle") if is_on_floor() else "weapon_fall" )
		toggle_sprite_dir(direction)
		

func toggle_sprite_dir(direction)->void:
	if direction==1:
		animated_sprite.flip_h = false
	if direction==-1:
		animated_sprite.flip_h = true
