extends Node2D
@onready var scene_transition_animation_fadeout: AnimationPlayer = $SceneTransitionAnimation/FadeOut/AnimationPlayer
@onready var scene_transition_animation_fadein: AnimationPlayer = $SceneTransitionAnimation/FadeIn/AnimationPlayer
@onready var scene_transition_animation_btwnscn: AnimationPlayer = $SceneTransitionAnimation/BetweenScenes/AnimationPlayer

@onready var player_camera = $player/Camera2D

var current_wave: int
@export var bat_scene: PackedScene
@export var frog_scene: PackedScene

var starting_nodes: int
var current_nodes: int
var wave_spawn_end


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_transition_animation_fadeout.get_parent().get_node("ColorRect").color.a = 255
	print(scene_transition_animation_fadeout.get_parent().get_node("ColorRect").color.a)
	scene_transition_animation_fadeout.play("fade_out")
	player_camera.enabled = true
	Global.playerWeaponEquip = true
	current_wave = 0
	Global.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()

func position_to_next_wave() -> void:
	if current_nodes ==  starting_nodes:
		if current_wave != 0:
			Global.moving_to_next_wave =  true
		wave_spawn_end = false
		scene_transition_animation_btwnscn.play("between_scenes")
		current_wave += 1
		Global.current_wave = current_wave
		await get_tree().create_timer(0.5).timeout
		prepare_spawn("bats", 4.0 , 4.0)
		prepare_spawn("frogs", 1.5 , 2.0)

		print(current_wave)
		

func prepare_spawn(type, multiplier, mob_spawns) -> void :
	var mob_amount = float(current_wave)*multiplier
	var mob_wait_time : float = 2.0
	var mob_spawn_rounds = mob_amount/mob_spawns
	spawn_type(type, mob_spawn_rounds, mob_wait_time)
	
func spawn_type(type, mob_spawn_rounds, mob_wait_time):
	print(type, mob_spawn_rounds, mob_wait_time)
	if type == "bats":
		var bat_spawn1 = $BatSpawnPoint1
		var bat_spawn2 = $BatSpawnPoint2
		var bat_spawn3 = $BatSpawnPoint3
		var bat_spawn4 = $BatSpawnPoint4
		if mob_spawn_rounds >= 1:
			for i in mob_spawn_rounds:
				var bat1 = bat_scene.instantiate()
				bat1.global_position = bat_spawn1.global_position
				var bat2 = bat_scene.instantiate()
				bat2.global_position = bat_spawn2.global_position
				var bat3 = bat_scene.instantiate()
				bat3.global_position = bat_spawn3.global_position
				var bat4 = bat_scene.instantiate()
				bat4.global_position = bat_spawn4.global_position
				add_child(bat1)
				add_child(bat2)
				add_child(bat3)
				add_child(bat4)
				mob_spawn_rounds -=1
				await get_tree().create_timer(mob_wait_time).timeout
	elif type == "frogs":
		var frog_spawn1 = $FrogSpawnPoint1
		var frog_spawn2 = $FrogSpawnPoint2
		print("spawning", frog_spawn1)
		if mob_spawn_rounds >= 1:
			for i in mob_spawn_rounds:
				var frog1 = frog_scene.instantiate()
				frog1.global_position = frog_spawn1.global_position
				var frog2 = frog_scene.instantiate()
				frog2.global_position = frog_spawn2.global_position
				add_child(frog1)
				add_child(frog2)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
		
		wave_spawn_end = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Global.playerAlive:
		Global.gameStarted = false
		scene_transition_animation_fadein.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		update_score()
		get_tree().change_scene_to_file("res://scenes/lobby_level.tscn")
	current_nodes = get_child_count()
	if wave_spawn_end:
		position_to_next_wave()
		
func update_score() -> void:
	Global.previous_score = Global.current_score
	if Global.current_score > Global.high_score:
		Global.high_score = Global.current_score
	Global.current_score = 0
	
