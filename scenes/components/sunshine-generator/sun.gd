extends Area2D

class_name SunDrop

# 信号：当阳光被收集或吸收时发出，通知UI更新
signal sun_collected(amount)
signal sun_absorbed_by_plant(sun_instance, plant_instance)

# 属性
var fall_speed: float = 100.0
var target_y: float = 0.0 # 阳光下落的目标高度
var sun_value: int = 25
var is_falling: bool = true
var is_absorbed: bool = false # 防止被重复吸收

func _ready():
	# 1. 将阳光加入 "suns" 组，这是关键！
	# 以后植物可以通过 get_tree().get_nodes_in_group("suns") 找到所有阳光
	add_to_group("suns")
	
	# 2. 随机设置一个停止高度 (类似PvZ，阳光不会一直掉到底)
	# 假设屏幕高度是 600，我们在 200 到 550 之间随机停止
	target_y = randf_range(200.0, 550.0)
	
	# 连接输入事件（如果你允许玩家点击收集）
	input_event.connect(_on_input_event)

func _process(delta):
	if is_absorbed:
		return # 如果正在被吸收，停止下落逻辑，交给Tween处理

	if is_falling:
		position.y += fall_speed * delta
		if position.y >= target_y:
			position.y = target_y
			is_falling = false
			# 这里可以加一个简单的上下浮动动画，让它看起来更生动

# 处理玩家点击（如果游戏允许玩家手动点）
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		fly_to_nearest_plant()

# 飞向最近的植物
func fly_to_nearest_plant():
	if is_absorbed: return
	
	# 查找场景中所有的植物
	var plants = get_tree().get_nodes_in_group("plants")
	
	if plants.is_empty():
		# 如果没有植物，执行普通收集
		collect_sun()
		return
	
	# 找到最近的植物
	var nearest_plant = null
	var nearest_distance = INF
	
	for plant in plants:
		if plant is TomatoStageManager:
			var distance = global_position.distance_to(plant.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_plant = plant
	
	if nearest_plant:
		# 飞向最近的植物并被吸收
		absorbed_by_plant(nearest_plant)
	else:
		# 如果没找到合适的植物，执行普通收集
		collect_sun()

# 核心功能：被植物吸收
# target_position: 植物的位置
func absorbed_by_plant(target_node: Node2D):
	if is_absorbed: return
	is_absorbed = true
	
	# 发出信号，通知主场景阳光被植物吸收了
	sun_absorbed_by_plant.emit(self, target_node)
	
	# 移除碰撞，防止被其他植物再次选中
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 使用 Tween 制作飞向植物的动画
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	# 1. 飞向植物位置
	tween.tween_property(self, "global_position", target_node.global_position, 0.5)
	# 2. 同时缩小（模拟被吃掉）
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.5)
	
	# 3. 动画结束后销毁并增加资源
	tween.tween_callback(func():
		# 这里可以调用全局单例增加阳光数值
		# GameManager.add_sun(sun_value) 
		queue_free()
	)

# 普通收集（飞向UI）
func collect_sun():
	if is_absorbed: return
	is_absorbed = true
	emit_signal("sun_collected", sun_value)
	queue_free() # 暂时直接删除，你可以参考上面的Tween写飞向UI的逻辑
