extends Control

@onready var grow_button = $VBoxContainer/GrowButton
@onready var kill_button = $VBoxContainer/KillButton
@onready var stage_label = $VBoxContainer/StageLabel
@onready var info_label = $VBoxContainer/InfoLabel
@onready var plant_component = $PlantComponent

var plant_tower: StaticBody2D = null

func _ready():
	# 查找植物塔
	find_plant_tower()
	
	# 连接按钮信号
	grow_button.pressed.connect(_on_grow_button_pressed)
	kill_button.pressed.connect(_on_kill_button_pressed)
	
	# 更新UI
	update_ui()

func find_plant_tower():
	"""查找场景中的植物塔"""
	# 在父节点中查找PlantComponent
	var parent = get_parent()
	if parent:
		plant_tower = plant_component
		if not plant_tower:
			# 如果没找到PlantComponent，尝试查找Plat-root
			plant_tower = parent.get_node_or_null("Plat-root")
	
	if plant_tower:
		# 连接植物生长管理器的信号
		var growth_manager = plant_tower.get_node_or_null("PlantGrowthManager")
		if growth_manager:
			growth_manager.stage_changed.connect(_on_plant_stage_changed)
			growth_manager.transition_completed.connect(_on_plant_transition_completed)

func _on_grow_button_pressed():
	"""生长按钮被点击"""
	if plant_tower and plant_tower.has_method("grow_plant"):
		plant_tower.grow_plant()
	update_ui()

func _on_kill_button_pressed():
	"""杀死按钮被点击"""
	if plant_tower and plant_tower.has_method("kill_plant"):
		plant_tower.kill_plant()
	update_ui()

func update_ui():
	"""更新UI显示"""
	if not plant_tower:
		stage_label.text = "阶段: 未找到植物"
		info_label.text = "状态: 无植物"
		grow_button.disabled = true
		kill_button.disabled = true
		return
	
	if plant_tower.has_method("get_stage_name"):
		var stage_name = plant_tower.get_stage_name()
		var current_stage = plant_tower.get_current_stage()
		stage_label.text = "阶段: %s (%d)" % [stage_name, current_stage]
		
		# 检查是否可以继续生长
		var growth_manager = plant_tower.get_node_or_null("PlantGrowthManager")
		if growth_manager:
			grow_button.disabled = not growth_manager.can_advance()
			kill_button.disabled = not growth_manager.is_alive()
			
			if growth_manager.is_alive():
				info_label.text = "状态: 存活"
			else:
				info_label.text = "状态: 死亡"
		else:
			grow_button.disabled = false
			kill_button.disabled = false
			info_label.text = "状态: 正常"
	else:
		stage_label.text = "阶段: 未知"
		info_label.text = "状态: 无法获取信息"

func _on_plant_stage_changed(old_stage, new_stage):
	"""植物阶段改变时更新UI"""
	update_ui()

func _on_plant_transition_completed(stage):
	"""植物过渡完成时更新UI"""
	update_ui()
