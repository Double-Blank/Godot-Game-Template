extends Node2D
class_name TomatoStageManager

# 番茄生长阶段枚举
enum GrowthStage {
	STAGE_1,  # 种子/幼苗
	STAGE_2,  # 小苗
	STAGE_3,  # 成长期
	STAGE_4,  # 开花期
	STAGE_5,  # 结果期
	STAGE_6   # 成熟期
}

# 信号
signal stage_changed(new_stage: GrowthStage)
signal growth_completed()
signal plant_died()  # 新增：植物死亡信号

# 导出变量
@export var auto_grow: bool = false
@export var growth_interval: float = 2.0  # 自动生长间隔（秒）
@export var current_stage: GrowthStage = GrowthStage.STAGE_1 : set = set_current_stage
@export var max_health: float = 100
@export var current_health: float = 100 : set = set_current_health  # 添加setter
@export var death_animation_duration: float = 1.0  # 死亡动画持续时间

# 内部变量
var spine_sprite: SpineSprite
var growth_timer: Timer
var frute_init: Array[Vector2] = [
	Vector2(-20.35, -25.3),
	Vector2(-14.35, -25.3),
	Vector2(-4.35, -25.3),
	Vector2(9.65, -25.3),
	Vector2(21.65, -25.3),
	Vector2(27.65, -25.3)
]

var is_dead: bool = false  # 标记植物是否已死亡

# 动画名称映射
var stage_animations = {
	GrowthStage.STAGE_1: "stage1",
	GrowthStage.STAGE_2: "stage2", 
	GrowthStage.STAGE_3: "stage3",
	GrowthStage.STAGE_4: "stage4",
	GrowthStage.STAGE_5: "stage5",
	GrowthStage.STAGE_6: "stage6"
}

func _ready():
	# 将植物加入"plants"组，让阳光能够找到它
	add_to_group("plants")
	
	# 查找SpineSprite节点
	spine_sprite = find_child("SpineSprite", true, false)
	if not spine_sprite:
		# 如果没找到，尝试查找父节点或子节点中的SpineSprite
		spine_sprite = get_parent().find_child("SpineSprite", true, false)
	
	if not spine_sprite:
		push_error("TomatoStageManager: 未找到SpineSprite节点")
		return
	
	# 设置初始动画
	update_animation()
	
	# 如果启用自动生长，创建定时器
	if auto_grow:
		setup_auto_growth()

func set_current_health(new_health: float):
	"""设置当前生命值"""
	if is_dead:
		return
		
	current_health = clamp(new_health, 0, max_health)
	
	# 检查生命值是否归零
	if current_health <= 0:
		die()

func setup_auto_growth():
	"""设置自动生长定时器"""
	if is_dead:
		return
		
	growth_timer = Timer.new()
	growth_timer.wait_time = growth_interval
	growth_timer.timeout.connect(_on_growth_timer_timeout)
	add_child(growth_timer)
	growth_timer.start()

func _on_growth_timer_timeout():
	"""自动生长定时器回调"""
	if not is_dead:
		grow_to_next_stage()

func set_current_stage(new_stage: GrowthStage):
	"""设置当前生长阶段"""
	if is_dead:
		return
		
	if new_stage != current_stage:
		current_stage = new_stage
		update_animation()
		stage_changed.emit(current_stage)
		
		# 检查是否完成所有生长阶段
		if current_stage == GrowthStage.STAGE_6:
			growth_completed.emit()
			if growth_timer:
				growth_timer.stop()

func update_animation():
	"""更新Spine动画"""
	if not spine_sprite or is_dead:
		return
		
	var animation_name = stage_animations.get(current_stage, "stage1")
	
	# 播放对应阶段的动画
	spine_sprite.get_animation_state().set_animation(animation_name, false, 0)
	
	print("番茄生长到阶段: ", current_stage, " 播放动画: ", animation_name)

func die():
	"""植物死亡处理"""
	if is_dead:
		return
		
	is_dead = true
	
	# 发送死亡信号
	plant_died.emit()
	
	# 停止所有计时器
	if growth_timer:
		growth_timer.stop()
	
	# 播放死亡动画
	play_death_animation()

func play_death_animation():
	"""播放死亡动画：旋转并淡出"""
	# 创建Tween动画
	var tween = create_tween()
	tween.set_parallel(true)  # 并行执行所有动画
	
	# 旋转90度（向左倒）
	tween.tween_property(self, "rotation_degrees", -90.0, death_animation_duration)
	
	# 淡出效果
	var all_sprites = get_tree().get_nodes_in_group("plant_sprites")  # 可能需要给相关节点添加分组
	if all_sprites.is_empty():
		# 如果没找到分组，就淡出整个节点
		tween.tween_property(self, "modulate:a", 0.0, death_animation_duration)
	else:
		# 淡出所有精灵
		for sprite in all_sprites:
			tween.tween_property(sprite, "modulate:a", 0.0, death_animation_duration)
	
	# 动画完成后销毁
	tween.finished.connect(_on_death_animation_finished)

