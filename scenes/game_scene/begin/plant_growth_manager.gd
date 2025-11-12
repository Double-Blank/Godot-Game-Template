extends Node2D
class_name PlantGrowthManager

# 植物生长阶段枚举
enum GrowthStage {
	GERMINATION = 0,    # 发芽 - 根部开始生长
	SEEDLING = 1,       # 绿色草本幼苗 - 叶子开始生长
	VEGETATIVE = 2,     # 绿色香草蔬菜 - 叶子开始繁茂
	PRE_FLOWERING = 3,  # 开花前 - 植株长出花苞
	FLOWERING = 4,      # 花期 - 植株开花
	FRUITING = 5,       # 结果 - 植株长出果实
	DEATH = 6           # 死亡 - 植株枯萎
}

# 当前生长阶段
@export var current_stage: GrowthStage = GrowthStage.GERMINATION
# 过渡动画持续时间
@export var transition_duration: float = 1.0
# 是否自动播放过渡动画
@export var auto_play_transition: bool = true

# 各阶段的显示节点
var stage_nodes: Array[Node] = []
# 当前激活的节点
var current_active_node: Node = null

# 信号
signal stage_changed(old_stage: GrowthStage, new_stage: GrowthStage)
signal transition_started(to_stage: GrowthStage)
signal transition_completed(stage: GrowthStage)

func _ready():
	setup_stage_nodes()
	set_stage(current_stage, false)  # 初始化时不播放动画

func setup_stage_nodes():
	"""设置各阶段的显示节点"""
	stage_nodes.clear()
	
	# 阶段0: 发芽 - Spine2D根部
	var root_node = get_node_or_null("RootStage")
	if root_node:
		stage_nodes.append(root_node)
	else:
		stage_nodes.append(null)
	
	# 阶段1: 幼苗 - Spine2D叶子
	var leaves_node = get_node_or_null("LeavesStage")
	if leaves_node:
		stage_nodes.append(leaves_node)
	else:
		stage_nodes.append(null)
	
	# 阶段2-6: 图片占位符
	for i in range(2, 7):
		var stage_node = get_node_or_null("Stage" + str(i))
		if stage_node:
			stage_nodes.append(stage_node)
		else:
			stage_nodes.append(null)

func set_stage(new_stage: GrowthStage, play_transition: bool = true):
	"""设置植物生长阶段"""
	if new_stage == current_stage:
		return
	
	var old_stage = current_stage
	
	if play_transition and auto_play_transition:
		transition_started.emit(new_stage)
		await play_transition_animation(old_stage, new_stage)
	
	current_stage = new_stage
	update_display()
	
	stage_changed.emit(old_stage, new_stage)
	
	if play_transition and auto_play_transition:
		transition_completed.emit(new_stage)

func next_stage():
	"""进入下一个生长阶段"""
	if current_stage < GrowthStage.DEATH:
		set_stage(current_stage + 1)

func die():
	"""直接跳转到死亡阶段"""
	set_stage(GrowthStage.DEATH)

func update_display():
	"""更新显示的节点"""
	# 隐藏所有节点
	for node in stage_nodes:
		if node and is_instance_valid(node):
			node.visible = false
	
	# 显示当前阶段的节点
	if current_stage < stage_nodes.size():
		var target_node = stage_nodes[current_stage]
		if target_node and is_instance_valid(target_node):
			target_node.visible = true
			current_active_node = target_node
			
			# 如果是Spine节点，播放相应动画
			if target_node is SpineSprite:
				play_spine_animation(target_node, current_stage)

func play_spine_animation(spine_node: SpineSprite, stage: GrowthStage):
	"""播放Spine动画"""
	match stage:
		GrowthStage.GERMINATION:
			# 播放根部生长动画
			if spine_node.has_animation("grow"):
				spine_node.play("grow")
			elif spine_node.has_animation("idle"):
				spine_node.play("idle")
		GrowthStage.SEEDLING:
			# 播放叶子生长动画
			if spine_node.has_animation("grow"):
				spine_node.play("grow")
			elif spine_node.has_animation("idle"):
				spine_node.play("idle")

func play_transition_animation(from_stage: GrowthStage, to_stage: GrowthStage):
	"""播放过渡动画"""
	var tween = create_tween()
	
	# 当前节点淡出
	if current_active_node and is_instance_valid(current_active_node):
		tween.tween_property(current_active_node, "modulate:a", 0.0, transition_duration * 0.5)
	
	# 等待淡出完成
	await tween.finished
	
	# 更新显示
	update_display()
	
	# 新节点淡入
	if current_active_node and is_instance_valid(current_active_node):
		current_active_node.modulate.a = 0.0
		var fade_in_tween = create_tween()
		fade_in_tween.tween_property(current_active_node, "modulate:a", 1.0, transition_duration * 0.5)
		await fade_in_tween.finished

func get_stage_name(stage: GrowthStage) -> String:
	"""获取阶段名称"""
	match stage:
		GrowthStage.GERMINATION:
			return "发芽"
		GrowthStage.SEEDLING:
			return "幼苗"
		GrowthStage.VEGETATIVE:
			return "繁茂"
		GrowthStage.PRE_FLOWERING:
			return "花苞"
		GrowthStage.FLOWERING:
			return "开花"
		GrowthStage.FRUITING:
			return "结果"
		GrowthStage.DEATH:
			return "死亡"
		_:
			return "未知"

func is_alive() -> bool:
	"""检查植物是否存活"""
	return current_stage != GrowthStage.DEATH

func can_advance() -> bool:
	"""检查是否可以进入下一阶段"""
	return current_stage < GrowthStage.DEATH
