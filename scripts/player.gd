extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var deal_damage_zone: Area2D = $DealDamageZone
@onready var player_hitbox: Area2D = $PlayerHitbox

const SPEED = 200.0
const JUMP_POWER = -350.0

var attack_type:String
var current_attack:bool
var weapon_equipped: bool

var health:int = 100
var health_max:int = 100
var health_min:int = 0
var can_take_damage: bool
var dead:bool

func _ready() -> void:
	Global.playerBody = self
	Global.playerAlive = true
	current_attack = false
	dead = false
	can_take_damage = true
	
func _physics_process(delta: float) -> void:
	weapon_equipped = Global.playerWeaponEquip 
	Global.playerDamageZone = deal_damage_zone
	Global.playerHitbox = player_hitbox
	
	if not is_on_floor():
		velocity += get_gravity() * delta #default is get_gravity()
	
	if !dead:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_POWER
			
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if weapon_equipped and !current_attack:
			if Input.is_action_just_pressed("left_mouse") or Input.is_action_just_pressed("right_mouse"):
				current_attack = true
				if Input.is_action_just_pressed("left_mouse") and is_on_floor():
					attack_type = "single"
				elif Input.is_action_just_pressed("right_mouse") and is_on_floor():
					attack_type = "double"
				else:
					attack_type = "air"
			set_damage(attack_type)
			handle_attack_animations(attack_type)
		handle_movement_animations(direction)
		check_hitbox()
	move_and_slide()

func check_hitbox():
	var hitbox_areas = $PlayerHitbox.get_overlapping_areas()
	var damage: int
	if hitbox_areas:
		var hitbox =  hitbox_areas.front()
		if hitbox.get_parent() is BatEnemy:
			damage = Global.batDamageDealt
	if (can_take_damage and damage != 0):
		take_damage(damage)
		
func take_damage(damage:int)->void:
	if health>0 : 
		health -= damage
		print(health)
		take_damage_cooldown(1.0)
	if health<=0:
		health =0
		dead = true
		Global.playerAlive = false
		handle_death_animation()
	
func handle_death_animation() -> void:
	$CollisionShape2D.position.y =5
	animated_sprite.play("death")
	await get_tree().create_timer(0.5).timeout
	$Camera2D.zoom.x =4
	$Camera2D.zoom.y=4
	await get_tree().create_timer(3.5).timeout
	self.queue_free()
	
func handle_attack_animations(attack_type: String) -> void:
	if weapon_equipped:
		if current_attack:
			var animation = attack_type+"_attack"
			animated_sprite.play(animation)
			toggle_damage_collisions(attack_type)
	
func handle_movement_animations(direction: int) -> void:
	if(!weapon_equipped):
		animated_sprite.play(("run" if velocity else "idle") if is_on_floor() else "fall" )
		toggle_sprite_dir(direction)
	if(weapon_equipped and !current_attack):
		animated_sprite.play(("weapon_run" if velocity else "weapon_idle") if is_on_floor() else "weapon_fall" )
		toggle_sprite_dir(direction)
		
func toggle_damage_collisions(attack_type:String)->void:
	var damage_zone_collision = deal_damage_zone.get_node("CollisionShape2D")
	var wait_time: float
	if attack_type == "air":
		wait_time = 0.63
	if attack_type == "single":
		wait_time = 0.5
	if attack_type == "double":
		wait_time = 0.64
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true
	
func toggle_sprite_dir(direction:int)->void:
	if direction==1:
		animated_sprite.flip_h = false
		deal_damage_zone.scale.x = 1
	if direction==-1:
		animated_sprite.flip_h = true
		deal_damage_zone.scale.x = -1

func set_damage(attack_type: String) -> void:
	var damage_dealt:int
	if attack_type == "single":
		damage_dealt = 8
	elif attack_type == "double":
		damage_dealt = 16
	elif attack_type == "air":
		damage_dealt = 20
	Global.playerDamageDealt = damage_dealt
	
func take_damage_cooldown(wait_time:float) -> void:
	can_take_damage = false
	await get_tree().create_timer(wait_time).timeout
	can_take_damage=true

func _on_animated_sprite_2d_animation_finished() -> void:
	current_attack = false
