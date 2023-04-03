extends Node

signal total_kills_changed(kills: int)

var zombies_max: float = 5.0
var demons_max: float = 0.0
var total_kills: int = 0
var player: Player
@export var zombie: PackedScene
@export var demon: PackedScene

func _ready():
	player = %Player

	
func on_enemy_dead(type: String):
	zombies_max += 0.5
	demons_max += 0.1
	if type == "demon":
		demons_max -= 0.8 # just some small "balance" here lol
	total_kills += 1
	total_kills_changed.emit(total_kills)

func _on_timer_timeout():
	var zombies = get_tree().get_nodes_in_group("zombie")
	var demons = get_tree().get_nodes_in_group("demon")
	if len(zombies) < floor(zombies_max):
		spawn(zombie)
	if len(demons) < floor(demons_max):
		spawn(demon)
	
		
func spawn(enemy: PackedScene):
	var plr: Node3D = %Player
	var spawn_offset = (Vector3.FORWARD * randf_range(2.4, 4.4)).rotated(Vector3.UP, randf()*PI*2)
	var e = enemy.instantiate()
	add_child(e)
	e.plr = player
	e.enemy_dead.connect(on_enemy_dead)
	e.global_position = plr.global_position + spawn_offset
	e.set_owner(owner)
