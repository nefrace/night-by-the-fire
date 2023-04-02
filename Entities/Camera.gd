extends Camera3D

@export var point_path: NodePath
var point: Node3D
var target_offset: Vector3
#@onready var point: Node3D = get_parent_node_3d()
# Called when the node enters the scene tree for the first time.
func _ready():
	point = get_node(point_path)
	target_offset = global_position - point.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	look_at(%Player.position)
	var target = point.global_position + target_offset
	global_position = global_position.lerp(target, 0.1)
