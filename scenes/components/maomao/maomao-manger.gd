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
@export var attack_range: float = 30.0  # 攻击范围

# 内部变量
var spine_sprite: SpineSprite
var target_plant: Node2D = null
var is_moving: bool = false

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
	
	# 设置初始动画
	update_animation()

func _process(delta):
	"""每帧更新"""
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
	
	var distance_to_target = global_position.distance_to(target_plant.global_position)
	
	# 如果到达攻击范围，停止移动并切换到攻击状态
	if distance_to_target <= attack_range:
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
	var distance = get_distance_to_target()
	return distance != -1.0 and distance <= attack_range

func stop_moving():
	"""停止移动"""
	is_moving = false
	target_plant = null

func set_target_plant(plant: Node2D):
	"""手动设置目标植物"""
	target_plant = plant
