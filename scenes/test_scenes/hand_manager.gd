extends Node2D

@export var Plants: Node2D
@export var cell: Cell

var UINode:UI
var card_list:Array[CardTemplate]
var hand_scene
var card_res: CardRes
var select_sprite: Sprite2D  # 使用 Sprite2D 来显示所选
var mouse_in_cell: bool = false  # 添加状态跟踪，防止闪烁

func _ready() -> void:
	UINode = get_tree().get_first_node_in_group("UI")
	card_list = UINode.card_list
	for card in card_list:
		if(card != null):
			card.card_click.connect(_on_card_click)
	cell.click_cell.connect(_on_click_cell)
	cell.cell_mouse_enter.connect(_on_mouse_enter)
	cell.cell_mouse_exit.connect(_on_mouse_exit)

func _on_card_click(clicked_card_res: CardRes):
	if not select_sprite:
		select_sprite = Sprite2D.new()
		select_sprite.texture = clicked_card_res.card_shadow
		add_child(select_sprite)
		self.card_res = clicked_card_res
	
	select_sprite.global_position = get_global_mouse_position()

func _process(delta: float) -> void:
	# print(delta)
	if select_sprite:
		select_sprite.global_position = get_global_mouse_position()

func _on_click_cell(cell_click: Cell):
	if select_sprite:
		cell_click.is_plant = true
		# 实例化植物场景
		if card_res.plant_scene:
			#var spine_sprite: SpineSprite = cell_click.card_shadow.get_node("SpineSprite") 测试getnode
			var plant_instance = card_res.plant_scene.instantiate()
			cell_click.plant_set.add_child(plant_instance)
			#plant_instance.global_position = cell_click.global_position
			# 查找TomatoStageManager并设置为STAGE_1
			var stage_manager = plant_instance.find_child("TomatoStageManager", true, false)
			if stage_manager and stage_manager is TomatoStageManager:
				stage_manager.grow_to_stage(TomatoStageManager.GrowthStage.STAGE_1)
		# 清理选择状态
		if select_sprite:
			select_sprite.queue_free()  # 删除选择精灵
		select_sprite = null
		card_res = null
		cell_click.card_shadow.texture = null
		
		
		

func _on_mouse_enter(cell_enter: Cell):
	# 防止重复触发
	if mouse_in_cell:
		return
	
	# 检查 cell_enter 和 cell_enter.card_shadow 是否存在且有效
	if not cell_enter or not is_instance_valid(cell_enter):
		return
	if not cell_enter.card_shadow or not is_instance_valid(cell_enter.card_shadow):
		return
	# 检查 card_res 是否存在
	if not card_res:
		return
	# 检查 card_res.card_shadow 是否存在
	if not card_res.card_shadow:
		return
	
	# 设置状态并显示阴影
	mouse_in_cell = true
	cell_enter.card_shadow.texture = card_res.card_shadow

func _on_mouse_exit(cell_enter: Cell):
	# 防止重复触发
	if not mouse_in_cell:
		return
	
	# 检查 cell 和 cell.card_shadow 是否存在且有效
	if not cell_enter or not is_instance_valid(cell_enter):
		return
	if not cell_enter.card_shadow or not is_instance_valid(cell_enter.card_shadow):
		return
	
	# 重置状态并隐藏阴影
	mouse_in_cell = false
	cell_enter.card_shadow.texture = null