func _on_death_animation_finished():
	"""死亡动画完成后的处理"""
	print("植物已死亡，正在销毁...")
	queue_free()

func take_damage(damage: float):
	"""植物受到伤害"""
	if is_dead:
		return
		
	current_health -= damage
	print("植物受到伤害: ", damage, " 剩余生命: ", current_health)
	
	# 可以在这里添加受伤动画效果
	if not is_dead:
		# 短暂闪烁红色表示受伤
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func grow_to_next_stage():
	"""生长到下一个阶段"""
	if current_stage < GrowthStage.STAGE_6 and not is_dead:
		set_current_stage(current_stage + 1)
		return true
	return false

func grow_to_stage(target_stage: GrowthStage):
	"""直接生长到指定阶段"""
	if target_stage >= GrowthStage.STAGE_1 and target_stage <= GrowthStage.STAGE_6 and not is_dead:
		set_current_stage(target_stage)
		return true
	return false

func reset_to_stage_1():
	"""重置到第一阶段"""
	if is_dead:
		return
		
	set_current_stage(GrowthStage.STAGE_1)
	current_health = max_health
	is_dead = false
	
	# 恢复显示
	self.modulate = Color.WHITE
	self.rotation_degrees = 0
	
	if growth_timer:
		growth_timer.start()

func get_stage_name() -> String:
	"""获取当前阶段名称"""
	match current_stage:
		GrowthStage.STAGE_1:
			return "种子期"
		GrowthStage.STAGE_2:
			return "幼苗期"
		GrowthStage.STAGE_3:
			return "成长期"
		GrowthStage.STAGE_4:
			return "开花期"
		GrowthStage.STAGE_5:
			return "结果期"
		GrowthStage.STAGE_6:
			return "成熟期"
		_:
			return "未知阶段"

func get_progress_percentage() -> float:
	"""获取生长进度百分比"""
	return (current_stage + 1) / 6.0 * 100.0

func is_fully_grown() -> bool:
	"""检查是否完全成熟"""
	return current_stage == GrowthStage.STAGE_6

func can_harvest() -> bool:
	"""检查是否可以收获"""
	return current_stage == GrowthStage.STAGE_6

# 调试用的手动控制函数
func _input(event):
	if not Engine.is_editor_hint():
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				grow_to_stage(GrowthStage.STAGE_1)
			KEY_2:
				grow_to_stage(GrowthStage.STAGE_2)
			KEY_3:
				grow_to_stage(GrowthStage.STAGE_3)
			KEY_4:
				grow_to_stage(GrowthStage.STAGE_4)
			KEY_5:
				grow_to_stage(GrowthStage.STAGE_5)
			KEY_6:
				grow_to_stage(GrowthStage.STAGE_6)
			KEY_SPACE:
				grow_to_next_stage()
			KEY_R:
				reset_to_stage_1()
			KEY_D:  # 新增：测试死亡效果
				take_damage(100)  # 直接造成100伤害

func drop():
	if is_dead:
		return
		
	set_current_stage(GrowthStage.STAGE_5)
	var drop_sprite2d_array: Array[Sprite2D] = []
	var children = get_node("frute_group").get_children()
	var index = 0
	for child in children:
		if child is Sprite2D:
			child.visible = true
			drop_sprite2d_array.append(child)
			child.position = frute_init[index]
		index += 1
	# 创建 Tween
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)  # 缓出效果，模拟重力加速度
	tween.set_trans(Tween.TRANS_QUAD)  # 二次曲线，更像自由落体
	
	for test in drop_sprite2d_array:
		# 记录初始位置
		var test_start_position = test.position
		var test_end_position = test_start_position + Vector2(0, 22)
		# 设置动画
		tween.tween_property(test, "position", test_end_position, 0.3)
	
func collect():
	if is_dead:
		return
		
	var drop_sprite2d_array: Array[Sprite2D] = []
	var children = get_node("frute_group").get_children()
	for child in children:
		if child is Sprite2D:
			drop_sprite2d_array.append(child)
	
	var end_position = Vector2(0, 0)
	# 创建 Tween 动画
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)  # 缓入效果，开始慢，结束快
	tween.set_trans(Tween.TRANS_QUAD)
	
	for test in drop_sprite2d_array:
		# 移动到左上角 (0,0)
		tween.tween_property(test, "global_position", end_position, 0.5)
		tween.finished.connect(func(): test.visible = false)
	
