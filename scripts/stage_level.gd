extends Node2D
@onready var scene_transition_animation_fadeout: AnimationPlayer = $SceneTransitionAnimation/FadeOut/AnimationPlayer
@onready var scene_transition_animation_fadein: AnimationPlayer = $SceneTransitionAnimation/FadeIn/AnimationPlayer
@onready var player_camera = $player/Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_transition_animation_fadeout.get_parent().get_node("ColorRect").color.a = 255
	print(scene_transition_animation_fadeout.get_parent().get_node("ColorRect").color.a)
	scene_transition_animation_fadeout.play("fade_out")
	player_camera.enabled = true
	Global.playerWeaponEquip = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Global.playerAlive:
		Global.gameStarted = false
		scene_transition_animation_fadein.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/lobby_level.tscn")
