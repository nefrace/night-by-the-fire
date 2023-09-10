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
var attack_direction: Vector3
var shoot_timer: float = 0
var revive_cooldown: float = 0
var swing_ready: bool = true
@export var reload_timer: float = 2;
var ammo: int = 2
@export var is_attacking: bool = false


func update_attack(_delta): 
	if health <= 0:
		return
	if is_attacking:
		return false
	var pbk : AnimationNodeStateMachinePlayback = animtree.get("parameters/playback")
	if Input.is_action_just_pressed("attack_low"):
		pbk.travel("attack-h")
		attack_direction = mouse_direction
	if Input.is_action_just_pressed("attack_high") && swing_ready:
		pbk.travel("attack-v")
		attack_direction = mouse_direction
		swing_ready = false
		await get_tree().create_timer(2).timeout
		swing_ready = true
		%SwingReadyAnim.play("start")


func _process(delta):
	update_attack(delta)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	revive_cooldown = max(revive_cooldown - delta, 0)

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
	var dir = mouse_direction
	if is_attacking:
		dir = attack_direction
	$Sprite3D.scale.x = -1 if dir.x < 0 else 1
	$Sprite3D/WeaponPoint.visible = health > 0
	move_and_slide()


func _on_floor_input_event(_camera, _event, pos, _normal, _shape_idx):
	mouse_direction = (pos - global_position).normalized()
	mouse_direction.y = 0
	
func attack(damage: int, distance: float, penetration: int, effect_scene: PackedScene):
	var s: Node3D = effect_scene.instantiate()
	add_child(s)
	s.rotation.y = -attack_direction.signed_angle_to(Vector3.FORWARD, Vector3.UP)+PI/2
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position + attack_direction*distance, 16)
	query.collide_with_areas = true 
	query.collide_with_bodies = false
	query.exclude = []
	var excludes = []
	var didHit = false
	for i in range(penetration):
		var result := space_state.intersect_ray(query)
		if result:
			var e := result["collider"].get_parent() as BasicEnemy
			if e != null:
				didHit = true
				e.take_damage(damage)
				excludes.push_back(result["collider"].get_rid())
				query.exclude = excludes
	if didHit:
		$HitSound.play()
	
func stab():
	attack(2, 0.8, 1, stab_scene)
	
func swing():
	attack(5, 1.2, 3, swing_scene)
	
func take_damage():
	health -= 1
	if health <= 0:
		revive_cooldown = 0.5
		var diff = (global_position - $"../Campfire".global_position).normalized()
		velocity = Vector3(diff.x, 1, diff.y) * 3
		
	health_changed.emit(health)
	
func on_campfire_died():
	if is_dead:
		return
	$GameOver.play()
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



func _on_pickup_detector_area_entered(area):
	var camp = $"../Campfire"
	if area.name != "camp":
		health = min(6, health + 2)
		health_changed.emit(health)
		$HealthSound.play()
		area.queue_free()
		return
	if health > 0:
		return
	if revive_cooldown > 0:
		return
	health = 3
	camp.health = max(camp.health - 2, 0.5) #dirty hack 
	health_changed.emit(health)
