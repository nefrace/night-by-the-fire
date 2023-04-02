extends MeshInstance3D

var grass = preload("res://Entities/Environment/Grass/Grass.tscn")
var rocks = preload("res://Entities/Environment/Rock/Rock.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(500):
		var g : Sprite3D = grass.instantiate()
		add_child(g)
		g.global_position.x = randf_range(-20.0, 20.0)
		g.global_position.z = randf_range(-20.0, 20.0)
	for i in range(100):
		var r : Sprite3D = rocks.instantiate()
		add_child(r)
		r.global_position.x = randf_range(-20.0, 20.0)
		r.global_position.z = randf_range(-20.0, 20.0)
