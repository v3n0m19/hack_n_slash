extends CharacterBody2D

const speed = 30
var dir:Vector2 
var is_bat_chase: bool
var player:CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	is_bat_chase = true

func _physics_process(delta: float) -> void:
	move(delta)
	handle_animations()

func move(delta:float) -> void:
	if is_bat_chase:
		player = Global.playerBody
		velocity = position.direction_to(player.position) * speed
		# basically we are finding the absolute direction (which side of the axis) in x (-1 or 1)
		# can also be done by using the below formula as speed cancels out:
		#position.direction_to(player.position).x / abs(position.direction_to(player.position).x)
		dir.x = abs(velocity.x) / velocity.x
		
		
	elif !is_bat_chase:
		velocity += dir*speed*delta
	move_and_slide()
	

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5,0.6,0.8,1])
	if !is_bat_chase:
		#dir = choose([Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN,])
		var x = choose([-1,1,0.5,-0.5,0])
		var y = choose([-1,1,0.5,-0.5,0])
		dir = Vector2(x,y)
		print(dir)

func handle_animations() -> void:
	animated_sprite.play("fly")
	animated_sprite.flip_h = true if dir.x == -1 else false

func choose(array):
	array.shuffle()
	return array.front()
