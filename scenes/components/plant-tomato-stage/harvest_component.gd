extends Node2D
class_name HarvestComponent

## 收获组件
## 挂载在植物场景下，支持鼠标交互收获并增加金币

@export var harvest_value: int = 6
@export var area_path: NodePath = ^"../Area2D"

var parent_plant: Node2D
var area: Area2D
var sun_manager: SunManager

func _ready():
	parent_plant = get_parent()
	if area_path:
		area = get_node(area_path)
	
	if area:
		area.mouse_entered.connect(_on_mouse_entered)
		area.mouse_exited.connect(_on_mouse_exited)
		area.input_event.connect(_on_input_event)
		# 确保 Area2D 接收输入
		area.input_pickable = true
	
	# 获取场景中的 SunManager
	var sun_managers = get_tree().get_nodes_in_group("sun_manager")
	if sun_managers.size() > 0:
		sun_manager = sun_managers[0]
	else:
		# 备选方案：通过类名查找
		sun_manager = get_tree().get_first_node_in_group("sun_manager")
		if not sun_manager:
			# 尝试在根节点下寻找
			var root = get_tree().root
			sun_manager = _find_sun_manager(root)

func _find_sun_manager(node: Node) -> SunManager:
	if node is SunManager:
		return node
	for child in node.get_children():
		var found = _find_sun_manager(child)
		if found:
			return found
	return null

func _on_mouse_entered():
	print("_on_mouse_entered")
	# 检查植物是否可收获（例如是否在最终阶段，这里可以根据需要添加逻辑）
	# 暂时假设只要鼠标进入就显示手势
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		harvest()

func harvest():
	# 检查植物是否可以收获
	# 假设 tomato_plant 有一个方法判断是否成熟
	if parent_plant.has_method("can_harvest") and not parent_plant.can_harvest():
		return
		
	print("收获植物: ", parent_plant.name, " 获得金币: ", harvest_value)
	
	# 增加金币
	if sun_manager:
		sun_manager.sun += harvest_value
	else:
		# 如果没找到 sun_manager，尝试通过全局单例或组再次查找
		var mgr = get_tree().get_first_node_in_group("sun_manager")
		if mgr:
			mgr.sun += harvest_value
		else:
			print("错误: 未找到 SunManager")

	# 通知植物已被收获
	if parent_plant.has_method("on_harvested"):
		parent_plant.on_harvested()
