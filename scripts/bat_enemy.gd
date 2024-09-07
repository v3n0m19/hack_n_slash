extends CharacterBody2D

class_name BatEnemy

const speed = 30
var dir:Vector2 
var is_bat_chase: bool
var player:CharacterBody2D
var health:int = 50
var health_max:int = 50
var health_min: int = 0
var dead: bool = false
var taking_damage: bool = false
var is_roaming: bool
var damage_to_deal:int = 5
var player_hit:bool
var points_for_kill = 100



func _ready() -> void:
	is_bat_chase = true
	player_hit = false

func _physics_process(delta: float) -> void:
	Global.batDamageDealt = damage_to_deal
	Global.batDamageZone = $BatDealDamage
	
	if !Global.playerAlive:
		is_bat_chase = false
	
	if is_on_floor() and dead:
		await get_tree().create_timer(0.5).timeout
		Global.current_score += points_for_kill
		self.queue_free()
	move(delta)
	handle_animations()

func move(delta:float) -> void:
	player = Global.playerBody
	if !dead:
		is_roaming = true
					
		if !taking_damage and is_bat_chase and Global.playerAlive == true and !player_hit:
			velocity = position.direction_to(player.position) * speed
			# basically we are finding the absolute direction (which side of the axis) in x (-1 or 1)
			# can also be done by using the below formula as speed cancels out:
			#position.direction_to(player.position).x / abs(position.direction_to(player.position).x)
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage or player_hit :
			var knockback =  position.direction_to(player.position) *( -20 if player_hit else -50)
			velocity = knockback
			if player_hit:
				is_bat_chase = false
				player_hit = false
				await get_tree().create_timer(1.0).timeout
				is_bat_chase = true
		else:
			velocity += dir*speed*delta
	elif dead:
		velocity.y += 10*delta
		velocity.x = 0
		
	move_and_slide()
	

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5,0.6,0.8,1])
	if !is_bat_chase:
		#dir = choose([Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN,])
		var x = choose([-1,1,0.5,-0.5,0])
		var y = choose([-1,1,0.5,-0.5,0])
		dir = Vector2(x,y)

func handle_animations() -> void:
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	
	var distance = position.distance_to(player.position) if Global.playerAlive == true else 50

	if !dead and !taking_damage and is_bat_chase and distance < 30:
		animated_sprite.play("attack")
		await get_tree().create_timer(0.8).timeout
	elif !dead and !taking_damage:
		animated_sprite.play("fly")
		animated_sprite.flip_h = true if dir.x == -1 else false
	elif !dead and taking_damage:
		animated_sprite.play("hurt")
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming =false
		animated_sprite.play("death")
		set_collision_layer_value(1, true)
		set_collision_layer_value(2, false)
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)
		

	
	
func choose(array):
	array.shuffle()
	return array.front()

func take_damage(damage:int) -> void:
	health -= damage
	taking_damage = true
	if health <= 0:
		health = 0
		dead = true
	
func _on_bat_hit_box_area_entered(area: Area2D) -> void:
	if area == Global.playerDamageZone:
		var damage = Global.playerDamageDealt
		take_damage(damage)


func _on_bat_deal_damage_area_entered(area: Area2D) -> void:
	if area == Global.playerHitbox:
		player_hit = true
