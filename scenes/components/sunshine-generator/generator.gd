extends Node2D
class_name Generator
@onready var spawn_timer: Timer = $SpawnTimer
@export var sun_scene: PackedScene # 在编辑器里把 Sun.tscn 拖进去
@export var spawn_area_rect: Rect2 # 定义阳光生成的X轴范围

@export_range(0.0, 100.0) var min_time: float = 2.1
@export_range(0.0, 100.0) var max_time: float = 8.2

# 阳光生成
signal sun_spawned

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	# 也可以在代码里定义生成范围，比如屏幕宽度 1152
	if spawn_area_rect.size == Vector2.ZERO:
		spawn_area_rect = Rect2(50, 50, 1000, 0) # x:50-1050, y:50(屏幕下方)

func _on_spawn_timer_timeout():
	spawn_sun()
	# 随机化下一次生成时间，让游戏不那么死板
	spawn_timer.wait_time = randf_range(min_time, max_time)

func spawn_sun():
	if sun_scene == null:
		return
		
	var sun_instance = sun_scene.instantiate()
	
	# 随机 X 位置
	var random_x = randf_range(spawn_area_rect.position.x, spawn_area_rect.end.x)
	var start_y = spawn_area_rect.position.y
	
	sun_instance.position = Vector2(random_x, start_y)
	
	# 将阳光添加到场景中（通常添加到当前场景的根节点，或者专门的 'Projectiles' 层）
	get_parent().add_child(sun_instance)
