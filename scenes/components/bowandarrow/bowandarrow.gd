extends Node2D
class_name BowAndArrow

@onready var spine_sprite: SpineSprite = $SpineSprite
@onready var crosshair_bone: SpineBoneNode = $SpineSprite/CrosshairBone


# 箭矢伤害
@export var arrow_damage: float = 20.0
# 击退强度（数值越大，弹开越远）
@export var knockback_force: float = 300.0

# 箭矢场景
const ARROW_SCENE = preload("res://scenes/components/bowandarrow/arrow/area_2d.tscn")
# 存储所有箭矢实例的数组
var arrows: Array[Node2D] = []
# 箭矢移动速度
var arrow_speed: float = 1600.0
# 屏幕范围（用于检测箭矢是否超出屏幕）
var screen_rect: Rect2

# 自动射击冷却时间
var shoot_cooldown: float = 0.5
# 当前冷却计时
var shoot_timer: float = 0.0
# 自动射击检测范围
var detection_range: float = 2000.0

# 存储当前要发射的目标位置
var current_target_position: Vector2 = Vector2.ZERO
# 是否正在等待动画事件发射箭矢
var waiting_for_shoot_event: bool = false

func _ready() -> void:
	spine_sprite.animation_event.connect(_on_animation_event)
	# 获取屏幕范围
	call_deferred("_setup_screen_rect")

func _setup_screen_rect():
	var viewport = get_viewport()
	var canvas_transform = viewport.canvas_transform
	# 计算屏幕范围（考虑可能的缩放和平移）
	screen_rect = Rect2(
		-canvas_transform.get_origin() / canvas_transform.get_scale(),
		viewport.get_visible_rect().size / canvas_transform.get_scale()
	)
	# 扩大一点范围，确保箭矢完全离开屏幕才销毁
	screen_rect = screen_rect.grow(100)

func _on_animation_event(sprite: SpineSprite, animation_state: SpineAnimationState, track_entry: SpineTrackEntry, event: SpineEvent):
	# Animation event: attack, 射出
	if event.get_data().get_event_name() == "射出":
		if waiting_for_shoot_event:
			# 实际发射箭矢
			_actually_spawn_arrow(current_target_position)
			waiting_for_shoot_event = false
			# current_target_position = Vector2.ZERO

# 鼠标点击时触发动画
func _input(event: InputEvent) -> void:
	# you键点击：播放动画，准备向鼠标位置发射
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# 获取鼠标位置作为目标
		var target_pos = get_global_mouse_position()
		# 触发动画播放
		play_shoot_animation(target_pos)
	
	# left键点击：播放动画，准备向指定位置发射（例如屏幕中心）
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		## 示例：向屏幕中心发射
		#var viewport = get_viewport()
		#var screen_center = viewport.get_visible_rect().size * 0.5
		#var world_center = get_viewport().get_canvas_transform().affine_inverse() * screen_center
		## 触发动画播放
		#play_shoot_animation(world_center)

# 播放射击动画并准备发射
func play_shoot_animation(target_position: Vector2 = Vector2.ZERO):
	# 如果没有传入目标位置，使用鼠标位置
	if target_position == Vector2.ZERO:
		target_position = get_global_mouse_position()
		# 更新准星位置跟随鼠标
		crosshair_bone.global_position = get_viewport().get_mouse_position()
	else:
		crosshair_bone.global_position = target_position
	# 存储目标位置
	current_target_position = target_position
	waiting_for_shoot_event = true
	
	var state = spine_sprite.get_animation_state()
	state.set_time_scale(1)
	# 播放射击动画
	spine_sprite.get_animation_state().set_animation("attack", 0, false)

