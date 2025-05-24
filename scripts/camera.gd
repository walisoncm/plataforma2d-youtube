extends Camera2D

var target: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_target()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = target.position

func get_target():
	var nodes = get_tree().get_nodes_in_group("Player")

	if nodes.size() == 0:
		push_error("No player found in scene!")
		return

	return nodes[0]
