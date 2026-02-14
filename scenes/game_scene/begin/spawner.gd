extends Marker2D

@export var spawn_interval_min: float = 2
@export var spawn_interval_max: float = 3
@export var items:Array[PackedScene] = []

func _ready() -> void:
	spawner_something()

func spawner_something():
	#var finsh_scene = preload("res://scenes/game_scene/begin/enemy/enemy_maomaochong_0.tscn")
	var finsh_scene = items.pick_random()
	
	var new_fish = finsh_scene.instantiate()
	add_child(new_fish)
	
	get_tree().create_timer(randf_range(spawn_interval_min, spawn_interval_max)).timeout.connect(spawner_something)