# 实际发射箭矢的方法（由动画事件触发）
func _actually_spawn_arrow(target_position: Vector2):
	if target_position == Vector2.ZERO:
		return
	
	# 获取弓的发射位置（使用当前节点的全局位置）
	var spawn_pos = global_position
	
	# 实例化箭矢
	var arrow_instance = ARROW_SCENE.instantiate() as Node2D
	if arrow_instance == null:
		return
	
	# 添加箭矢到场景
	get_parent().add_child(arrow_instance)
	
	# 设置箭矢初始位置
	arrow_instance.global_position = spawn_pos
	
	# 连接碰撞信号
	arrow_instance.area_entered.connect(_on_arrow_area_entered.bind(arrow_instance))
	arrow_instance.body_entered.connect(_on_arrow_body_entered.bind(arrow_instance))
	
	# 计算从发射点到目标位置的向量
	var direction = (target_position - spawn_pos).normalized()
	
	# 计算箭矢的旋转角度（使其指向目标方向）
	var angle = direction.angle()
	arrow_instance.rotation = angle
	
	# 存储箭矢实例和其移动方向
	arrow_instance.set_meta("direction", direction)
	arrow_instance.set_meta("speed", arrow_speed)
	arrow_instance.set_meta("target_position", target_position)
	arrows.append(arrow_instance)

# 公共方法：可以从其他脚本调用
func shoot_arrow(target_position: Vector2):
	"""从弓的当前位置向指定目标位置发射箭矢（触发动画）"""
	play_shoot_animation(target_position)

func shoot_arrow_to_mouse():
	"""向鼠标位置发射箭矢（触发动画）"""
	var mouse_pos = get_global_mouse_position()
	play_shoot_animation(mouse_pos)

# 当箭矢碰到其他区域时触发
func _on_arrow_area_entered(area: Area2D, arrow: Node2D):
	_on_arrow_hit(area.get_parent(), arrow)

# 当箭矢碰到物理体时触发
func _on_arrow_body_entered(body: Node2D, arrow: Node2D):
	_on_arrow_hit(body, arrow)

# 统一处理命中逻辑
func _on_arrow_hit(target: Node, arrow: Node2D):
	if not is_instance_valid(arrow) or arrow not in arrows:
		return
		
	if target.is_in_group("enemy"):
		# 1. 处理伤害
		if target.has_method("take_damage"):
			target.take_damage(arrow_damage)
		
		# 2. 处理击退 (新增部分)
		# 计算从箭矢指向目标的击退方向
		var knockback_direction = arrow.get_meta("direction", Vector2.ZERO)
		
		# 如果目标有 handle_knockback 方法，则调用它
		if target.has_method("handle_knockback"):
			target.handle_knockback(knockback_direction, knockback_force)
		# 或者如果你的毛毛虫直接暴露了位置，也可以在这里微调（但不推荐，建议在毛毛虫内部处理）
		elif "position" in target:
			var tween = get_tree().create_tween()
			tween.tween_property(target, "position", target.position + knockback_direction * 50, 0.1)
		
		# 命中敌人后销毁箭矢
		arrows.erase(arrow)
		arrow.queue_free()

func _process(delta: float) -> void:
	# 自动锁敌逻辑
	if not waiting_for_shoot_event:
		if shoot_timer > 0:
			shoot_timer -= delta
		else:
			var target = _find_nearest_enemy()
			if target:
				play_shoot_animation(target.global_position)
				shoot_timer = shoot_cooldown

	# 遍历所有箭矢并移动它们
	for i in range(arrows.size() - 1, -1, -1):
		var arrow = arrows[i]
		if not is_instance_valid(arrow):
			arrows.remove_at(i)
			continue
		
		# 获取箭矢的移动数据
		var direction = arrow.get_meta("direction", Vector2.RIGHT)
		var speed = arrow.get_meta("speed", arrow_speed)
		
		# 移动箭矢
		arrow.global_position += direction * speed * delta
		
		# 检查箭矢是否超出屏幕
		if not screen_rect.has_point(arrow.global_position):
			# 销毁箭矢
			arrow.queue_free()
			arrows.remove_at(i)

# 寻找最近的敌人
func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest_enemy = null
	var min_dist = detection_range
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		# 如果敌人有 is_dead 属性且为 true，跳过
		if "is_dead" in enemy and enemy.is_dead:
			continue
			
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest_enemy = enemy
			
	return nearest_enemy
