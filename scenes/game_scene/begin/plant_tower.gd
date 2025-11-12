extends StaticBody2D

@onready var timer = $Timer
@export var health: float = 500
@onready var health_bar = $HealthBar
@onready var growth_manager = $PlantGrowthManager
var bullet_scene = preload("res://scenes/game_scene/begin/bullet-green/greenbullet.tscn")

func _ready():
	health_bar.value = health
	health_bar.max_value = health
	timer.start()
	
	# 连接植物生长管理器的信号
	if growth_manager:
		growth_manager.stage_changed.connect(_on_plant_stage_changed)
		growth_manager.transition_completed.connect(_on_plant_transition_completed)
	
	print("Plant tower initialized with growth manager")

func shoot_bullet():
	# 只有在植物存活时才能射击
	if growth_manager and growth_manager.is_alive():
		var new_bullet = bullet_scene.instantiate()
		# 将子弹添加到父节点（Level1）而不是塔本身
		get_parent().add_child(new_bullet)
		# 设置子弹的初始位置为塔的位置
		new_bullet.global_position = global_position

func _on_timer_timeout():
	shoot_bullet()

func take_damage(damage: float):
	health -= damage
	health_bar.value = health
	
	if health <= 0:
		# 植物死亡
		if growth_manager:
			growth_manager.die()
		else:
			queue_free()

func grow_plant():
	"""让植物进入下一个生长阶段"""
	if growth_manager and growth_manager.can_advance():
		growth_manager.next_stage()

func kill_plant():
	"""直接杀死植物"""
	if growth_manager:
		growth_manager.die()

func get_current_stage():
	"""获取当前植物生长阶段"""
	if growth_manager:
		return growth_manager.current_stage
	return null

func get_stage_name() -> String:
	"""获取当前阶段名称"""
	if growth_manager:
		return growth_manager.get_stage_name(growth_manager.current_stage)
	return "未知"

func _on_plant_stage_changed(old_stage, new_stage):
	"""植物阶段改变时的回调"""
	print("植物从 %s 阶段变为 %s 阶段" % [
		growth_manager.get_stage_name(old_stage),
		growth_manager.get_stage_name(new_stage)
	])
	
	# 根据不同阶段调整植物属性
	match new_stage:
		0: # GERMINATION
			# 发芽阶段 - 基础属性
			timer.wait_time = 2.0
		1: # SEEDLING
			# 幼苗阶段 - 射击稍快
			timer.wait_time = 1.8
		2: # VEGETATIVE
			# 繁茂阶段 - 射击更快
			timer.wait_time = 1.5
		3: # PRE_FLOWERING
			# 花苞阶段 - 射击频率提升
			timer.wait_time = 1.2
		4: # FLOWERING
			# 开花阶段 - 射击很快
			timer.wait_time = 1.0
		5: # FRUITING
			# 结果阶段 - 射击最快
			timer.wait_time = 0.8
		6: # DEATH
			# 死亡阶段 - 停止射击
			timer.stop()

func _on_plant_transition_completed(stage):
	"""植物过渡动画完成时的回调"""
	print("植物过渡到 %s 阶段完成" % growth_manager.get_stage_name(stage))
