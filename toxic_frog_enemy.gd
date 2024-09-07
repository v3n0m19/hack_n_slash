extends CharacterBody2D

class_name FrogEnemy

const speed = 30
var health = 80
const health_max = 80
const health_min = 0

var is_frog_chase: bool = true
var dead: bool = false
var taking_damage: bool = false
var damage_to_deal:int  = 20
var is_dealing_damage:bool =  false

var dir: Vector2
var knockback_force = -50
var is_roaming:bool = true

var player : CharacterBody2D
var player_in_area: bool = false


func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += get_gravity().y * delta
		velocity.x = 0
		
	if !Global.playerAlive:
		is_frog_chase = false
		
	player = Global.playerBody
	Global.frogDamageZone = $FrogDealDamage
	Global.frogDamageDealt = damage_to_deal
	
	move(delta)
	move_and_slide()
	handle_animations()
	
func move(delta: float) -> void:
	if !dead:
		if !is_frog_chase:
			velocity += dir*speed*delta
		elif is_frog_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x =  abs(velocity.x)/velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
			
			
	elif dead:
		velocity.x = 0

func handle_animations() -> void :
	var animated_sprite  = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		animated_sprite.play("walk")
		animated_sprite.flip_h = false if dir.x == 1 else true
	elif !dead and taking_damage and !is_dealing_damage:
		animated_sprite.play("hurt")
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		animated_sprite.play("death")
		await get_tree().create_timer(1.0).timeout
		handle_death()
	elif !dead and is_dealing_damage:
		animated_sprite.play("deal_damage")
		
func handle_death()-> void:
	self.queue_free()
	
func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_frog_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x=0
	
func choose(array: Array) :
	array.shuffle()
	return array.front()

func take_damage( damage : int )-> void:
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
		
	
func _on_frog_hitbox_area_entered(area: Area2D) -> void:
	var damage =  Global.playerDamageDealt
	if area == Global.playerDamageZone:
		take_damage(damage)


func _on_frog_deal_damage_area_entered(area: Area2D) -> void:
	if area == Global.playerHitbox:
		is_dealing_damage = true
		await get_tree().create_timer(1.0).timeout
		is_dealing_damage = false
