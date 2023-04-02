extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


func _on_back_pressed():
	%HowToPlay.visible = false
	%MainMenu.visible = true


func _on_controls_pressed():
	%HowToPlay.visible = true
	%MainMenu.visible = false
