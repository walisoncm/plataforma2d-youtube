extends Area2D

@export var next_level: PackedScene = null

func _on_body_entered(_body: Node2D) -> void:
	call_deferred("load_next_level")

func load_next_level():
	get_tree().change_scene_to_packed(next_level)
