extends Marker2D

@export var spawn_interval_min: float = 2
@export var spawn_interval_max: float = 3

func _ready() -> void:
	print("ininin")
	spawner_something()

func spawner_something():
	var test = get_parent()
	print(test)
	var finsh_scene = preload("res://scenes/game_scene/begin/green-enemy/enemy_maomaochong_0.tscn")
	var new_fish = finsh_scene.instantiate()
	add_child(new_fish)
	
	get_tree().create_timer(randf_range(spawn_interval_min, spawn_interval_max)).timeout.connect(spawner_something)
