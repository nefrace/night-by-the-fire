extends CharacterBody3D
class_name BasicEnemy

signal enemy_dead(type: String)

@export var health: int = 3
@export var damage: int = 1

var type: String
var is_stunned: bool = false
var stun_time: float = 0
var plr: Player


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var poof = preload("res://Entities/SFX/poof.tscn")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func take_damage(dmg: int):
	if is_stunned:
		return
	health -= dmg
	if has_method("damage_callback"):
		call("damage_callback", dmg)
	is_stunned = true
	await get_tree().create_timer(0.4).timeout
	is_stunned = false
	if health <= 0:
		for i in range(3):
			var p := poof.instantiate()
			get_parent().add_child(p)
			p.global_position = global_position + Vector3(randf_range(-0.3, 0.3), randf_range(0.1, 0.3), randf_range(-0.3, 0.3))
		enemy_dead.emit(type)
		queue_free()
