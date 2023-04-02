extends CharacterBody3D
class_name Player

signal health_changed(health: int)

const SPEED = 2.0
const JUMP_VELOCITY = 3.5

@onready var animtree : AnimationTree = $AnimationTree
var bullet_scene = preload("res://Entities/Player/Bullet.tscn")
var swing_scene = preload("res://Entities/SFX/swing.tscn")
var stab_scene = preload("res://Entities/SFX/stab.tscn")
var poof = preload("res://Entities/SFX/poof.tscn")
var health: int = 6
var is_dead: bool = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_direction: Vector3
var shoot_timer: float = 0
@export var reload_timer: float = 2;
var ammo: int = 2
@export var is_attacking: bool = false


func update_attack(delta): 
	if health <= 0:
		return
	var pbk : AnimationNodeStateMachinePlayback = animtree.get("parameters/playback")
	if Input.is_action_just_pressed("attack_low"):
		pbk.travel("attack-h")
	if Input.is_action_just_pressed("attack_high"):
		pbk.travel("attack-v")


func _process(delta):
	update_attack(delta)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
#	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_attacking:
#		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if !is_dead && direction && !is_attacking:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, 20 * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, 20 * delta)
		animtree.set("parameters/conditions/is_idle", false)
		animtree.set("parameters/conditions/is_running", true)
	else:
		velocity.x = move_toward(velocity.x, 0, 10 * delta)
		velocity.z = move_toward(velocity.z, 0, 10 * delta)
		animtree.set("parameters/conditions/is_idle", true)
		animtree.set("parameters/conditions/is_running", false)
	$Sprite3D.scale.x = -1 if mouse_direction.x < 0 else 1
	$Sprite3D/WeaponPoint.visible = health > 0
	move_and_slide()


func _on_floor_input_event(camera, event, position, normal, shape_idx):
	mouse_direction = (position - global_position).normalized()
	mouse_direction.y = 0
	
func attack(damage: int, distance: float, penetration: int, effect_scene: PackedScene):
	var s: Node3D = effect_scene.instantiate()
	add_child(s)
	s.rotation.y = -mouse_direction.signed_angle_to(Vector3.FORWARD, Vector3.UP)+PI/2
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position + mouse_direction*distance, 2)
	query.exclude = []
	var excludes = []
	for i in range(penetration):
		var result := space_state.intersect_ray(query)
		if result:
			(result["collider"] as BasicEnemy).take_damage(damage)
			excludes.push_back(result["collider"].get_rid())
			query.exclude = excludes
	
func stab():
	attack(1, 0.5, 1, stab_scene)
	
func swing():
	attack(3, 1, 3, swing_scene)
	
func take_damage():
	health -= 1
	health_changed.emit(health)
	
func on_campfire_died():
	if is_dead:
		return
	is_dead = true
	collision_layer = 1
	animtree.active = false
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite3D, "rotation", Vector3(0, 0, PI/2), 1)
	await tween.finished
	visible = false
	for i in range(5):
		var p := poof.instantiate()
		get_parent().add_child(p)
		p.global_position = global_position + Vector3(randf_range(-0.3, 0.3), randf_range(0.1, 0.3), randf_range(-0.3, 0.3))



func _on_campfire_detector_area_entered(area):
	if health == 0:
		health = 3
	health_changed.emit(health)
