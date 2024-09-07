extends Node2D

@onready var scene_transition_animation_fadeout: AnimationPlayer = $SceneTransitionAnimation/FadeOut/AnimationPlayer
@onready var scene_transition_animation_fadein: AnimationPlayer = $SceneTransitionAnimation/FadeIn/AnimationPlayer
@onready var player_camera = $player/Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_transition_animation_fadeout.play("fade_out")
	player_camera.enabled = false
	Global.playerWeaponEquip = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.gameStarted = true
		scene_transition_animation_fadein.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/stage_level.tscn")
