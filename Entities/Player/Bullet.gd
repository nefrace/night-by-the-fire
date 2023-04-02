extends CharacterBody3D

var speed: float = 2.0
var lifetime: float = 3
var direction: Vector3
var poof = preload("res://Entities/SFX/poof.tscn")

func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	var col = move_and_collide(direction * delta * speed)
	if col != null:
		var obj = col.get_collider()
		if obj is Player:
			obj.take_damage()
			obj.velocity += direction * 3 + Vector3.UP*0.8
			var p : Sprite3D = poof.instantiate()
			get_parent().add_child(p)
			p.global_position = global_position
			p.pixel_size = 0.01
			queue_free()
