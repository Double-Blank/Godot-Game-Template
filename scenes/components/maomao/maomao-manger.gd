extends Node2D
class_name Maomao

# 毛毛虫动画枚举
enum MaoMaoStage {
	STAGE_1,  # 种子/幼苗
	STAGE_2,  # 小苗
	STAGE_3,  # 成长期
}

# 动画名称映射
var stage_animations = {
	MaoMaoStage.STAGE_1: "walk",
	MaoMaoStage.STAGE_2: "attack", 
	MaoMaoStage.STAGE_3: "death",
}

@export var current_stage: MaoMaoStage = MaoMaoStage.STAGE_1 : set = set_current_stage

# 移动相关变量
@export var move_speed: float = 50.0  # 移动速度
@export var detection_range: float = 5000.0  # 检测范围

# 生命值相关变量
@export var max_health: float = 100.0  # 最大生命值
@export var current_health: float = 100.0 : set = set_current_health  # 当前生命值
@export var health_regeneration: float = 0.0  # 生命值回复速度（每秒）

# 内部变量
var spine_sprite: SpineSprite
var target_plant: Node2D = null
var is_moving: bool = false
var is_dead: bool = false
var is_in_attack_area: bool = false

# 信号
signal health_changed(new_health: float, max_health: float)
signal died()
signal health_depleted()

func _ready():
	# 加入"Enemy"组，能够找到它
	add_to_group("enemy")
	
	# 查找SpineSprite节点
	spine_sprite = find_child("SpineSprite", true, false)
	if not spine_sprite:
		# 如果没找到，尝试查找父节点或子节点中的SpineSprite
		spine_sprite = get_parent().find_child("SpineSprite", true, false)
	
	if not spine_sprite:
		push_error("TomatoStageManager: 未找到SpineSprite节点")
		return
	
	# 连接Area2D信号
	var area = $Area2D
	if area:
		area.area_entered.connect(_on_area_2d_area_entered)
		area.area_exited.connect(_on_area_2d_area_exited)
	
	# 初始化生命值
	current_health = max_health
	
	# 设置初始动画
	update_animation()

func _process(delta):
	"""每帧更新"""
	# 如果死亡，不进行任何操作
	if is_dead:
		return
	
	# 生命值回复
	if health_regeneration > 0 and current_health < max_health:
		heal(health_regeneration * delta)
	
	# 如果没有目标，寻找最近的植物
	if not target_plant or not is_instance_valid(target_plant):
		find_nearest_plant()
	
	# 如果有目标，移动向目标
	if target_plant and is_instance_valid(target_plant):
		move_towards_target(delta)

func find_nearest_plant():
	"""寻找最近的植物目标"""
	var plants = get_tree().get_nodes_in_group("plant")
	if plants.is_empty():
		return
	var nearest_plant = null
	var nearest_distance = detection_range
	
	for plant in plants:
		if not is_instance_valid(plant):
			continue
			
		var distance = global_position.distance_to(plant.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_plant = plant
	
	target_plant = nearest_plant
	if target_plant:
		print("毛毛虫发现目标植物，距离: ", nearest_distance)

func move_towards_target(delta):
	"""向目标移动"""
	if not target_plant or not is_instance_valid(target_plant):
		return
	
	# 如果到达攻击范围，停止移动并切换到攻击状态
	if is_in_attack_area:
		is_moving = false
		if current_stage != MaoMaoStage.STAGE_2:
			set_current_stage(MaoMaoStage.STAGE_2)
		return
	
	# 计算移动方向
	var direction = (target_plant.global_position - global_position).normalized()
	
	# 移动
	global_position += direction * move_speed * delta
	is_moving = true
	
	# 确保在移动时播放行走动画
	if current_stage != MaoMaoStage.STAGE_1:
		set_current_stage(MaoMaoStage.STAGE_1)
	
	# 根据移动方向翻转精灵
	if direction.x < 0:
		scale.x = abs(scale.x)   # 向左移动时翻转
	else:
		scale.x = abs(scale.x) * -1  # 向右移动时正常

func update_animation():
	"""更新Spine动画"""
	if not spine_sprite:
		return
		
	var animation_name = stage_animations.get(current_stage, "stage1")
	# 播放对应阶段的动画
	spine_sprite.get_animation_state().set_animation(animation_name, true, 0)
	
	print("毛毛虫到阶段: ", current_stage, " 播放动画: ", animation_name)
	
func set_current_stage(new_stage: MaoMaoStage):
	"""设置当前生长阶段"""
	if new_stage != current_stage:
		current_stage = new_stage
		update_animation()

# 公共接口函数
func get_target_plant() -> Node2D:
	"""获取当前目标植物"""
	return target_plant

func get_distance_to_target() -> float:
	"""获取到目标的距离"""
	if target_plant and is_instance_valid(target_plant):
		return global_position.distance_to(target_plant.global_position)
	return -1.0

func is_at_attack_range() -> bool:
	"""检查是否在攻击范围内"""
	return is_in_attack_area

func stop_moving():
	"""停止移动"""
	is_moving = false
	target_plant = null

func set_target_plant(plant: Node2D):
	"""手动设置目标植物"""
	target_plant = plant

# 生命值相关函数
func set_current_health(new_health: float):
	"""设置当前生命值"""
	var old_health = current_health
	current_health = clamp(new_health, 0.0, max_health)
	
	# 发出生命值变化信号
	if old_health != current_health:
		health_changed.emit(current_health, max_health)
		print("毛毛虫生命值变化: ", current_health, "/", max_health)
	
	# 检查是否死亡
	if current_health <= 0 and not is_dead:
		die()

func take_damage(damage: float):
	"""受到伤害"""
	if is_dead:
		return
	
	set_current_health(current_health - damage)
	print("毛毛虫受到伤害: ", damage, " 剩余生命值: ", current_health)

func heal(heal_amount: float):
	"""治疗"""
	if is_dead:
		return
	
	set_current_health(current_health + heal_amount)

func die():
	"""死亡"""
	if is_dead:
		return
	
	is_dead = true
	is_moving = false
	target_plant = null
	
	# 切换到死亡动画
	set_current_stage(MaoMaoStage.STAGE_3)
	
	# 发出死亡信号
	died.emit()
	health_depleted.emit()
	
	print("毛毛虫死亡")

func revive(new_health: float = -1):
	"""复活"""
	is_dead = false
	
	if new_health > 0:
		set_current_health(new_health)
	else:
		set_current_health(max_health)
	
	# 切换回行走状态
	set_current_stage(MaoMaoStage.STAGE_1)
	
	print("毛毛虫复活，生命值: ", current_health)

func get_health_percentage() -> float:
	"""获取生命值百分比"""
	if max_health <= 0:
		return 0.0
	return (current_health / max_health) * 100.0

func is_alive() -> bool:
	"""检查是否存活"""
	return not is_dead and current_health > 0

func set_max_health(new_max_health: float):
	"""设置最大生命值"""
	max_health = max(new_max_health, 1.0)
	# 如果当前生命值超过新的最大值，调整当前生命值
	if current_health > max_health:
		set_current_health(max_health)

func _on_area_2d_area_entered(area: Area2D):
	if target_plant and area.get_parent() == target_plant:
		is_in_attack_area = true

func _on_area_2d_area_exited(area: Area2D):
	if target_plant and area.get_parent() == target_plant:
		is_in_attack_area = false
