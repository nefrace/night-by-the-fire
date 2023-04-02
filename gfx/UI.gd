extends CanvasLayer


func _on_player_health_changed(health):
	%HealthContainer.set_health(health)
	%AfterlifeEffect.material.set_shader_parameter("is_active", health <= 0)
	%Campfire.is_going_down = health <= 0


func _on_game_over_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")


func _on_campfire_campfire_died():
	%GameOverLabel.visible = true
	%GameOverTimer.start()
