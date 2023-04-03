extends StaticBody3D
class_name Campfire

signal campfire_died

var is_going_down: bool = false
var is_dead: bool = false
var health: float = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if is_dead:
		return
	if is_going_down:
		health -= delta
		if health <= 0:
			health = 0
			is_dead = true
			$AnimationPlayer.play("Idle")
			$GPUParticles3D.emitting = false
			campfire_died.emit()
	else:
		health = min(health + delta / 10, 5)
	$Light.pixel_size = remap(health, 0, 5, 0.003, 0.03)
