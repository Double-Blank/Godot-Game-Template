extends Sprite2D

@export var speed: float = 400
@export var damage: float = 25
var target_enemy: Node2D = null

func _ready() -> void:
	# 寻找敌人目标
	find_target()

func find_target():
	# 在父节点中寻找敌人
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			if child.name.begins_with("Enemy"):
				target_enemy = child
				break

func _physics_process(delta: float) -> void:
	# 子弹向右移动
	global_position += Vector2(speed * delta, 0)
	
	# 检查是否击中敌人
	if target_enemy and is_instance_valid(target_enemy):
		if global_position.distance_to(target_enemy.global_position) < 30:
			target_enemy.queue_free()
			queue_free()
	
	# 如果子弹移出屏幕，删除它
	if global_position.x > 1200:  # 假设屏幕宽度约为1152
		queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("hint", body.has_method("take_damage"))
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
	pass # Replace with function body.
