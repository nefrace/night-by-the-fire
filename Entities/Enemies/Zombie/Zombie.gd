extends BasicEnemy
class_name Zombie

@export var SPEED = 0.4

@onready var animtree : AnimationTree = $AnimationTree

# Get the gravity from the project settings to be synced with RigidBody nodes.
var dir_offset: float = 0
var dir_offset_phase: float = randf() * 5.0
var dir_offset_scale: float = 0.8
var timer: float = 0.0
@export var is_attacking: bool = false

func _ready():
	SPEED = SPEED + randf_range(-0.1, 0.1)
	await get_tree().create_timer(randf()).timeout
	animtree.active = true

func _physics_process(delta):
	var plr : CharacterBody3D = %Player
	timer += delta
	if plr.is_dead:
		return
	dir_offset = sin(timer*2.5 + dir_offset_phase) * dir_offset_scale
	var diff := plr.global_position - global_position
	if diff.length_squared() < 0.1:
		animtree.get("parameters/playback").travel("attack")
	$Sprite3D.flip_h = diff.x < 0
	var direction: Vector3 = diff.normalized().rotated(Vector3.UP, dir_offset)
	if !is_stunned:
		if direction.length_squared() != 0 and !is_attacking:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	
	super._physics_process(delta)

func damage_callback(dmg: int):
	velocity += (global_position - %Player.global_position).normalized() * 2.0 * (dmg / 3.0)
	velocity.y = 1.3
	if health <= 0:
		animtree.active = false
		var tween := get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($Sprite3D, "rotation", Vector3(0, 0, PI/2), 0.3)

func hit_player():
	var plr : CharacterBody3D = %Player
	var diff := plr.global_position - global_position
	if diff.length_squared() < 0.13:
		plr.take_damage()
		plr.velocity += diff.normalized() * 2 + Vector3.UP*0.6
