extends BasicEnemy
class_name Demon


@onready var animtree : AnimationTree = $AnimationTree
var bullet = preload("res://Entities/Enemies/Demon/Demonball.tscn")
var heart = preload("res://Entities/Environment/HeartPickup/Heart.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var dir_offset: float = 0
var dir_offset_phase: float = randf() * 5.0
var dir_offset_scale: float = 0.8
var timer: float = 0.0
var teleport_time: float = 3.0
var teleport_count: int = 0
var attack_count: int = 0
var attack_now: bool = false
@export var is_attacking: bool = false
@export var is_teleporting: bool = false

func _ready():
	type = "demon"
	await get_tree().create_timer(randf()).timeout
	animtree.active = true
	teleport_time = randf_range(3, 5)

func _process(delta):
	timer += delta
	$Sprite3D.offset.y = 17 + sin(timer * 2) * 2

func _physics_process(delta):
	if !is_teleporting && !is_attacking:
		teleport_time -= delta
		if teleport_time <= 0:
			var pb: AnimationNodeStateMachinePlayback = animtree.get("parameters/playback")
			if !attack_now:				
				pb.travel("teleport_out")
				if attack_count == 3:
					attack_count = 0
			else:
				pb.travel("attack")
				attack_now = false
				attack_count += 1
	var diff := plr.global_position - global_position
	$Sprite3D.flip_h = diff.x < 0

	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 5.0 * delta)
		velocity.z = move_toward(velocity.z, 0, 5.0 * delta)
	set_collision_layer_value(2, !is_teleporting)
	super._physics_process(delta)

func damage_callback(dmg: int):
	velocity += (global_position - %Player.global_position).normalized() * 2.0 * (dmg / 3.0)
	velocity.y = 1.3
	if health <= 0:
		var h = heart.instantiate()
		get_parent().add_child(h)
		h.global_position = global_position
#		h.global_position.y = 0
		animtree.active = false
		var tween := get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($Sprite3D, "rotation", Vector3(0, 0, PI/2), 0.3)

func teleport():
	var offset := (Vector3.FORWARD * randf_range(1.3, 2.5)).rotated(Vector3.UP, randf()*PI*2)
	global_position = plr.global_position + offset
	teleport_time = randf_range(1, 2)
	teleport_count += 1
	if teleport_count == 3:
		teleport_time = 0.4
		attack_now = true
		teleport_count = 0

func single_shot():
	var b := bullet.instantiate()
	add_child(b)
	b.global_position = global_position + Vector3.UP * 0.1
	var dir = (plr.global_position - global_position).normalized()
	dir.y = 0
	b.direction = dir

func multi_shot():
	for i in range(-1, 2):
		var b := bullet.instantiate()
		add_child(b)
		b.global_position = global_position + Vector3.UP * 0.1
		var dir = (plr.global_position - global_position).normalized()
		dir.y = 0
		b.direction = dir.rotated(Vector3.UP, i)
		
func attack():
	$AttackSound.play()
	if attack_count == 3:
		multi_shot()
	else:
		single_shot()
