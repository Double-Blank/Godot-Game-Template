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

# 优化后的被植物吸收功能
func absorbed_by_plant(target_node: Node2D):
	if is_absorbed: return
	is_absorbed = true
	
	sun_absorbed_by_plant.emit(self, target_node)
	$CollisionShape2D.set_deferred("disabled", true)
	
	var tween = create_tween()
	# 设置平滑的曲线类型
	tween.set_parallel(true) # 开启并行模式，方便处理复杂的同步动画
	
	# 计算一个中转点（在起始点和终点上方，制造抛物线效果）
	var start_pos = global_position
	var end_pos = target_node.global_position
	var mid_pos = (start_pos + end_pos) / 2 + Vector2(0, -80) # 向上偏移80像素
	
	# 1. 轨迹优化：利用两个阶段模拟抛物线/弧线飞行
	# 第一阶段：飞向中转点（耗时 0.25秒）
	tween.tween_property(self, "global_position", mid_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# 第二阶段：从中转点飞向目标（接在后面执行，耗时 0.35秒）
	tween.chain().tween_property(self, "global_position", end_pos, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# 2. 缩放优化：前 0.3 秒保持大小甚至稍微弹跳，后 0.3 秒才真正缩小
	var zoom_tween = create_tween()
	zoom_tween.tween_property(self, "scale", Vector2.ZERO, 0.45).set_delay(0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# 3. 透明度优化：增加消失感
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.6)
	
	# 4. 结束回调
	tween.chain().tween_callback(func():
		# GameManager.add_sun(sun_value)
		queue_free()
	)

# 普通收集（飞向UI）
func collect_sun():
	if is_absorbed: return
	is_absorbed = true
	emit_signal("sun_collected", sun_value)
	queue_free() # 暂时直接删除，你可以参考上面的Tween写飞向UI的逻辑
