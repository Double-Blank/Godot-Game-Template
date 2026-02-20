extends Node2D

## 敌人生成器
## 支持配置生成范围、时间间隔，并可拖入不同的敌人场景（如 maomao 或 Sun）

@export var enemy_scenes: Array[PackedScene] = [] ## 支持多种敌人随机生成
@export var spawn_zone: Area2D ## 拖入一个 Area2D 节点:
	# set(value):
	# 	spawn_area = value
	# 	queue_redraw() # 关键：告诉引擎重新调用 _draw() 默认在屏幕右侧边缘生成
@export var min_interval: float = 3.0 ## 最小生成间隔
@export var max_interval: float = 7.0 ## 最大生成间隔
@export var auto_start: bool = true

## 敌人缩放范围
@export var min_scale: float = 0.20
@export var max_scale: float = 0.21

@onready var timer: Timer = $Timer

func _ready() -> void:
	if timer == null:
		_create_timer()
	
	timer.timeout.connect(_on_timer_timeout)
	
	if auto_start:
		start_spawning()

func _create_timer() -> void:
	var new_timer = Timer.new()
	new_timer.name = "Timer"
	new_timer.one_shot = false # 确保它不是只运行一次
	add_child(new_timer)
	timer = new_timer

func start_spawning() -> void:
	_update_timer()
	timer.start()

func stop_spawning() -> void:
	timer.stop()

func _update_timer() -> void:
	timer.wait_time = randf_range(min_interval, max_interval)

func _on_timer_timeout() -> void:
	spawn_enemy()
	_update_timer()

func spawn_enemy() -> void:
	if spawn_zone == null:
			push_error("未指定生成区域！")
			return

	# 获取 Area2D 下第一个 CollisionShape2D 的形状
	var collision_shape = spawn_zone.get_node("CollisionShape2D")
	if not collision_shape or not collision_shape.shape is RectangleShape2D:
			push_error("Area2D 必须包含一个 RectangleShape2D 子节点")
			return

	var rect_shape = collision_shape.shape as RectangleShape2D
	var size = rect_shape.size
	
	# 基于 CollisionShape 的 global_position 计算随机点
	var center = collision_shape.global_position
	
	if enemy_scenes.is_empty():
		push_warning("EnemyGenerator: No enemy scenes assigned!")
		return
	
	# 随机选择一个场景
	var scene_to_spawn = enemy_scenes.pick_random()
	if scene_to_spawn == null:
		return
		
	var enemy_instance = scene_to_spawn.instantiate()
	# --- 新增：控制大小 ---
	var random_s = randf_range(min_scale, max_scale)
	enemy_instance.scale = Vector2(random_s, random_s)
	
	# 在范围内随机计算位置
	var spawn_pos = Vector2(
			randf_range(center.x - size.x / 2, center.x + size.x / 2),
			randf_range(center.y - size.y / 2, center.y + size.y / 2)
	)
	enemy_instance.global_position = spawn_pos
	
	# 添加到场景中，优先尝试添加到当前场景根节点或父节点
	var spawn_root = get_tree().current_scene
	if spawn_root:
		spawn_root.add_child(enemy_instance)
	else:
		get_parent().add_child(enemy_instance)
